import zmq


class MQL5DataStreammer:
    def __init__(self, request_port, subscribe_port):
        self._request_port = request_port
        self._subscribe_port = subscribe_port
        self._setup_subscribe_client()

    def _setup_subscribe_client(self):
        self._socket_sub.connect('%s:%s' % (
            self._server_hostname, self._subscribe_port))
        self._socket_sub.setsockopt(zmq.SUBSCRIBE, b'')

    def request_json_data(self):
        return self._socket_sub.recv_json()
