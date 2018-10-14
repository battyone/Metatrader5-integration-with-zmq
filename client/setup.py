from setuptools import setup
import setuptools

PACKAGE = 'zmq_client'
version = '0.1'

setup(
    name=PACKAGE,
    version=version,
    author='Leoni Mota Loris',
    description='This Library allows communication between '
    'Metatrader 5 and python.',
    packages=setuptools.find_packages(),
    zip_safe=False,
    url='https://github.com/leoniloris/zmq_metatrader5')
