import zmq
import json
c = zmq.Context()
s = c.socket(zmq.REQ)
s.connect('tcp://localhost:5555')


def _request_reply_from_server(cmd_dict):
    s.send_string(json.dumps(cmd_dict))
    return s.recv_string()


# cmd = {'operation': 'subscribe', 'symbol': 'BBAS3', 'timeframe_minutes': '0'}
# print(_request_reply_from_server(cmd))

# cmd = {'operation': 'data','symbol': 'WINZ19','from_ms': '1570147200000', 'count': '100000'}
cmd = {'operation': 'data','symbol': 'WINZ19','from_ms': '1570387800000', 'to_ms': '1570507317000'}
response = _request_reply_from_server(cmd)
print(response)

