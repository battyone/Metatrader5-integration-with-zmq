#ifndef ZMQ_API_MQH
#define ZMQ_API_MQH
#include <Zmq/Zmq.mqh>

class ZMQ_api {
 protected:
  Socket *rep_socket;
  Socket *pub_socket;
  string zeromq_protocol;
  string hostname;
  int pub_port;
  int rep_port;

 public:
  ZMQ_api(Context &context);
  void setup_pub_server(string zeromq_protocol, string hostname, int pub_port);
  void setup_rep_server(string zeromq_protocol, string hostname, int rep_port);
  void setup_server(string zeromq_protocol, string hostname, int rep_port,
                    int pub_port);
  void close_server(void);
  int listen_to_requests(ZmqMsg &_msg_container);
  void reply_to_requests(string reply);
  // void publish(string topic, string data);
  void publish(string data);
  void publish(const uchar &data[]);
};

void ZMQ_api::setup_pub_server(string _zeromq_protocol, string _hostname,
                               int _pub_port) {
  zeromq_protocol = _zeromq_protocol;
  hostname = _hostname;
  pub_port = _pub_port;
  Print("Binding PUB Server:" + (string)(pub_port) + "..");
  pub_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, pub_port));
}

void ZMQ_api::setup_rep_server(string _zeromq_protocol, string _hostname,
                               int _rep_port) {
  zeromq_protocol = _zeromq_protocol;
  hostname = _hostname;
  rep_port = _rep_port;
  Print("Binding REP Server:" + (string)rep_port + "..");

  rep_socket.bind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
  rep_socket.setLinger(1000);
  rep_socket.setSendHighWaterMark(5);
}

void ZMQ_api::setup_server(string _zeromq_protocol, string _hostname,
                           int _rep_port, int _pub_port) {
  setup_rep_server(_zeromq_protocol, _hostname, _rep_port);
  setup_pub_server(_zeromq_protocol, _hostname, _pub_port);
}

void ZMQ_api::close_server(void) {
  rep_socket.unbind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, rep_port));
  pub_socket.unbind(
      StringFormat("%s://%s:%d", zeromq_protocol, hostname, pub_port));
}

void ZMQ_api::ZMQ_api(Context &_context) {
  rep_socket = new Socket(_context, ZMQ_REP);
  pub_socket = new Socket(_context, ZMQ_PUB);
}

int ZMQ_api::listen_to_requests(ZmqMsg &_msg_container) {
  return rep_socket.recv(_msg_container);
}

void ZMQ_api::reply_to_requests(string reply) { rep_socket.send(reply); }

void ZMQ_api::publish(const uchar &data[]) {
  pub_socket.send(data, true);
}

// void ZMQ_api::publish(string topic, string data) {
void ZMQ_api::publish(string data) {
  // string msg = StringFormat("%s %s", topic, data);
  // pub_socket.send(msg, true);
  pub_socket.send(data, true);
}

#endif
