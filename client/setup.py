from setuptools import setup
import setuptools

PACKAGE = 'bpi'
version = '0.1'

setup(
    name=PACKAGE,
    version=version,
    author='Leoni Mota Loris',
    packages=setuptools.find_packages(),
    package_dir={"": "src"},
    description='This Library allows communication between '
    'currency brokers and python.',
    zip_safe=False,
    url='https://github.com/leoniloris/zmq_metatrader5')
