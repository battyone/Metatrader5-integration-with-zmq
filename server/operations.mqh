#ifndef OPERATIONS_MQH_
#define OPERATIONS_MQH_

#include <Trade\Trade.mqh>
#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

#define TICK_INDICATOR_NAME "tick_subscriber"
#define metrics_to_json(metric, out, rates)                                \
  out += "\"" + #metric + "\":" + "[" + DoubleToString(rates[0].##metric); \
  for (int i = 1; i < count; i++) {                                        \
    out += "," + DoubleToString(rates[i].##metric, 4);                     \
  }                                                                        \
  out += "]";

extern long order_magic = 12345;

void get_historical_data(JSONObject *&json_object, string &_return) {
  MqlRates rates[];
  int count = 0;
  ArraySetAsSeries(rates, true);
  count = CopyRates(
      json_object["symbol"],
      minutes_to_timeframe((int)StringToInteger(json_object["timeframe"])),
      StringToTime(json_object["start_datetime"]),
      (int)StringToInteger(json_object["count"]), rates);

  if (count > 0) {
    metrics_to_json(open, _return, rates);
    _return += ",";
    metrics_to_json(close, _return, rates);
    _return += ",";
    metrics_to_json(high, _return, rates);
    _return += ",";
    metrics_to_json(low, _return, rates);
    _return += ",";
    metrics_to_json(tick_volume, _return, rates);
    _return += ",";
    metrics_to_json(real_volume, _return, rates);
    _return += ",";
    metrics_to_json(spread, _return, rates);
    _return += ",";
    metrics_to_json(time, _return, rates);
  }
}

class Operations : public ZMQ_api {
 protected:
  CTrade trade;
  uint indicator_idx;
  void open_trade(JSONObject *&json_object);
  void modify_trade(JSONObject *&json_object);
  void close_trade(JSONObject *&json_object);

  void buy(JSONObject *&json_object);
  void sell(JSONObject *&json_object);

 public:
  Operations(Context &context, int order_deviation_pts = 10);
  void handle_trade_operations(JSONObject *&json_object);
  void handle_rate_operations(JSONObject *&json_object);
  string handle_data_operations(JSONObject *&json_object);
  string handle_tick_subscription(JSONObject *&json_object);
};

Operations::Operations(Context &_context, int order_deviation_pts = 10)
    : ZMQ_api(_context) {
  trade.SetExpertMagicNumber(order_magic);
  trade.SetDeviationInPoints(order_deviation_pts);
  trade.SetTypeFilling(ORDER_FILLING_RETURN);
  trade.LogLevel(LOG_LEVEL_ALL);
  trade.SetAsyncMode(true);
  indicator_idx = 0;
};

void Operations::sell(JSONObject *&json_object) {
  double stop_loss = get_market_info(json_object["symbol"], MODE_BID) +
                     StringToDouble(json_object["stop_loss"]) * _Point;
  double take_profit = get_market_info(json_object["symbol"], MODE_BID) -
                       StringToDouble(json_object["take_profit"]) * _Point;
  if (!trade.Sell(StringToDouble(json_object["volume"]), json_object["symbol"],
                  get_market_info(json_object["symbol"], MODE_BID), stop_loss,
                  take_profit)) {
    Print("Sell() method failed. Return code=", trade.ResultRetcode(),
          ". Code description: ", trade.ResultRetcodeDescription());
  } else {
    Print("Sell() method executed successfully. Return code=",
          trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
}

void Operations::buy(JSONObject *&json_object) {
  double stop_loss = get_market_info(json_object["symbol"], MODE_ASK) -
                     StringToDouble(json_object["stop_loss"]) * _Point;
  double take_profit = get_market_info(json_object["symbol"], MODE_ASK) +
                       StringToDouble(json_object["take_profit"]) * _Point;
  if (!trade.Buy(StringToDouble(json_object["volume"]), json_object["symbol"],
                 get_market_info(json_object["symbol"], MODE_ASK), stop_loss,
                 take_profit)) {
    Print("Buy() method failed. Return code=", trade.ResultRetcode(),
          ". Code description: ", trade.ResultRetcodeDescription());
  } else {
    Print("Buy() method executed successfully. Return code=",
          trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
}

void Operations::open_trade(JSONObject *&json_object) {
  if (json_object["type"] == "buy")
    buy(json_object);
  else if (json_object["type"] == "sell")
    sell(json_object);
}

void Operations::modify_trade(JSONObject *&json_object) {}

void Operations::close_trade(JSONObject *&json_object) {
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ulong order_ticket = OrderGetTicket(i);
    trade.OrderDelete(order_ticket);
  }
}

void Operations::handle_trade_operations(JSONObject *&json_object) {
  string action = json_object["action"];
  if (action == "open") {
    open_trade(json_object);
  } else if (action == "modify") {
    modify_trade(json_object);
  } else if (action == "close") {
    close_trade(json_object);
  }
}

string Operations::handle_data_operations(JSONObject *&json_object) {
  string metrics = "{ \"symbol\": \"" + json_object["symbol"] + "\" ,";
  get_historical_data(json_object, metrics);
  metrics += "}";
  return metrics;
}

void Operations::handle_rate_operations(JSONObject *&json_object) {
  string symbol = json_object["symbol"];
  string ret = StringFormat("%f|%f", get_market_info(symbol, MODE_BID),
                            get_market_info(symbol, MODE_ASK));
}

string Operations::handle_tick_subscription(JSONObject *&json_object) {
  string symbol = json_object["symbol"];
  string reply = StringFormat("Subscribed to %s", symbol);
  long timeframe_events = StringToInteger(json_object["timeframe_events"]);
  Print("Subscribing to " + symbol +
        ". Events: " + json_object["timeframe_events"]);
  if (iCustom(symbol, PERIOD_M1, TICK_INDICATOR_NAME, ChartID(),
              indicator_idx++, timeframe_events) == INVALID_HANDLE) {
    reply = StringFormat("Can't subscribe to %s", symbol);
    Print("Error on subscribing");
  }
  return reply;
}

#endif
