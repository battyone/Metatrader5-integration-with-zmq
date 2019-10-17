#include <Zmq/Zmq.mqh>
#include <json.mqh>
#include <mql4_migration.mqh>
#include <operations.mqh>

extern string PROJECT_NAME = "zeromq_server";
extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";
extern int REP_PORT = 5555;
extern int TIMER_PERIOD_MS = 100;
extern int indicator_n = 0;

Context context(PROJECT_NAME);
Operations op(context);

int OnInit() {
  EventSetMillisecondTimer(TIMER_PERIOD_MS);
  op.setup_rep_server(ZEROMQ_PROTOCOL, HOSTNAME, REP_PORT);
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  op.close_server();
  EventKillTimer();
}

void OnTimer() { run_EA(); }

void run_EA(void) {
  string reply;
  ZmqMsg msg_container;
  int msg_size = op.listen_to_requests(msg_container);
  if (msg_size > 0) {
    reply = on_incomming_message(msg_container);
  }
  Print(reply);
  op.reply_to_requests(reply);
}

string on_incomming_message(ZmqMsg &client_request) {
  uchar _data[];
  JSONParser *json_parser = new JSONParser();
  JSONValue *json_value;
  string reply;

  if (client_request.size() > 0) {
    if (ArrayResize(_data, (int)client_request.size(), 0) != EMPTY) {
      client_request.getData(_data);
      string data_str = CharArrayToString(_data);
      json_value = json_parser.parse(data_str);

      if (json_value == NULL) {
        Print("Coudn't parse: " + (string)json_parser.getErrorCode() +
              (string)json_parser.getErrorMessage());
      } else {
        JSONObject *json_object = json_value;
        reply = handle_zmq_msg(json_object);
        delete json_value;
      }
    }
  }
  delete json_parser;
  return reply;
}

string handle_zmq_msg(JSONObject *&json_object) {
  string op_code = json_object["operation"];
  string reply;
  if (op_code == "trade") {
    reply =  op.handle_trade_operations(json_object);
  } else if (op_code == "rates") {
    reply = op.handle_rate_operations(json_object);
  } else if (op_code == "data") {
    reply = op.handle_data_operations(json_object);
  } else if (op_code == "subscribe") {
    reply = op.handle_tick_subscription(json_object);
  }
  return reply;
}