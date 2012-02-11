#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
2-1.py
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

if __name__ == '__main__':
    a = random.randint(0, 10)
    args = sys.argv
    if len(args) == 2:
        a = int(args[1])
    print "a:", a
    print "fact(a):", fact(a)
