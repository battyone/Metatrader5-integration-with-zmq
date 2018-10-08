#ifndef OPERATIONS_MQH
#define OPERATIONS_MQH

#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

class Operations : ZMQ_api {
 protected:
  string get_bid_ask(string symbol);

 public:
  Operations(Context &context);
  void handle_trade_operations(JSONValue *&jason_object);
  void handle_rate_operations(JSONValue *&jason_object);
  void handle_data_operations(JSONValue *&jason_object);
};

void Operations::Operations(Context &context) : ZMQ_api(context) {}

void Operations::handle_trade_operations(JSONValue *&jason_value) {
  JSONObject *jason_object = jason_value;
  string action = jason_object["action"];
  if (action == "open") {
    async_push("OPEN TRADE Instruction Received");
  } else if (action == "modify") {
  } else if (action == "close") {
    async_push("CLOSE TRADE Instruction Received");
    string ret = "Trade Closed";
    async_push(ret);
  }
}

void Operations::handle_data_operations(JSONValue *&jason_value) {
  JSONObject *jason_object = jason_value;
  double price_array[];
  ArraySetAsSeries(price_array, true);
  async_push("HISTORICAL DATA Instruction Received");
  int price_count =
      CopyClose(jason_object["symbol"], 1, 0, 0, price_array);
  if (price_count > 0) {
    string closing_prices = jason_object["symbol"];

    for (int i = 0; i < price_count; i++) {
        closing_prices += closing_prices + DoubleToString(price_array[i]);
    }

    Print("Sending: " + closing_prices);
    async_push(StringFormat("%s", closing_prices));
  }
}

void Operations::handle_rate_operations(JSONValue *&jason_value) {
  JSONObject *jason_object = jason_value;
  string symbol = jason_object["symbol"];
  string ret = get_bid_ask(symbol);
  async_push(ret);
}

string get_bid_ask(string symbol) {
  double bid = get_market_info(symbol, MODE_BID);
  double ask = get_market_info(symbol, MODE_ASK);
  return (StringFormat("%f|%f", bid, ask));
}

#endif
