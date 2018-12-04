import zmq
import json
import logging as log

from bal.mt5_broker.subscriptions import Subscriptions
from threading import Thread
from multiprocessing import Event


class MT5ZMQCommunication:
    def __init__(self, **kwargs):
        self._server_hostname = kwargs.get(
            'server_hostname', 'tcp://localhost')
        self._request_port = kwargs.get('request_port', 5555)
        self._subscribe_port = kwargs.get('subscribe_port', 5556)
        self._context = zmq.Context()
        self._socket_req = self._context.socket(zmq.REQ)
        self._socket_sub = self._context.socket(zmq.SUB)
        self._subscriptions = Subscriptions()
        self._setup_comunication()

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
        cmd_dict = {
            'operation': 'trade', 'action': 'open', 'type': trade_type,
            'symbol': str(symbol),
            'stop_loss': trade_args['stop_loss'],
            'take_profit': trade_args['take_profit'],
            'volume': trade_args['volume']}
        self._request_reply_from_server(cmd_dict)

    def _connect(self):
        self._setup_request_client()
        self._setup_subscribe_client()

    def request_active_data(self, symbol, start_datetime, count, timeframe):
        request_data_cmd_dict = {'operation': 'data',
                                 'symbol': str(symbol),
                                 'timeframe': str(timeframe),
                                 'start_datetime': str(start_datetime),
                                 'count': str(count)}
        return self._request_reply_from_server(request_data_cmd_dict)

    def request_to_subscribe(self, symbol, timeframe_events, callback):
        subscribe_cmd_dict = {'operation': 'subscribe',
                              'symbol': str(symbol),
                              'timeframe_events': str(timeframe_events)}

        reply = self._request_reply_from_server(subscribe_cmd_dict)
        if int(reply.get('code', -1)) >= 0:
            self._subscriptions.add_subscription(
                symbol, callback, timeframe_events)

    def close_trade(self, symbol):
        cmd_dict = {'operation': 'trade',
                    'action': 'close', 'symbol': str(symbol)}
        self._request_reply_from_server(cmd_dict)

    def _gather_subscriptions(self, server_closed):
        while not server_closed.is_set():
            log.info('Setting up the subscriber client')
            published_data = self._socket_sub.recv_json()
            log.info('Received publication.')

            try:
                self._subscriptions.notify_subscribers(published_data)
            except KeyError as e:
                log.warning('Either received tick from a not subscribed'
                            'symbol or the received data is wrong.'
                            'Err: %s, Data: %s' % (e, published_data))

    def _setup_comunication(self):
        self._server_closed = Event()
        self._connect()
        thread = Thread(
            target=self._gather_subscriptions,
            args=(self._server_closed,),
            daemon=True)
        thread.start()

        # self._incoming_messages_queue = Queue()
        # self._outgoing_messages_queue = Queue()
        # process = Process(
        #     target=serial_worker,
        #     args=(self._incoming_bytes_queue, self._outgoing_bytes_queue,
        #           self._worker_ready, self._hardware_closed,
        #           self._serial_opened, serial_port, self._handshake_func),
        #     daemon=True)
        #     process.start()
        #     self._worker_ready.wait()
        #     if self._serial_opened.is_set():
        #         return

        # read_task = Thread(
        #     target=_read_task,
        #     args=(self._incoming_messages_queue, self._server_closed),
        #     daemon=True)

        # write_task = Thread(
        #     target=_write_task,
        #     args=(self._outgoing_messages_queue, self._server_closed),
        #     daemon=True)
