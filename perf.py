import dis

def f(b):
    a = []
    if b is not None:
        a = [i for i in b if i%2==0]

    return a

def f2(b):
    if b is not None:
        a = [i for i in b if i%2==0]
    else:
        a = []

    return a


import random
g = []
for _ in range(1000000):
    if random.random() < 0.5:
        g.append(None)
    else:
        g.append(list(range(random.randint(3, 10))))


import time

t = time.time()
for i in g:
    f2(i)
print(time.time() - t)


t = time.time()
for i in g:
    f(i)
print(time.time() - t)