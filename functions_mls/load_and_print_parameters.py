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
pyfname = "ML_NM" + str(pid).zfill(2) + ".pickle"
JobSta = pickle.load(file(pyfname))

# second argument, used for "Shrinks"
print JobSta.simplexStatus,
if JobSta.simplexStatus == "Shrinks" :
  if len(sys.argv) == 3 :
    jobid = int(sys.argv[2])
    for para in JobSta.newPara[jobid][:] :
      print para,
  else:
    for para1,para2,para3 in JobSta.newPara: # up to the number of parameters
      print para1,para2,para3,
else:
  for para in JobSta.newPara:
    print para,

# the end
