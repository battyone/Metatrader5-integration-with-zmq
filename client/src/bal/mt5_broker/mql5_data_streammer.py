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
        data_dict = self._socket_sub.recv_json()
        return SubscriptionData(
            symbol=data_dict['symbol'], bid=data_dict['bid_price'],
            ask=data_dict['ask_price'], timestamp=data_dict['timestamp'])
