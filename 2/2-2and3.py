#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
2-2and3.py
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

import math
import random
import sys

def fact(n):
    if n <= 1:
        return 1
    else:
        return n * fact(n - 1)

def term(n):
    return 1 / n - math.log((n + 1) / n)

def limit(f, g, s, diff=1e-10):
    r = 0
    i = s
    while True:
        d = f(float(i))
        if d < diff:
            return r
        else:
            r = g(r, d)
            i += 1

def sigma(f, s):
    return limit(f, lambda x, y: x + y, s)

def product(f, s):
    return limit(f, lambda x, y: x * y, s, 1e-5)

def euler():
    return sigma(lambda n: 1 / n - math.log((n + 1) / n), 1)

def napier():
    return sigma(lambda n: 1 / fact(n), 0)

# Napier's constant
E = napier()

# Euler's constant
GAMMA = euler()

def f(x, m):
    return (1 + x / m) * (E ** (-x / m))

def rfact(x):
    return 1 / ((x + 1) * (E ** (GAMMA * (x + 1))) * \
            product(lambda m: (1 + (x + 1) / m) * (E ** (-x / m)), 1))

if __name__ == '__main__':
    a = random.uniform(0, 10)
    args = sys.argv
    if len(args) == 2:
        a = float(args[1])
    print "a:", a
    print "rfact(a):", rfact(a)
