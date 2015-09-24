#! /usr/bin/env python  
#coding=utf-8  

import numpy as np
from itertools import imap

x = []
for line in open("temp_monMaskedfldmean_text",'r'):
  x.append(float(line))


def average(x):
  assert len(x) > 0
  return float(sum(x)) / len(x)

def pearson_def(x, y):
  assert len(x) == len(y)
  n = len(x)
  assert n > 0
  avg_x = average(x)
  avg_y = average(y)
  diffprod = 0
  xdiff2 = 0
  ydiff2 = 0
  for idx in range(n):
    xdiff = x[idx] - avg_x
    ydiff = y[idx] - avg_y
    diffprod += xdiff * ydiff
    xdiff2 += xdiff * xdiff
    ydiff2 += ydiff * ydiff
  return diffprod / np.sqrt(xdiff2 * ydiff2)

result = pearson_def(x, y)
print result

