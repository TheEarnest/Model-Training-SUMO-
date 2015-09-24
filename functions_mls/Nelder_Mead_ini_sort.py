#!/usr/bin/python
# -*- encoding: utf-8
# for presort the performance 
# argument inputs are necessary
# $1 -> number of the seq.
# $2 -> total number of the samppling base
# $3 -> file name of job parameters
# $4 -> file name of job performance


import os
import numpy as np
import sys
# --------------------------------------------------------------------  

# -------------------------------------------------------------------- 

if len(sys.argv) < 2:
  print "The job id and the number of parallel jobs are necessary!!!"
  sys.exit()

# --------------------------------------------------------------------
#  Define Job status
#
pid = int(sys.argv[1])-1  # id for parallel jobs
g_dim = int(sys.argv[2])
finname = sys.argv[3]
foutname = sys.argv[4]

# --------------------------------------------------------------------
#  Initialization
#
n_dim = 100;
#Jexpid = []
#JPerfs = np.zeros((0))
LJPerExp = []
# --------------------------------------------------------------------
#  Read performance
#
for line in open(foutname,'r'):
  temp = line.strip().split(' ')
  LJPerExp.append([temp[0], float(temp[1])])

if g_dim > len(LJPerExp) : 
  g_dim = len(LJPerExp)

# --------------------------------------------------------------------
#  Build initial array
#  STJexp: store only g_dim the sorted job expids
SdupJPE = sorted(LJPerExp, key = lambda x : x[1])
SortJP = []
for isor in range(len(SdupJPE)-1):
  if SdupJPE[isor][1] != SdupJPE[isor+1][1]:
    SortJP.append([SdupJPE[isor][0], SdupJPE[isor][1]])
SortJP.append([SdupJPE[-1][0], SdupJPE[-1][1]])
# --------------------------------------------------------------------
#  Read parameters
#
JexpidParas = []
JParasAll = np.zeros((0,0))
tempparas = np.zeros((0))
for line in open(finname,'r'):
  n_dimcheck = 0
  temp = line.strip().split(' ')
  JexpidParas.append(temp[0])
  tempparas = np.zeros((0,))
  for string in temp[1:] :
    if n_dimcheck < n_dim :
      if string != "done" :
        tempparas = np.append(tempparas, [float(string)],0)
        n_dimcheck += 1
  if n_dim == 100:
    n_dim = n_dimcheck
    JParasAll = np.zeros((0,n_dim))
#    print "The total is %d-D problem. \n " % n_dim
  JParasAll = np.append( JParasAll, [tempparas], 0)  

# --------------------------------------------------------------------
# 

print SortJP[pid][0], SortJP[pid][1], 
for idim in range(n_dim):
  print JParasAll[JexpidParas.index(SortJP[pid][0])][idim],





# the end
