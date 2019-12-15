import logging as log
from multiprocessing import RLock
from multiprocessing import Event
from bal.callback_utils import ThreadPoolWithError
from collections import namedtuple
from threading import Thread

import time


SubscriptionData = namedtuple('SubscriptionData',
                              ["symbol", "time", "bid", "ask", "last", "real_volume", "flags"])


class Subscriptions():
    def __init__(self, subscriber_type, server_hostname, request_port=5555, **kwargs):
        self._subscriber_dict = {}
        self._data_streamer = self._create_data_streamer(
            subscriber_type, server_hostname, request_port, **kwargs)
        self._subscribers_lock = RLock()
        self._server_closed = Event()
        self._setup_comunication()


    def _gather_subscriptions(self, server_closed):
        # _thread_pool = ThreadPoolWithError()
        while not server_closed.is_set():
            try:
                data = self._data_streamer.request_data()
                self._notify_subscribers(data)
                # _thread_pool.apply_async(
                #     self._notify_subscribers,
                #     args=(data,)
                # )
            except Exception as e:
                log.exception(e)

    def add_subscription(self, symbol, callback):
        with self._subscribers_lock:
            if symbol in self._subscriber_dict:
                log.warning(
                    'Symbol already has a callback. Replacing the first one')
            else: self._data_streamer.add_subscription()
            self._subscriber_dict[symbol] = callback

    def remove_subscription(self, symbol):
        with self._subscribers_lock:
            self._subscriber_dict.pop(symbol, None)

    def _notify_subscribers(self, subscription_data):
        with self._subscribers_lock:
            self._subscriber_dict[subscription_data.symbol](subscription_data)

    def _setup_comunication(self):
        thread = Thread(target=self._gather_subscriptions,
                         args=(self._server_closed,),
                         daemon=True)
        thread.start()

    def close_server(self):
        self._server_closed.set()

    def _create_data_streamer(self, subscriber_type, server_hostname, request_port, **kwargs):
        from bal.broker import BrokerType
        if subscriber_type == BrokerType.MQL5:
            from bal.mt5_broker.mql5_data_streammer import MQL5DataStreammer
            return MQL5DataStreammer(server_hostname, request_port)
        elif subscriber_type == BrokerType.OANDA:
            from bal.oanda.oanda_streamer import OANDADataStreammer
            return OANDADataStreammer(**kwargs)
        else:
            raise NotImplementedError
