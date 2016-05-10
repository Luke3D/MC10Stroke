import queue
import time
import math

# Used for BioStampRCCallInApp decorator
callback_queue = queue.Queue()


class BioStampRCCallInApp(object):
    '''The Tk GUI does not support multithreading: calls to Tk must originate from 
    the main thread only or unpredictable behavior will occur. In order to allow
    callbacks from other threads to access the GUI, the function decorator
    BioStampRCCallInApp is provided. It returns a function that puts the original
    function call in a queue to be called by the main thread.
    '''
    def __init__(self, f):
        self.f = f
        
    def __call__(self, *args, **kwargs):
        callback_queue.put(lambda: self.f(*args, **kwargs))

# Retry decorator with exponential backoff
# From https://wiki.python.org/moin/PythonDecoratorLibrary
def retry(tries, delay=3, backoff=2):
    '''Retries a function or method until it returns True.
       delay sets the initial delay in seconds, and backoff sets the factor by which
       the delay should lengthen after each failure. backoff must be greater than 1,
       or else it isn't really a backoff. tries must be at least 0, and delay
       greater than 0.'''

    if backoff < 1:
        raise ValueError("backoff must be >= 1")
    tries = math.floor(tries)
    if tries < 0:
        raise ValueError("tries must be 0 or greater")
    if delay < 0:
        raise ValueError("delay must be >= 0")

    def deco_retry(f):
        def f_retry(*args, **kwargs):
            mtries, mdelay = tries, delay  # make mutable
            rv = f(*args, **kwargs)  # first attempt
            while mtries > 0:
                if rv is True:  # Done on success
                    return True
            mtries -= 1  # consume an attempt
            time.sleep(mdelay)  # wait...
            mdelay *= backoff  # make future wait longer
            rv = f(*args, **kwargs)  # Try again
            return False  # Ran out of tries :-(
        return f_retry  # true decorator -> decorated function
    return deco_retry  # @retry(arg[, ...]) -> true decorator
