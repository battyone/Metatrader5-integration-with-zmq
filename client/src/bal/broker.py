from enum import Enum
import logging as log
from abc import ABC, abstractmethod


BrokerType = Enum('BrokerType', ['MOCK', 'MQL5', 'OANDA'])


def create(broker_type, **kwargs):
    log.basicConfig(level=kwargs.get('loglevel', log.DEBUG))
    log.getLogger('parso.python.diff').disabled = True

    if broker_type == BrokerType.OANDA:
        from bal.oanda.oanda import OandaBroker
        return OandaBroker(**kwargs)
    elif broker_type == BrokerType.MQL5:
        from bal.mt5_broker.mt5_broker import Metatrader5Broker
        return Metatrader5Broker(**kwargs)
    else:
        raise NotImplementedError


class Broker(ABC):
    @abstractmethod
    def buy(self, type, symbol, **trade_args):
        return {}

    @abstractmethod
    def sell(self, type, symbol, **trade_args):
        return {}

    @abstractmethod
    def close_trade(self, type, symbol, **trade_args):
        return False

    @abstractmethod
    def request_data(self, symbol, start_datetime, count, timeframe):
        return {}

    @abstractmethod
    def subscribe_to_symbol(self, symbol, timeframe_events, callback):
        return False

    @abstractmethod
    def cancel_subscription(self, symbol):
        return false
