from bal.broker import Broker
import logging as log
import json
import zmq


class Metatrader5Broker(Broker):
    def __init__(self, **kwargs):
        self._server_hostname = kwargs.get(
            'server_hostname', 'tcp://localhost')
        self._request_port = kwargs.get('request_port', 5555)
        self._subscribe_port = kwargs.get('subscribe_port', 5556)

        _context = zmq.Context()
        self._socket_req = _context.socket(zmq.REQ)
        self._socket_sub = _context.socket(zmq.SUB)
        self._ticks_callbacks = {}

    def _request_reply_from_server(self, cmd_dict):
        self._socket_req.send_string(json.dumps(cmd_dict))
        return self._socket_req.recv_json()

    def _setup_request_client(self):
        self._socket_req.connect(
            self._server_hostname + ':' + self._request_port)

    def _setup_subscribe_client(self):
        self._socket_sub.connect(
            self._server_hostname + ':' + self._subscribe_port)

    def _open_trade(self, trade_type, symbol, **trade_args):
        cmd_dict = {
            'operation': 'trade', 'action': 'open', 'type': trade_type,
            'symbol': str(symbol),
            'stop_loss': trade_args['stop_loss'],
            'take_profit': trade_args['take_profit'],
            'volume': trade_args['volume']}
        self._request_reply_from_server(cmd_dict)

    def connect(self):
        self._setup_request_clien()
        self._setup_subscribe_clien()

    def subscribe_to_symbol(self, symbol, timeframe_events, callback):
        if symbol in self._ticks_callbacks.keys():
            log.warning('Symbol already has callback. Replacing the first one')

        subscribe_cmd_dict = {'operation': 'subscribe',
                              'symbol': str(symbol),
                              'timeframe_events': str(timeframe_events)}
        reply = self._request_reply_from_server(subscribe_cmd_dict)
        if int(reply.get('code', -1)) > 0:
            self._ticks_callbacks[symbol] = callback

    def request_data(self, symbol, start_datetime, count, timeframe):
        request_data_cmd_dict = {'operation': 'data',
                                 'symbol': str(symbol),
                                 'timeframe': str(timeframe),
                                 'start_datetime': str(start_datetime),
                                 'count': str(count)}
        return self._request_reply_from_server(request_data_cmd_dict)

    def buy(self, symbol, **trade_args):
        self._do_trade('buy', symbol, **trade_args)

    def sell(self, symbol, **trade_args):
        self._do_trade('sell', symbol, **trade_args)

    def close_trade(self, symbol):
        cmd_dict = {
            'operation': 'trade', 'action': 'close',
            'symbol': str(symbol)}
        self._request_reply_from_server(cmd_dict)
