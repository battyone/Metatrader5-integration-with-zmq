#ifndef OPERATIONS_MQH_
#define OPERATIONS_MQH_

#include <Trade\Trade.mqh>
#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

class Operations : ZMQ_api {
 protected:
  double stop_loss_level, take_profit_level, stop_level;
  CTrade trade;

  extern double MaximumLotSize = 0.01;
  extern int Slippage = 3;
  extern input long order_magic = 12345;

  void open_trade(JSONObject *&json_object);
  void modify_trade(JSONObject *&json_object);
  void close_trade(JSONObject *&json_object);

  void buy(JSONObject *&json_object);
  void sell(JSONObject *&json_object);

 public:
  Operations(Context &context, double stop_loss_level, double take_profit_level,
             double stop_level);
  void handle_trade_operations(JSONValue *&json_value);
  void handle_rate_operations(JSONValue *&json_value);
  void handle_data_operations(JSONValue *&json_value);
};

Operations::Operations(Context &context, double _stop_loss_level,
                       double _TakeProfitLevel, double _stop_level,
                       int order_deviation_pts = 10)
    : ZMQ_api(context),
      stop_loss_level(_stop_loss_level),
      take_profit_level(_TakeProfitLevel),
      stop_level(_stop_level) {
  trade.SetExpertMagicNumber(order_magic);
  trade.SetDeviationInPoints(order_deviation_pts);
  trade.SetTypeFilling(ORDER_FILLING_RETURN);
  trade.LogLevel(1);
  trade.SetAsyncMode(true);
};

void sell(JSONObject *&json_object) {
  stop_loss_level = get_market_info(json_object["symbol"], MODE_BID) +
                    StrToDouble(json_object["price"]) * _Point;
  take_profit_level = get_market_info(json_object["symbol"], MODE_BID) -
                      StrToDouble(json_object["sl"]) * _Point;
  if (!trade.Sell(json_object['volume'], json_object["symbol"],
                  get_market_info(json_object["symbol"], MODE_BID),
                  stop_loss_level, take_profit_level)) {
    Print("Sell() method failed. Return code=", trade.ResultRetcode(),
          ". Code description: ", trade.ResultRetcodeDescription());
  } else {
    Print("Sell() method executed successfully. Return code=",
          trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
}

void buy(JSONObject *&json_object) {
  stop_loss_level = get_market_info(json_object["symbol"], MODE_ASK) -
                    StrToDouble(json_object["price"]) * _Point;
  take_profit_level = get_market_info(json_object["symbol"], MODE_ASK) +
                      StrToDouble(json_object["sl"]) * _Point;
  if (!trade.Buy(json_object['volume'], json_object["symbol"],
                 get_market_info(json_object["symbol"], MODE_ASK),
                 stop_loss_level, take_profit_level)) {
    Print("Buy() method failed. Return code=", trade.ResultRetcode(),
          ". Code description: ", trade.ResultRetcodeDescription());
  } else {
    Print("Buy() method executed successfully. Return code=",
          trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
}

void Operations::open_trade(JSONObject *&json_object) {
  json_object["type"] == "buy" ? (buy : sell)(json_object);
}

void Operations::modify_trade(JSONObject *&json_object) {}

void Operations::close_trade(JSONObject *&json_object) {
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ulong order_ticket = OrderGetTicket(i);
    trade.OrderDelete(order_ticket);
  }
}

void Operations::handle_trade_operations(JSONValue *&json_value) {
  JSONObject *json_object = json_value;
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

void Operations::handle_data_operations(JSONValue *&json_value) {
  JSONObject *json_object = json_value;
  double price_array[];
  ArraySetAsSeries(price_array, true);
  async_push("HISTORICAL DATA Instruction Received");
  int price_count = CopyClose(json_object["symbol"], 1, 0, 0, price_array);
  if (price_count > 0) {
    string closing_prices = "{ \"symbol\":" + json_object["symbol"] + "," +
                            "\"closing_prices\":" + "[" +
                            DoubleToString(price_array[0]);
    for (int i = 1; i < price_count; i++) {
      closing_prices += "," + DoubleToString(price_array[i]);
    }

    closing_prices += "]}";
    Print("Sending: " + closing_prices);
    async_push(StringFormat("%s", closing_prices));
  }
}

void Operations::handle_rate_operations(JSONValue *&json_value) {
  JSONObject *json_object = json_value;
  string symbol = json_object["symbol"];
  string ret = StringFormat("%f|%f", get_market_info(symbol, MODE_BID),
                            get_market_info(symbol, MODE_ASK));
  async_push(ret);
}

#endif
