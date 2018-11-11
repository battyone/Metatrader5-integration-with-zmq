#ifndef ZMQ_API_MQH
#define ZMQ_API_MQH
#include <Zmq/Zmq.mqh>

class ZMQ_api {
protected:
  Socket *rep_socket;
  Socket *pub_sub_socket;

public:
  ZMQ_api(Context &context);
  void setup_server(string zeromq_protocol, string hostname, int rep_port);
  void close_server(string zeromq_protocol, string hostname, int rep_port);
  int listen_to_requests(ZmqMsg &_msg_container);
  void reply_to_requests(string reply);
  void publish(string topic, string data);
};

void ZMQ_api::setup_server(string zeromq_protocol, string hostname,
                           int rep_port) {
  Print("Binding REP Server:" + (string)rep_port + "..");
  Print("Binding PUB Server:" + (string)(rep_port + 1) + "..");
  rep_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
  pub_sub_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port + 1));
  rep_socket.setLinger(1000);
  rep_socket.setSendHighWaterMark(5);
}

void ZMQ_api::close_server(string zeromq_protocol, string hostname,
                           int rep_port) {
  rep_socket.unbind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
}

void ZMQ_api::ZMQ_api(Context &_context) {
  rep_socket = new Socket(_context, ZMQ_REP);
  pub_sub_socket = new Socket(_context, ZMQ_PUB);
}

int ZMQ_api::listen_to_requests(ZmqMsg &_msg_container) {
  return rep_socket.recv(_msg_container);
}

void ZMQ_api::reply_to_requests(string reply) { rep_socket.send(reply); }

void ZMQ_api::publish(string topic, string data) {
  string msg = StringFormat("%s %s", topic, data);
  pub_sub_socket.send(msg, true);
}

#endif
