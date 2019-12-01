from bal.broker import Broker
from bal.mt5_broker.mt5_zmq_communication import MT5ZMQCommunication


class Metatrader5Broker(Broker):
    def __init__(self, **kwargs):
        self._communication = MT5ZMQCommunication(**kwargs)

    def subscribe_to_symbol(self, symbol, callback):
        return self._communication.request_to_subscribe(
            symbol, callback)

    def request_data(self, symbol, from_datetime, to_datetime):
        return self._communication.request_data(symbol, from_datetime, to_datetime)

    def buy(self, trade_type, symbol, stop_loss, take_profit, volume):
        return self._communication.open_trade('buy', self, trade_type, symbol, stop_loss, take_profit, volume)

    def sell(self, trade_type, symbol, stop_loss, take_profit, volume):
        return self._communication.open_trade('sell', self, trade_type, symbol, stop_loss, take_profit, volume)

    def close_all_orders(self, symbol):
        return self._communication.close_all_orders(symbol)

    def cancel_subscription(self, symbol):
        self._communication.cancel_subscription(symbol)
