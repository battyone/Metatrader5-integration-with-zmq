#ifndef OPERATIONS_MQH_
#define OPERATIONS_MQH_

#include <Trade\Trade.mqh>
#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

#define TICK_INDICATOR_NAME "tick_subscriber"
#define metrics_to_json(metric, out, rates, count)                         \
  out += "\"" + #metric + "\":" + "[" + DoubleToString(rates[0].##metric); \
  for (int i = 1; i < count; i++) {                                        \
    out += "," + DoubleToString(rates[i].##metric, 4);                     \
  }                                                                        \
  out += "]";

extern long order_magic = 12345;

bool create_symbol_file(string symbol) {
  int file_handle = FileOpen(SYMBOLS_FOLDER + "//" + symbol,
                             FILE_READ | FILE_WRITE | FILE_ANSI | FILE_COMMON);
  bool ret = false;
  if (file_handle != INVALID_HANDLE) {
    FileClose(file_handle);
    ret = true;
  } else {
    PrintFormat("Failed to open %s file, Error code = %d", symbol,
                GetLastError());
  }
  return ret;
}

void get_historical_data(JSONObject *&json_object, string &_return) {
    bool success = false;
    MqlTick tick_array[];
    int count = 0;
    ulong from_ms = (ulong) StringToInteger(json_object["from_ms"]);
    ulong to_ms = (ulong) StringToInteger(json_object["to_ms"]);
    string symbol = json_object["symbol"];
    Print("from ",from_ms);
    Print("to ", to_ms);
    Print("symbol ", symbol);
    for (int attempts = 0; attempts<3; attempts++) {
        uint start = GetTickCount();
        int received = CopyTicksRange(
            symbol,
            tick_array,
            COPY_TICKS_ALL,
            from_ms,
            to_ms);
        count += received;
        int error = GetLastError();
        Print(error);
        if (received != -1) {
            PrintFormat("%s: received %d ticks in %d ms", symbol, received, GetTickCount() - start);
            if (GetLastError() == 0) {
                success = true;
                break;
            } else {
                PrintFormat("%s: Ticks are not synchronized yet, %d ticks received for %d ms. Error=%d",
                symbol, received, GetTickCount() - start, _LastError);
            }
        }
        Sleep(1000);
    }

    _return = "time, bid, ask, last, volume, volume_real, flags\n";
    if (success) {
        for (int i = 0; i < count; i++) {
            _return += StringFormat("%s,%.3f,%.3f,%.3f,%d,%d,%d\n", IntegerToString(tick_array[i].time_msc), tick_array[i].bid, tick_array[i].ask, tick_array[i].last, tick_array[i].volume, tick_array[i].volume_real, tick_array[i].flags);
        }
    }
}

class Operations : public ZMQ_api {
    protected:
        CTrade trade_helper;
        uint indicator_idx;
        int open_trade(JSONObject *&json_object);
        int modify_trade(JSONObject *&json_object);
        int close_trade(JSONObject *&json_object);

        int buy(JSONObject *&json_object);
        int sell(JSONObject *&json_object);

    public:
        Operations(Context &context, int order_deviation_pts = 10);
        string handle_trade_operations(JSONObject *&json_object);
        string handle_rate_operations(JSONObject *&json_object);
        string handle_data_operations(JSONObject *&json_object);
        string handle_tick_subscription(JSONObject *&json_object);
};

Operations::Operations(Context &_context, int order_deviation_pts = 10)
    : ZMQ_api(_context) {
    trade_helper.SetExpertMagicNumber(order_magic);
    trade_helper.SetDeviationInPoints(order_deviation_pts);
    trade_helper.SetTypeFilling(ORDER_FILLING_RETURN);
    trade_helper.LogLevel(LOG_LEVEL_ALL);
    trade_helper.SetAsyncMode(true);
    indicator_idx = 0;
};

int Operations::sell(JSONObject *&json_object) {
    int ret = 0;
    double stop_loss = get_market_info(json_object["symbol"], MODE_BID) +
                        StringToDouble(json_object["stop_loss"]) * _Point;
    double take_profit = get_market_info(json_object["symbol"], MODE_BID) -
                        StringToDouble(json_object["take_profit"]) * _Point;
    if (!trade_helper.Sell(StringToDouble(json_object["volume"]),
                            json_object["symbol"],
                            get_market_info(json_object["symbol"], MODE_BID),
                            stop_loss, take_profit)) {
        Print("Sell() method failed. Return code=", trade_helper.ResultRetcode(),
                ". Code description: ", trade_helper.ResultRetcodeDescription());
        ret = -1;
    } else {
        Print("Sell() method executed successfully. Return code=",
                trade_helper.ResultRetcode(), " (",
                trade_helper.ResultRetcodeDescription(), ")");
    }
    return ret;
}

int Operations::buy(JSONObject *&json_object) {
    int ret = 0;
    double stop_loss = get_market_info(json_object["symbol"], MODE_ASK) -
                        StringToDouble(json_object["stop_loss"]) * _Point;
    double take_profit = get_market_info(json_object["symbol"], MODE_ASK) +
                        StringToDouble(json_object["take_profit"]) * _Point;
    if (!trade_helper.Buy(StringToDouble(json_object["volume"]),
                        json_object["symbol"],
                        get_market_info(json_object["symbol"], MODE_ASK),
                        stop_loss, take_profit)) {
        ret = (int)trade_helper.ResultRetcode();
        Print("Buy() method failed. Return code=", ret,
                ". Code description: ", trade_helper.ResultRetcodeDescription());
        ret = -1;
    } else {
        Print("Buy() method executed successfully. Return code=",
                trade_helper.ResultRetcode(), " (",
                trade_helper.ResultRetcodeDescription(), ")");
    }
    return ret;
}

int Operations::open_trade(JSONObject *&json_object) {
    if (json_object["type"] == "buy")
        return buy(json_object);
    else if (json_object["type"] == "sell")
        return sell(json_object);
    else
        return -1;
}

int Operations::modify_trade(JSONObject *&json_object) { return -1; }

int Operations::close_trade(JSONObject *&json_object) {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        ulong order_ticket = OrderGetTicket(i);
        trade_helper.OrderDelete(order_ticket);
    }
    return 1;
}

string Operations::handle_trade_operations(JSONObject *&json_object) {
    string action = json_object["action"];
    int ret = 0;
    if (action == "open") {
        ret = open_trade(json_object);
    } else if (action == "modify") {
        ret = modify_trade(json_object);
    } else if (action == "close") {
        ret = close_trade(json_object);
    }
    return StringFormat("{\"code\":%d}", ret);
}

string Operations::handle_data_operations(JSONObject *&json_object) {
    string data;
    get_historical_data(json_object, data);
    return data;
}

string Operations::handle_rate_operations(JSONObject *&json_object) {
  string symbol = json_object["symbol"];
  MqlTick last_tick;
  SymbolInfoTick(symbol, last_tick);
  return StringFormat("{\"bid\":%d,\"ask\":%d,\"volume\":%d}",
                      last_tick.bid, last_tick.ask, last_tick.volume);
}

string Operations::handle_tick_subscription(JSONObject *&json_object) {
  string symbol = json_object["symbol"];
  int ret = 0;
  Print("Subscribing to " + symbol);

  if (!create_symbol_file(symbol)) {
    ret = -1;
    Print(StringFormat("Coudn't subscribe to %s", symbol));
  }
  return StringFormat("{\"code\":%d}", ret);
}

#endif
