from zmq_client import ZMQClient
z = ZMQClient()
z.get_data('IBOV', '1440', 0, 100)
