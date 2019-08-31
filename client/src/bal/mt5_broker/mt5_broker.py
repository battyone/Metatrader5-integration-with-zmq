from bal.broker import Broker
from bal.mt5_broker.mt5_zmq_communication import MT5ZMQCommunication


class Metatrader5Broker(Broker):
    def __init__(self, **kwargs):
        self._communication = MT5ZMQCommunication(**kwargs)

    def subscribe_to_symbol(self, symbol, callback):
        return self._communication.request_to_subscribe(
            symbol, callback)

    def request_data(self, symbol, from_ms, count, timeframe_minutes):
        return self._communication.request_data(
            symbol, from_ms, count, timeframe_minutes)

    def buy(self, symbol, **trade_args):
        return self._communication.open_trade('buy', symbol, **trade_args)

    def sell(self, symbol, **trade_args):
        return self._communication.open_trade('sell', symbol, **trade_args)

    def close_trade(self, symbol):
        return self._communication.close_trade(symbol)

    def cancel_subscription(self, symbol):
        self._communication.cancel_subscription(symbol)
