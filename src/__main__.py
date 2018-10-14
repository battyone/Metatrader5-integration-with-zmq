import asyncio
import argparse
from zmq_client import ZMQClient


loop = asyncio.get_event_loop()


def parse_args():
    parser = argparse.ArgumentParser(description='Trade daemon')
    parser.add_argument(
        '--symbol',
        default='BTCUSD',
        help='Stock symbol to trade'
    )

    parser.add_argument(
        '--timeframe',
        default='H1',
        help='Time frame granularity')
    return parser.parse_args()


async def run_daemon(args, client):
    MONITOR_PERIOD_S = 1
    while True:
        # symbol, timeframe, start_datetime, end_datetime
        client.get_data(args.symbol, args.timeframe, 0, 2000)
        await asyncio.sleep(MONITOR_PERIOD_S)


def main():
    args = parse_args()
    loop = asyncio.get_event_loop()

    zmq_mql5_client = ZMQClient()
    tasks = [asyncio.ensure_future(
        run_daemon(args, zmq_mql5_client), loop=loop)]
    loop.run_until_complete(asyncio.gather(*tasks))
