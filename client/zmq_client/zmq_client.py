import zmq
import json
import logging as log


class ZMQClient():
    def __init__(self, port, host, protocol):
        self.context = zmq.Context()
        self.req_socket = self.context.socket(zmq.REQ)
        self.req_socket.connect('%s://%s:%s' % (protocol, host, port))

        self.pull_socket = self.context.socket(zmq.PULL)
        self.pull_socket.connect('%s://%s:%s' % (protocol, host, port + 1))

    def _push_to_server(self, socket, data):
        socket.send_string(data)
        msg_send = socket.recv_string()
        log.info('Sent %s' % msg_send)

    def _pull_from_server(self, socket):
        msg_pull = socket.recv()
        log.info(msg_pull)
        return msg_pull

    def _send_and_receive(self, data):
        self._push_to_server(self.req_socket, data)
        return self._pull_from_server(self.pull_socket)

    def get_data(self, symbol, timeframe, start_datetime, count):
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
