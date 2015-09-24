#!/usr/bin/python
# -*- encoding: utf-8
# for offline searching the min value
# argument inputs are necessary
# $1 -> number of concurrent run

import numpy as np
import sys
import pickle
# --------------------------------------------------------------------  
#-----------------------------------------------------------------------
# Use a class to keep the data tidy and conveniently accessible...
class JobStatus:
  """
	MLS: Stores the associated information used for the (nonlinear) simplex.
	"""
  pass
  #self.simplexStatus = ""
  #self.nPT = 10
  #self.gdimExpid = ""
  #self.RefExpid = ""
  #self.ConExpid = ""
  #self.SortExpid = []
# -------------------------------------------------------------------- 
# --------------------------------------------------------------------  
#
#                         Main program start
#
# --------------------------------------------------------------------
# -------------------------------------------------------------------- 
# --------------------------------------------------------------------
#  Define Job status
#
pid = int(sys.argv[1])  # id for parallel jobs
tid = int(sys.argv[2])-1  # id for parallel jobs
pyfname = "ML_NM" + str(pid).zfill(2) + ".pickle"
JobSta = pickle.load(file(pyfname))

print JobSta.simplexStatus,
if tid == -1 :
  rid = JobSta.gdim+pid-1
  #print rid, JobSta.gdim, pid
  print JobSta.SLJPerExp[rid][0], JobSta.SLJPerExp[rid][1],
  for para in JobSta.All_Paras[JobSta.All_expids.index(JobSta.SLJPerExp[rid][0])]:
    print para, 
  print rid
elif tid == -2 :
  print JobSta.ExpidT 
else:
  print JobSta.SLJPerExp[tid][0], JobSta.SLJPerExp[tid][1],
  for para in JobSta.All_Paras[JobSta.All_expids.index(JobSta.SLJPerExp[tid][0])]:
    print para,

# the end
