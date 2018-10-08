#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <operations.mqh>

extern string PROJECT_NAME = "zeromq_server";
extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";
extern int REP_PORT = 5555;
extern int PUSH_PORT = 5556;
extern int TIMER_PERIOD_MS = 1;

extern string t0 = "--- Trading Parameters ---";
extern int MaximumOrders = 1;
extern double MaximumLotSize = 0.01;

Context context(PROJECT_NAME);
Socket rep_socket(context, ZMQ_REP);
Socket push_socket(context, ZMQ_PUSH);

static JSONParser *json_parser = new JSONParser();
static JSONValue *json_value;

uchar data[];
ZmqMsg msg_container;
Operations op(&context);

int OnInit() {
  EventSetMillisecondTimer(TIMER_PERIOD_MS);
  Print("[REP] Binding REP Server:" + (string)REP_PORT + "..");
  Print("[PUSH] Binding PUSH Server:" + (string)PUSH_PORT + "..");
  rep_socket.bind(
      StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, REP_PORT));
  push_socket.bind(
      StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, PUSH_PORT));
  rep_socket.setLinger(1000);          // timeout for each push/rep
  rep_socket.setSendHighWaterMark(5);  // length of state retention .
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  Print("[REP] Unbinding Server:" + (string)REP_PORT + "..");
  rep_socket.unbind(
      StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, REP_PORT));
  Print("[PUSH] Unbinding Server:" + (string)PUSH_PORT + "..");
  push_socket.unbind(
      StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, PUSH_PORT));
}

void OnTimer() {
  rep_socket.recv(msg_container, true);
  ZmqMsg reply = on_incomming_message(msg_container, data);
  rep_socket.send(reply);
}

ZmqMsg on_incomming_message(ZmqMsg &_request, uchar &_data[]) {
  ZmqMsg reply;

  if (_request.size() > 0) {
    if (ArrayResize(_data, (int)_request.size(), 0) != EMPTY) {
      _request.getData(_data);
      string data_str = CharArrayToString(_data);
      json_value = json_parser.parse(data_str);
      if (json_value == NULL) {
        Print("Coudn't parse: " + (string)json_parser.getErrorCode() +
              (string)json_parser.getErrorMessage());
      } else {
        JSONObject *json_object = json_value;
        handle_zmq_msg(&push_socket, json_object);
        ZmqMsg ret(StringFormat("[SERVER] Processing: %s", data_str));
        reply = ret;
        delete json_value;
      }
    }
  }
  delete json_parser;
  return (reply);
}

void handle_zmq_msg(Socket &pSocket, JSONObject *&json_object) {
  string op_code = json_object["operation"];

  if (op_code == "trade") {
    op.handle_trade_operations(json_object);
  } else if (op_code == "rates") {
    op.handle_rate_operations(json_object);
  } else if (op_code == "data") {
    op.handle_data_operations(json_object);
  }
}

void ParseZmqMessage(string &message, string &retArray[]) {
  string sep = "|";
  ushort u_sep = StringGetCharacter(sep, 0);
  int splits = StringSplit(message, u_sep, retArray);

  for (int i = 0; i < splits; i++) {
    Print((string)i + ") " + retArray[i]);
  }
}

//+------------------------------------------------------------------+
// Generate string for Bid/Ask by symbol
string GetBidAsk(string symbol) {
  double bid = get_market_info(symbol, MODE_BID);
  double ask = get_market_info(symbol, MODE_ASK);
  return (StringFormat("%f|%f", bid, ask));
}

void async_push(Socket &_pushSocket, string message) {
  ZmqMsg pushReply(StringFormat("%s", message));
  _pushSocket.send(pushReply, true);
}
