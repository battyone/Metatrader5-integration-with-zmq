import logging as log
from multiprocessing import Lock
from multiprocessing import Event
from multiprocessing import Process
from bal.callback_utils import ThreadPoolWithError

import time


class Subscriptions():
    def __init__(self):
        self._subscriber_dict = {}
        self._subscribers_lock = Lock()
        self._stream_lock = Lock()

    def _gather_subscriptions(self, server_closed, oanda_client, data_stream):
        _thread_pool = ThreadPoolWithError()
        while not server_closed.is_set():
            with self._stream_lock:
                try:
                    for req_result in self._oanda_client.request(data_stream):
                        MINIMM_DELAY_BETWEEN_TICKS = 0.1
                        time.sleep(MINIMM_DELAY_BETWEEN_TICKS)
                        log.debug('Received publication. \n%s.' % req_result)
                        if req_result['type'] == 'PRICE':
                            _thread_pool.apply_async(
                                self._notify_subscribers,
                                args=(req_result,)
                            )
                except Exception as e:
                    log.error(e)

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

    def setup_comunication(self, account_id, oanda_client):
        self._account_id = account_id
        self._oanda_client = oanda_client
        with self._stream_lock:
            self._stream = PricingStream(accountID=self._account_id,
                                         params={'instruments': ''})
        self._server_closed = Event()
        process = Process(target=self._gather_subscriptions,
                          args=(self._server_closed,
                                self._oanda_client,
                                self._stream),
                          daemon=True)
        process.start()

    def close_server(self):
        self._server_closed.set()
