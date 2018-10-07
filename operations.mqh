#ifndef OPERATIONS_MQH
#define OPERATIONS_MQH
#include <Zmq/Zmq.mqh>
#include <json.mqh>

class Operations {
 private:
  void async_push(Socket &push_socket, string message);

 public:
  Operations(void);
  int handle_trade_operations(Socket &push_socket, JSONValue *&jason_object);
  int handle_rate_operations(Socket &push_socket, JSONValue *&jason_object);
  int handle_data_operations(Socket &push_socket, JSONValue *&jason_object);
};

void Operations::async_push(Socket &push_socket, string message) {
  ZmqMsg pushReply(StringFormat("%s", message));
  push_socket.send(pushReply, true);
}

void Operations::Operations() {}

int Operations::handle_trade_operations(Socket &push_socket,
                                        JSONValue *&jason_value) {
  JSONObject *jason_object = jason_value;
  string action = jason_object.getString("action");
  if (action == "open") {
    async_push(push_socket, "OPEN TRADE Instruction Received");
  } else if (action == "modify") {
  } else if (action == "close") {
    async_push(push_socket, "CLOSE TRADE Instruction Received");
    ret = StringFormat("Trade Closed (Ticket: %d)", ticket);
    async_push(push_socket, ret);
  }
  return (1);
}

int Operations::handle_data_operations(Socket &push_socket,
                                       JSONValue *&jason_value) {}

int Operations::handle_rate_operations(Socket &push_socket,
                                       JSONValue *&jason_value) {
  JSONObject *jason_object = jason_value;
  string ret = "";
  string symbol = jason_object.getString("symbol");
  ret = "N/A";
  ret = GetBidAsk(symbol);
  Operations::async_push(push_socket, ret);
}

#endif
