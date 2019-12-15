from bal.subscriptions import SubscriptionData
import zmq


class MQL5DataStreammer:
    def __init__(self, server_hostname, request_port):
        self._server_hostname = server_hostname
        self._request_port = request_port
        self._context = zmq.Context()
        self._sockets_sub = {}
        # self._setup_subscribe_client()

    def add_subscription(self):
        self._request_port += 1
        available_port = self._request_port
        self._sockets_sub[available_port] = self._context.socket(zmq.SUB)

        self._sockets_sub[available_port].connect('%s:%s' % (
            self._server_hostname, available_port))
        self._sockets_sub[available_port].setsockopt(zmq.SUBSCRIBE, b'')

    def request_data(self):
        data = self._socket_sub.recv().decode("utf-8").split("|")
        return SubscriptionData(data[0], data[1], data[2], data[3], data[4], data[5], data[6])
