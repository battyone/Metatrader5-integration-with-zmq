import logging as log
from multiprocessing import RLock
from multiprocessing import Event
from multiprocessing import Process
from bal.callback_utils import ThreadPoolWithError

import time


class Subscriptions():
    def __init__(self, subscriber_type, **kwargs):
        self._subscriber_dict = {}
        self._data_streamer = self._create_data_streamer(
              subscriber_type, **kwargs)
        self._subscribers_lock = RLock()
        self._server_closed = Event()
        self._setup_comunication()

    def _gather_subscriptions(self, server_closed):
        _thread_pool = ThreadPoolWithError()
        while not server_closed.is_set():
            try:
                data = self._data_streamer.request_dict_data()
                _thread_pool.apply_async(
                    self._notify_subscribers,
                    args=(data,)
                )
                MINIMM_DELAY_BETWEEN_TICKS = 0.1
                time.sleep(MINIMM_DELAY_BETWEEN_TICKS)
            except Exception as e:
                log.exception(e)

    def add_subscription(self, symbol, callback, timeframe_events):
        with self._subscribers_lock:
            if symbol in self._subscriber_dict.keys():
                log.warning(
                    'Symbol already has a callback. Replacing the first one')
            self._subscriber_dict[symbol] = {
                'callback': callback, 'timeframe_events': timeframe_events}

    def remove_subscription(self, symbol):
        with self._subscribers_lock:
            self._subscriber_dict.pop(symbol, None)

    def _notify_subscribers(self, subscription_data):
        with self._subscribers_lock:
            rec_symbol = subscription_data['instrument']
            self._subscriber_dict[rec_symbol]['callback'](
                subscription_data['time'],
                subscription_data['closeoutBid'],
                subscription_data['closeoutAsk']
            )

    def _setup_comunication(self):
        process = Process(target=self._gather_subscriptions,
                          args=(self._server_closed,),
                          daemon=True)
        process.start()

    def close_server(self):
        self._server_closed.set()

    def _create_data_streamer(self, subscriber_type, **kwargs):
        from bal.broker import BrokerType
        if subscriber_type == BrokerType.MQL5:
            from bal.mt5_broker.mql5_data_streammer import MQL5DataStreammer
            return MQL5DataStreammer(kwargs['server_hostname'], kwargs['subscribe_port'])
        elif subscriber_type == BrokerType.OANDA:
            from bal.oanda.oanda_streamer import OANDADataStreammer
            return OANDADataStreammer(**kwargs)
        else:
            raise NotImplementedError
        self._setup_comunication()
