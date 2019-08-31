import zmq
import json
c = zmq.Context()
s = c.socket(zmq.REQ)
s.connect('tcp://localhost:5555')


def _request_reply_from_server(cmd_dict):
    s.send_string(json.dumps(cmd_dict))
    return s.recv_json()


cmd = {'operation': 'subscribe', 'symbol': 'BBAS3', 'timeframe_minutes': '0'}
print(_request_reply_from_server(cmd))

cmd = {'operation': 'data','symbol': 'BOVA11','from_ms': '1', 'count': '100'}
response = _request_reply_from_server(cmd)
print(response)
