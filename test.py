import bal
from datetime import datetime
import pytz
tz = pytz.timezone('Brazil/East')
b = bal.create(bal.BrokerType.MQL5)
# year_month_day = [2019, 11, 11]
year_month_day = [2019, 11, 1]

from_datetime=datetime(*year_month_day, tzinfo=tz)

to_datetime=datetime(*year_month_day[:2], year_month_day[2] + 1, tzinfo=tz)
data = b.request_data("WINZ19", from_datetime, to_datetime)
# import zmq
# import json
# c = zmq.Context()
# s_rep_req = c.socket(zmq.REQ)
# s_rep_req.connect('tcp://localhost:5555')


# def _request_reply_from_server(cmd_dict):
#     s_rep_req.send_string(json.dumps(cmd_dict))
#     return s_rep_req.recv_string()

# cmd = {'operation': 'data','symbol': 'WINZ19','from_ms': '1570147200000', 'count': '100000'}
# cmd = {'operation': 'data', 'symbol': 'WINZ19', 'from_ms': '1570387800000', 'to_ms': '1570507317000'}
# response = _request_reply_from_server(cmd)
# print(response)
