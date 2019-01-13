from oandapyV20.endpoints.pricing import PricingStream
import logging as log


class OANDADataStreammer:
    def __init__(self, client, account_id):
        self._client = client
        self._account_id = account_id
        self._stream = PricingStream(accountID=self._account_id,
                                     params={'instruments': ''})

    def request_dict_data(self):
        got_price = False
        while not got_price:
            req_result = next(self._client.request(self._stream))
            log.debug('Received publication. \n%s.' % req_result)
            got_price = req_result['type'] == 'PRICE'

        return {'bid': req_result['closeoutBid'],
                'ask': req_result['closeoutAsk'],
                'timestamp': req_result['time']}
