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

    def request_json_data(self):
        return self._socket_sub.recv_json()
