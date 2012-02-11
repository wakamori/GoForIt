#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import random
import sys

class DayLife:
    """Life in a day."""

    def __init__(self, date, life):
        """Set birth datetime and life."""
        self.birthdate = date
        self.life = life
        finalyear = self.birthdate.year + self.life
        finaldate = datetime.datetime(finalyear, self.birthdate.month,
                                      self.birthdate.day)
        self.finaldate = finaldate - datetime.timedelta(days=1)

    def now(self):
        """Calculate current time."""
        curdate = datetime.datetime.now()
        maxdays = (self.finaldate - self.birthdate).days
        curdays = (curdate - self.birthdate).days
        curtime = datetime.timedelta(days=1) / maxdays
        curtime = curtime * curdays
        return datetime.time(
                   (curtime.seconds / 60) / 60,
                   (curtime.seconds / 60) % 60,
                   curtime.seconds % 60)

if __name__ == '__main__':
    # options
    startyear = 1900
    endyear = 2000
    life = 200
    print startyear, "<= a <=", endyear
    print "n =", life
    daycount = (datetime.datetime(endyear, 12, 31) -
                   datetime.datetime(startyear, 1, 1)).days
    birthdate = datetime.datetime(startyear, 1, 1) + \
                    datetime.timedelta(days=random.randint(0, daycount))
    args = sys.argv
    if len(args) == 4:
        year = int(args[1])
        month = int(args[2])
        date = int(args[3])
        birthdate = datetime.datetime(year, month, date)
    print "birthdate:", birthdate.date()
    mylife = DayLife(birthdate, life)
    print "finaldate:", mylife.finaldate.date()
    print "today:", mylife.now()
