import logging as log
from multiprocessing import RLock
from multiprocessing import Event
from bal.callback_utils import ThreadPoolWithError
from collections import namedtuple
# from multiprocessing import Process
from threading import Thread

import time

SubscriptionData = namedtuple('SubscriptionData',
                              ["symbol", "time", "bid", "ask", "last", "real_volume", "flags"])


class Subscriptions():
    def __init__(self, subscriber_type, server_hostname, request_port=5555, **kwargs):
        self._subscriber_dict = {}
        self._server_closed = Event()
        self._data_streamer = self._create_data_streamer(
            subscriber_type, server_hostname, request_port, self._server_closed, **kwargs)
        self._subscribers_lock = RLock()
        self._setup_comunication()

    def _gather_subscriptions(self):
        _thread_pool = ThreadPoolWithError()
        while not self._server_closed.is_set():
            data = self._data_streamer.request_data()
            # self._notify_subscribers(data)
            _thread_pool.apply_async(
                self._notify_subscribers,
                args=(data,)
            )

    def add_subscription(self, symbol, callback):
        with self._subscribers_lock:
            if symbol in self._subscriber_dict:
                log.warning(
                    'Symbol already has a callback. Replacing the first one')
            else: self._data_streamer.add_subscription(symbol)
            self._subscriber_dict[symbol] = callback

    def remove_subscription(self, symbol):
        with self._subscribers_lock:
            self._subscriber_dict.pop(symbol, None)

    def _notify_subscribers(self, subscription_data):
        with self._subscribers_lock:
            self._subscriber_dict[subscription_data.symbol](subscription_data)

    def _setup_comunication(self):
        Thread(target=self._gather_subscriptions,
               daemon=True).start()

    def close_server(self):
        self._server_closed.set()

    def _create_data_streamer(self, subscriber_type, server_hostname, request_port, server_closed, **kwargs):
        from bal.broker import BrokerType
        if subscriber_type == BrokerType.MQL5:
            from bal.mt5_broker.mql5_data_streammer import MQL5DataStreammer
            return MQL5DataStreammer(server_hostname, request_port, server_closed)
        elif subscriber_type == BrokerType.OANDA:
            from bal.oanda.oanda_streamer import OANDADataStreammer
            return OANDADataStreammer(**kwargs)
        else:
            raise NotImplementedError
