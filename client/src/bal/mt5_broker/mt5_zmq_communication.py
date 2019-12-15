import zmq
import json
import pandas as pd
import logging as log

from io import StringIO
from bal.broker import BrokerType
from bal.subscriptions import Subscriptions


class MT5ZMQCommunication:
    def __init__(self, server_hostname='tcp://localhost', request_port=5555):
        self._server_hostname = server_hostname
        self._request_port = request_port
        self._subscribe_port = subscribe_port
        self._socket_req = zmq.Context().socket(zmq.REQ)
        self._setup_request_client()
        self._subscriptions = Subscriptions(
            BrokerType.MQL5, server_hostname, request_port)

    def _setup_request_client(self):
        self._socket_req.connect('%s:%s' % (
            self._server_hostname, self._request_port))

    def _request_reply_from_server(self, cmd_dict):
        self._socket_req.send_string(json.dumps(cmd_dict))
        return self._socket_req.recv_string()

    def open_trade(self, trade_type, symbol, stop_loss, take_profit, volume):
        cmd_dict = {'operation': 'trade', 'action': 'open', 'type': trade_type,
                    'symbol': str(symbol),
                    'stop_loss': stop_loss,
                    'take_profit': take_profit,
                    'volume': volume}
        self._request_reply_from_server(cmd_dict)

    def request_data(self, symbol, from_datetime, to_datetime):
        cmd = {
            'operation': 'data',
            'symbol': symbol,
            'from_ms': str(int(from_datetime.timestamp() * 1000)),
            'to_ms': str(int(to_datetime.timestamp() * 1000))
        }
        data = pd.read_csv(StringIO(self._request_reply_from_server(cmd)))
        data['datetime'] = pd.to_datetime(data['time'], unit='ms')

        return data.set_index('datetime')

    def request_to_subscribe(self, symbol, callback):
        subscribe_cmd_dict = {'operation': 'subscribe',
                              'symbol': str(symbol)}

        reply = self._request_reply_from_server(subscribe_cmd_dict)
        if int(json.loads(reply).get('code', -1)) >= 0:
            self._subscriptions.add_subscription(symbol, callback)

    def cancel_subscription(self, symbol):
        self._subscriptions.remove_subscription(symbol)

    def close_all_orders(self, symbol):
        cmd_dict = {'operation': 'trade',
                    'action': 'close', 'symbol': str(symbol)}
        self._request_reply_from_server(cmd_dict)
