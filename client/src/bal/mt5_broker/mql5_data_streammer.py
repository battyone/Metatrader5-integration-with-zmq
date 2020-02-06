from bal.subscriptions import SubscriptionData
from collections import namedtuple
from threading import Thread
from queue import Queue
import zmq


class MQL5DataStreammer:
    def __init__(self, server_hostname, request_port, server_closed):
        self._server_hostname = server_hostname
        self._request_port = request_port
        self._context = zmq.Context()
        self._server_closed = server_closed
        self._subscription_queue = Queue()
        self._port_to_symbol = {}

    def _blocking_polling_data(self, socket, port):
        while not self._server_closed.is_set():
            data = socket.recv().decode("utf-8").split("|")
            self._subscription_queue.put(SubscriptionData(
                self._port_to_symbol[port], data[0], data[1], data[2], data[3], data[4], data[5]))
        socket.close()

    @staticmethod
    def _wait_for_server():
        # This workaround exists to wait until a server is existent.
        import time
        time.sleep(3)

    def add_subscription(self, symbol):
        self._request_port += 1
        available_port = self._request_port
        self._port_to_symbol[symbol] = available_port
        self._wait_for_server()
        socket = self._context.socket(zmq.SUB)
        socket.connect('%s:%s' % (self._server_hostname, available_port))
        socket.setsockopt(zmq.SUBSCRIBE, b'')
        Thread(target=self._blocking_polling_data,
               args=(socket, available_port),
               daemon=True).start()

    def request_data(self):
        return self._subscription_queue.get()
