from enum import Enum


class BrokerType(Enum):
    MOCK = 'mock'
    MQL5 = 'mql5'


def create(broker_type, **kwargs):
    if broker_type == BrokerType.MOCK:
        pass
    elif broker_type == BrokerType.MQL5:
        from bal.metatrader5_broker import Metatrader5Broker
        return Metatrader5Broker(**kwargs)


class Broker:
    def init_client(self):
        raise NotImplementedError

    def buy(self, type, symbol, **trade_args):
        raise NotImplementedError

    def sell(self, type, symbol, **trade_args):
        raise NotImplementedError

    def close_trade(self, type, symbol, **trade_args):
        raise NotImplementedError

    def request_data(self, symbol, start_datetime, count, timeframe):
        raise NotImplementedError

    def subscribe_to_symbol(self, symbol, timeframe_events, callback):
        raise NotImplementedError
