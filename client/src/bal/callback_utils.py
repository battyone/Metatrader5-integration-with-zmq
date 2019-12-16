from traceback import print_exception
from collections import namedtuple
from threading import Thread
from queue import Queue
import sys

_Task = namedtuple('Task', ['callable', 'args', 'kwargs'])


class Worker(Thread):
    def __init__(self, tasks):
        Thread.__init__(self)
        self.tasks = tasks
        self.daemon = True
        self.start()

    def run(self):
        while True:
            _task = self.tasks.get()
            try:
                _task.callable(*_task.args, **_task.kwargs)
            except Exception:
                exception_info = sys.exc_info()
                print_exception(*exception_info)
            finally:
                self.tasks.task_done()


class ThreadPoolWithError:
    def __init__(self, n_threads=5):
        self.tasks = Queue()
        [Worker(self.tasks) for _ in range(n_threads)]

    def apply_async(self, callable, args=(), kwargs={}):
        self.tasks.put(_Task(callable=callable, args=args, kwargs=kwargs))

    def join(self):
        self.tasks.join()


class Notifier:
    def __init__(self):
        self._sequential_pool = ThreadPoolWithError(n_threads=1)

    def notify(self, callable, *args):
        self._sequential_pool.apply_async(callable, args=args)
