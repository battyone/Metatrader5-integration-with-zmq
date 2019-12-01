from bal.subscriptions import SubscriptionData
import zmq


class MQL5DataStreammer:
    def __init__(self, server_hostname, subscribe_port):
        self._server_hostname = server_hostname
        self._subscribe_port = subscribe_port
        _context = zmq.Context()
        self._socket_sub = _context.socket(zmq.SUB)
        self._setup_subscribe_client()

    def _setup_subscribe_client(self):
        self._socket_sub.connect('%s:%s' % (
            self._server_hostname, self._subscribe_port))
        self._socket_sub.setsockopt(zmq.SUBSCRIBE, b'')

    def request_data(self):
        data = self._socket_sub.recv().decode("utf-8").split("|")
        return SubscriptionData(data[0], data[1], data[2], data[3], data[4], data[5], data[6])
