#ifndef ZMQ_API_MQH
#define ZMQ_API_MQH
#include <Zmq/Zmq.mqh>

class ZMQ_api {
 protected:
  Socket* rep_socket;
  Socket* push_socket;
  void async_push(string message);

 public:
  ZMQ_api(Context& context);
  void setup_server(string zeromq_protocol, string hostname, int rep_port,
                    int push_port);
  void close_server(string zeromq_protocol, string hostname, int rep_port,
                    int push_port);
  void listen_to_requests(ZmqMsg& _msg_container);
  void reply_to_requests(ZmqMsg& _msg_container);
};

void ZMQ_api::setup_server(string zeromq_protocol, string hostname,
                           int rep_port, int push_port) {
  Print("Binding REP Server:" + (string)rep_port + "..");
  Print("Binding PUSH Server:" + (string)push_port + "..");
  rep_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
  push_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, push_port));
  rep_socket.setLinger(1000);
  rep_socket.setSendHighWaterMark(5);
  Print("bb");
}

void ZMQ_api::close_server(string zeromq_protocol, string hostname,
                           int rep_port, int push_port) {
  rep_socket.unbind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
  push_socket.unbind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, push_port));
}

void ZMQ_api::async_push(string message) {
  ZmqMsg pushReply(StringFormat("%s", message));
  push_socket.send(pushReply, true);
}

void ZMQ_api::ZMQ_api(Context& _context) {
  rep_socket = new Socket(_context, ZMQ_REP);
  push_socket = new Socket(_context, ZMQ_PUSH);
}

void ZMQ_api::listen_to_requests(ZmqMsg& _msg_container) {
  rep_socket.recv(&_msg_container, false);
}

void ZMQ_api::reply_to_requests(ZmqMsg& reply) { rep_socket.send(reply); }

#endif
