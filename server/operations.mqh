#ifndef OPERATIONS_MQH_
#define OPERATIONS_MQH_

#include <Trade\Trade.mqh>
#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

#define metrics_to_json(metric, out, rates)                                  \
  out += "\"" + "#metric" + "\":" + "[" + DoubleToString(rates[0].##metric); \
  for (int i = 1; i < count; i++) {                                          \
    out += "," + DoubleToString(rates[i].##metric);                          \
  }                                                                          \
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
      StringToTime(json_object["count"]), rates);
  Print(json_object["symbol"]);

  Print(minutes_to_timeframe((int)StringToInteger(json_object["timeframe"])));
  Print(StringToTime(json_object["end_datetime"]));
  Print(StringToTime(json_object["start_datetime"]));

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
  Print("return %s", _return);
  Print("return %s", _return);
  Print("return %s", _return);
  Print("return %s", _return);
  Print("return %s", _return);
  Print("return %s", _return);
  Print("return %s", _return);
  Sleep(500000);
}

class Operations : public ZMQ_api {
 protected:
  CTrade trade;

  void open_trade(JSONObject *&json_object);
  void modify_trade(JSONObject *&json_object);
  void close_trade(JSONObject *&json_object);

  void buy(JSONObject *&json_object);
  void sell(JSONObject *&json_object);

 public:
  Operations(Context &context, int order_deviation_pts = 10);
  void handle_trade_operations(JSONObject *&json_object);
  void handle_rate_operations(JSONObject *&json_object);
  void handle_data_operations(JSONObject *&json_object);
};

Operations::Operations(Context &_context, int order_deviation_pts = 10)
    : ZMQ_api(_context) {
  trade.SetExpertMagicNumber(order_magic);
  trade.SetDeviationInPoints(order_deviation_pts);
  trade.SetTypeFilling(ORDER_FILLING_RETURN);
  trade.LogLevel(1);
  trade.SetAsyncMode(true);
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
    async_push("OPEN TRADE Instruction Received");
    open_trade(json_object);
  } else if (action == "modify") {
    async_push("MODIFY TRADE Instruction Received");
    modify_trade(json_object);
  } else if (action == "close") {
    async_push("CLOSE TRADE Instruction Received");
    close_trade(json_object);
    string ret = "Trade Closed";
    async_push(ret);
  }
}

void Operations::handle_data_operations(JSONObject *&json_object) {
  async_push("HISTORICAL DATA Instruction Received");
  string metrics = "{ \"symbol\":" + json_object["symbol"] + ",";
  Print("symbol: " + json_object["symbol"]);
  get_historical_data(json_object, metrics);
  metrics += "}";

  Print("Sending: " + metrics);
  async_push(StringFormat("%s", metrics));
}

void Operations::handle_rate_operations(JSONObject *&json_object) {
  string symbol = json_object["symbol"];
  string ret = StringFormat("%f|%f", get_market_info(symbol, MODE_BID),
                            get_market_info(symbol, MODE_ASK));
  async_push(ret);
}

ENUM_TIMEFRAMES minutes_to_timeframe(int minutes) {
  switch (minutes) {
    case 0:
      return (PERIOD_CURRENT);
    case 1:
      return (PERIOD_M1);
    case 2:
      return (PERIOD_M2);
    case 3:
      return (PERIOD_M3);
    case 4:
      return (PERIOD_M4);
    case 5:
      return (PERIOD_M5);
    case 6:
      return (PERIOD_M6);
    case 10:
      return (PERIOD_M10);
    case 12:
      return (PERIOD_M12);
    case 15:
      return (PERIOD_M15);
    case 30:
      return (PERIOD_M30);
    case 60:
      return (PERIOD_H1);
    case 120:
      return (PERIOD_H2);
    case 180:
      return (PERIOD_H3);
    case 240:
      return (PERIOD_H4);
    case 360:
      return (PERIOD_H6);
    case 480:
      return (PERIOD_H8);
    case 1440:
      return (PERIOD_D1);
    case 10080:
      return (PERIOD_W1);
    case 43200:
      return (PERIOD_MN1);
    default:
      return (PERIOD_CURRENT);
  }
}

#endif
