import os
import socket

from redis import Redis

redis = Redis(
    host=os.getenv('REDIS_HOST', 'redis-database'),
    port=int(os.getenv('REDIS_PORT', 6379)),
)

def increment():
    return 'I have been seen {t} times. My Hostname is: {h}\n'.format(
        t=redis.incr('hits'), h=socket.gethostname()
    )
hvhjbhs
