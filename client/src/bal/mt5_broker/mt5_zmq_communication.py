import zmq
import json
import logging as log

from bal.mt5_broker.subscriptions import Subscriptions
from bal.broker import BrokerType


class MT5ZMQCommunication:
    def __init__(self, **kwargs):
        self._server_hostname = kwargs.get(
            'server_hostname', 'tcp://localhost')
        self._request_port = kwargs.get('request_port', 5555)
        self._subscribe_port = kwargs.get('subscribe_port', 5556)
        _context = zmq.Context()
        self._socket_sub = _context.socket(zmq.SUB)
        self._socket_req = _context.socket(zmq.REQ)

        self._setup_comunication()
        self._subscriptions = Subscriptions(
            BrokerType.MQL5, self._request_port, self._subscribe_port)

    def _setup_request_client(self):
        self._socket_req.connect('%s:%s' % (
            self._server_hostname, self._request_port))

    def _setup_subscribe_client(self):
        self._socket_sub.connect('%s:%s' % (
            self._server_hostname, self._subscribe_port))
        self._socket_sub.setsockopt(zmq.SUBSCRIBE, b'')

    def _request_reply_from_server(self, cmd_dict):
        self._socket_req.send_string(json.dumps(cmd_dict))
        return self._socket_req.recv_json()

    def open_trade(self, trade_type, symbol, **trade_args):
        cmd_dict = {'operation': 'trade', 'action': 'open', 'type': trade_type,
                    'symbol': str(symbol),
                    'stop_loss': trade_args['stop_loss'],
                    'take_profit': trade_args['take_profit'],
                    'volume': trade_args['volume']}
        self._request_reply_from_server(cmd_dict)

    def _connect(self):
        self._setup_subscribe_client()
        self._setup_request_client()

    def request_data(self, symbol, start_datetime, n_bars, timeframe_minutes):
        '''
        example:
                                                                                       yyyy.mm.dd [hh:mi:ss]
            {'operation': 'data','symbol': 'BOVA11', 'timeframe': 1,'start_datetime': "2019.03.04 [10:00:00]",'n_bars': 100}
        '''
        request_data_cmd_dict = {'operation': 'data',
                                 'symbol': str(symbol),
                                 'timeframe': str(timeframe_minutes),
                                 'start_datetime': str(start_datetime),
                                 'count': str(n_bars)}
        return self._request_reply_from_server(request_data_cmd_dict)

    def request_to_subscribe(self, symbol, timeframe_events, callback):
        subscribe_cmd_dict = {'operation': 'subscribe',
                              'symbol': str(symbol),
                              'timeframe_events': str(timeframe_events)}

        reply = self._request_reply_from_server(subscribe_cmd_dict)
        if int(reply.get('code', -1)) >= 0:
            self._subscriptions.add_subscription(
                symbol, callback, timeframe_events)

    def cancel_subscription(self, symbol):
        self._subscriptions.remove_subscription(symbol)

    def close_trade(self, symbol):
        cmd_dict = {'operation': 'trade',
                    'action': 'close', 'symbol': str(symbol)}
        self._request_reply_from_server(cmd_dict)

    def _setup_comunication(self):
        self._connect()
        self._subscriptions.setup_comunication()
