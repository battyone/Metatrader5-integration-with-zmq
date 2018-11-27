from setuptools import setup, find_packages

PACKAGE = 'bal'
version = '0.1'

setup(
    name=PACKAGE,
    version=version,
    author='Leoni Mota Loris',
    packages=find_packages(where='src'),
    package_dir={"": "src"},
    description='This is a Broker abstraction layer. It allows '
    'communication between currency brokers and python.',
    zip_safe=False,
    url='https://github.com/leoniloris/zmq_metatrader5')
