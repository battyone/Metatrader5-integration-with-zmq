from bal.subscriptions import Subscriptions
from bal.broker import Broker, BrokerType
import logging as log
import oandapyV20
import json


class OandaBroker(Broker):
    def __init__(self, **kwargs):
        user_token_path = kwargs.get('token', './oanda.conf')
        self._orders_ids = {}
        self._api_token, self._account_id = open(
            user_token_path).read().split(',')
        self._client = oandapyV20.API(access_token=self._api_token)
        self._subscriptions = Subscriptions(
            BrokerType.OANDA, self._client, self._account_id)

    def _extract_order_id(self, order_info):
        if 'orderOpened' in order_info.keys():
            return order_info['orderOpened']['id']
        elif 'tradeOpened' in order_info.keys():
            return order_info['tradeOpened']['id']
        else:
            raise NotImplementedError

    def _open_order(self, *, symbol, volume, stop_loss=None, take_profit=None):
        import oandapyV20.endpoints.orders as orders
        order_params = {
            'order': {
                'units': int(volume),
                'instrument': symbol,
                'positionFill': 'DEFAULT',
                'type': 'MARKET',
            }
        }
        if stop_loss:
            order_params['order']['stopLossOnFill'] = {
                'timeInForce': 'GTC',
                'price': float(stop_loss)
            }
            order_params['order']['type'] = 'LIMIT'
        if take_profit:
            order_params['order']['takeProfitOnFill'] = {
                'price': float(take_profit)
            }
            order_params['order']['type'] = 'LIMIT'

        try:
            req = orders.OrderCreate(
                accountID=self._account_id, data=order_params)
            response = self._client.request(req)
            self._orders_ids[symbol] = int(
                response['orderCreateTransaction']['id'])
        except Exception as e:
            log.error('%s' % e)
            return None
        else:
            log.debug('Response: %s\n%s' %
                      (req.status_code, json.dumps(response, indent=2)))
            return response

    def request_data(self, symbol, start_datetime, count, timeframe):
        import oandapyV20.endpoints.instruments as instruments
        params = {
            'count': int(count),
            'granularity': timeframe,
            'from': start_datetime
        }
        req = instruments.InstrumentsCandles(instrument=symbol,
                                             params=params)
        data = self._client.request(req)
        return data['candles']

    def subscribe_to_symbol(self, symbol, timeframe_events, callback):
        self._subscriptions.add_subscription(symbol, callback, timeframe_events)

    def buy(self, symbol, **trade_args):
        '''
        All arguments should be named:
            symbol, volume, (stop_loss), (take_profit)
        '''
        volume = abs(trade_args.get('volume'))
        return self._open_order(
            symbol=trade_args.get('symbol'),
            volume=volume,
            stop_loss=trade_args.get('stop_loss'),
            take_profit=trade_args.get('take_profit'),
        )

    def sell(self, symbol, **trade_args):
        '''
        All arguments should be named:
            symbol, volume, (stop_loss), (take_profit)
        '''
        volume = -1 * abs(trade_args.get('volume'))
        return self._open_order(
            symbol=trade_args.get('symbol'),
            volume=volume,
            stop_loss=trade_args.get('stop_loss'),
            take_profit=trade_args.get('take_profit'),
        )

    def close_trade(self, symbol):
        pass

    def cancel_subscription(self, symbol):
        pass
