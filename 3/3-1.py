#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
3-1.py
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

import sys

# table size (ascii)
CSIZE = 256

# make displacement table
def make_qs_table(pattern, size):
    qs_table = [size + 1] * CSIZE
    for i in xrange(size):
        qs_table[ord(pattern[i])] = size - i
    return qs_table

# quick search
def qs_search(buff, column, skip_count, pattern):
    i = column
    n = 0
    while i < len(buff):
        n += 1
        i += skip_count
    m = len(pattern)
    qs_table = make_qs_table(pattern, m)
    i = 0
    while i < n - m:
        j = 0
        while j < m:
            if buff[column + (i + j) * skip_count] != pattern[j]:
                break
            j += 1
        if j == m:
            # found
            return i
        else:
            i += qs_table[ord(buff[column + (i + m) * skip_count])]
    j = column + i * skip_count
    last = ''
    while j < len(buff):
        last += buff[j]
        j += skip_count
    if last == pattern:
        return i
    return -1

def find(buff, word, skip_count):
    for column in xrange(skip_count):
        r = qs_search(buff, column, skip_count, word)
        if r >= 0:
            print str(skip_count) + ',' + str(r * skip_count + column + 1)
            return True
    return False

if __name__ == '__main__':
    args = sys.argv
    if len(args) != 2:
        print 'Usage: ' + args[0] + ' keyword'
        sys.exit(1)
    keyword = args[1]
    print 'keyword:', keyword
    rand_str = raw_input('search string: ')
    l = len(rand_str)
    print
    print "order:",
    for i in xrange(l):
        if find(rand_str, keyword, i + 1):
            break
    rkeyword = keyword[::-1]
    print "reverse order:",
    for i in xrange(l):
        if find(rand_str, rkeyword, i + 1):
            break
