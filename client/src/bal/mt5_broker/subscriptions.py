import logging as log


class Subscriptions():
    def __init__(self):
        self._subscriber_dict = {}

    def add_subscription(self, symbol, callback, timeframe_events):
        if symbol in self._subscriber_dict.keys():
            log.warning(
                'Symbol already has a callback. Replacing the first one')
        self._subscriber_dict[symbol] = {
            'callback': callback, 'timeframe_events': timeframe_events}

    def notify_subscribers(self, subscription_data):
        rec_symbol = subscription_data['symbol']
        self._subscriber_dict[rec_symbol]['callback'](
            (subscription_data['time'], subscription_data['price']))
