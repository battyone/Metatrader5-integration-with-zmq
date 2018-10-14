import zmq
import json


class ZMQClient():
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
        self._push_to_server(self.req_socket, data)
        return self._pull_from_server(self.pull_socket)

    def get_data(self, symbol, timeframe, start_datetime, count):
        print(start_datetime, count)
        request = {'operation': 'data', 'symbol': symbol,
                   'timeframe': timeframe,
                   'start_datetime': str(start_datetime),
                   'count': str(count)}

        data = self._send_and_receive(json.dumps(request))
        data_dict = json.loads(str(data))
        return data_dict

    def buy_order(self, symbol, stop_loss, take_profit, volume):
        request = {'operation': 'trade', 'symbol': symbol,
                   'stop_loss': stop_loss, 'take_profit': take_profit,
                   'type': 'buy', 'volume': volume}
        return self._send_and_receive(json.dumps(request))
