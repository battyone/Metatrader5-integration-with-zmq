# from zmq_client import ZMQClient
# import logging as log
# z = ZMQClient(5555, 'localhost', 'tcp')
# z.get_data('IBOV', '1440', 0, 100)
import zmq;
import json;
import time

context = zmq.Context();
socket = context.socket(zmq.REQ);
socket.connect('tcp://localhost:5555');
request = {'operation': 'data', 'symbol': 'IBOV',
           'timeframe': '1440',
           'start_datetime': '0',
           'count': '100'};
socket.send_string(json.dumps(request));
time.sleep(2)
reply = socket.recv();
