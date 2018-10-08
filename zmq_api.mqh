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
};

void ZMQ_api::async_push(string message) {
  ZmqMsg pushReply(StringFormat("%s", message));
  push_socket.send(pushReply, true);
}

void ZMQ_api::ZMQ_api(Context& _context) {
  rep_socket = new Socket(_context, ZMQ_REP);
  push_socket = new Socket(_context, ZMQ_PUSH);

}

#endif
