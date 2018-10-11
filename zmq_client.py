import zmq
import json
import numpy as np


class zmq_python():
    def __init__(self):
        self.context = zmq.Context()
        self.req_socket = self.context.socket(zmq.REQ)
        self.req_socket.connect('tcp://localhost:5555')

        self.pull_socket = self.context.socket(zmq.PULL)
        self.pull_socket.connect('tcp://localhost:5556')

    def _push_to_server(self, socket, data):
        try:
            socket.send_string(data)
            msg_send = socket.recv_string()
            print('Sent %s' % msg_send)
        except zmq.Again as e:
            print('Try Again %s' % e)

    def _pull_from_server(self, socket):
        try:
            msg_pull = socket.recv(flags=zmq.NOBLOCK)
            return msg_pull
        except zmq.Again as e:
            print('Try Again %s' % e)

    def _send_and_receive(self, data):
        self.push_to_server(self.req_socket, data)
        return self.pull_from_server(self.pull_socket)

    def get_data(self, symbol, timeframe, start_datetime, end_datetime):
        request = {'operation': 'data', 'symbol': symbol,
                   'timeframe': timeframe,
                   'start_datetime': str(start_datetime),
                   'end_datetime': str(end_datetime)}

        prices = self._send_and_receive(request)
        prices_str = str(prices)
        price_lst = prices_str.split(sep='|')[1:-1]
        price_lst = [float(i) for i in price_lst]
        price_lst = price_lst[::-1]
        price_arr = np.array(price_lst)
        return price_arr

    def buy_order(self, symbol, stop_loss, take_profit):
        request = {'operation': 'trade', 'symbol': symbol,
                   'timeframe': timeframe, 'type': 'buy',
                   'price': aaaaaaaa, 'sl': stop_loss}
        return self._send_and_receive(cmd)
