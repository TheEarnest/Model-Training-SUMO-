#!/usr/bin/python
# -*- encoding: utf-8
# for offline searching the min value
# argument inputs are necessary
# $1 -> number of concurrent run
# $2 -> index of this run
# $3 -> Base exp number
# $4 -> Base exp performance
# $5 -> file name of job parameters
# $6 -> file name of job performance
# $7 -> file name of all job list

"""
Nelder-Mead simplex minimization of a nonlinear (multivariate) function.

The programming interface is via the minimize() function; see below.

This code has been adapted from the C-coded nelmin.c which was
adapted from the Fortran-coded nelmin.f which was, in turn, adapted
from the papers

J.A. Nelder and R. Mead (1965)
A simplex method for function minimization.
Computer Journal, Volume 7, pp 308-313.

R. O'Neill (1971)
Algorithm AS47. Function minimization using a simplex algorithm.
Applied Statistics, Volume 20, pp 338-345.

and some examples are in
D.M. Olsson and L.S. Nelson (1975)
The Nelder-Mead Simplex procedure for function minimization.
Technometrics, Volume 17 No. 1, pp 45-51.

For a fairly recent and popular incarnation of this minimizer,
see the amoeba function in the famous "Numerical Recipes" text.
"""

import os
import numpy as np
import sys
import pickle
# --------------------------------------------------------------------  
# define functions
# --------------------------------------------------------------------  
# function for initial run
def Sim_Init( JS ):
#
#  Compute the centroid of the simplex opposite the worst point.
#
  JS.SParas = np.zeros((0,JS.ndim))
  for iexp in range(JS.gdim+JS.pid):
    JS.SParas = np.append( JS.SParas, [JS.Paras[JS.ParasJexpids.index(JS.SLJPerExp[iexp][0])]], 0)

  x_bar = np.mean( JS.SParas[:JS.gdim], axis=0)

  print "x_bar: ", x_bar, "Sorted Paras", JS.SParas
#
# Compute the reflection point.
# 
  x_r = (1.0 + rho) * x_bar - rho * JS.SParas[JS.gdim+JS.pid-1][:]
  JS.newPara = x_r
  JS.Expid1 = JS.SLJPerExp[0][0]
  JS.Expide = JS.SLJPerExp[JS.gdim-1][0]
  if JS.simplexStatus == "Init" : 
    JS.ExpidT = JS.SLJPerExp[JS.gdim+JS.pid-1][0]
  else :
    JS.ExpidT = JobSta.ExpidE
  JS.simplexStatus = "RefP"
  return JS
# --------------------------------------------------------------------  
# function for the processure after refection 
def Sim_Ref( JS ): 
  print JS.JPerExp
  F_1 = JS.SLJPerExp[0][1]
  index = [it for it in range(len(JS.JPerExp)) if JS.JPerExp[it][0] == JS.Expide ][0]
  F_e = JS.JPerExp[index][1]
  print "JS.ExpidT is ", JS.ExpidT
  print "End of the list is: ", JS.JPerExp[-1][:]
  index = [it for it in range(len(JS.JPerExp)) if JS.JPerExp[it][0] == JS.ExpidT ][0]
  F_T = JS.JPerExp[index][1]
  print "JS.ExpidR is ", JS.ExpidR
  print "End of the list is: ", JS.JPerExp[-1][:]
  index = [it for it in range(len(JS.JPerExp)) if JS.JPerExp[it][0] == JS.ExpidR ][0]
  F_R = JS.JPerExp[index][1]

  JS.SParas = np.zeros((0,JS.ndim))
  for iexp in range(JS.gdim):
    JS.SParas = np.append( JS.SParas, [JS.Paras[JS.ParasJexpids.index(JS.SLJPerExp[iexp][0])]], 0)

  x_bar = np.mean( JS.SParas[:JS.gdim][:], axis=0)
  X_e = JS.Paras[JS.ParasJexpids.index(JS.Expide)]
  X_T = JS.Paras[JS.ParasJexpids.index(JS.ExpidT)]
#
#  if F[0] < F_r < F[-2], the point will be accepted 
#  
  print "x_bar: ", x_bar 
  if F_1 <= F_R and F_R <= F_e:
    JS.simplexStatus = "Init"
    x_n = (None, None)
  elif F_R < F_1:  #Test for possible expansion.
    x_n = (1 + rho*xi) * x_bar - rho*xi*X_T
    JS.simplexStatus = "ExpP"
  elif F_e <= F_R  and F_R < F_T :  # Outside contraction.
    x_n = (1+rho*gam)*x_bar - rho*gam*X_T
    JS.simplexStatus = "ConP"
  else:  #	F_R must be >= F(N_DIM+1),  Try an inside contraction.
    x_n = (1-gam)*x_bar + gam * X_T
    JS.simplexStatus = "ICoP"

  JS.newPara = x_n
  return JS 

# --------------------------------------------------------------------  
# function for the processure after refection 
def Sim_Con( JS ):
  index = [it for it in range(len(JS.JPerExp)) if JS.JPerExp[it][0] == JS.ExpidC ][0]
  F_C = JS.JPerExp[index][1]
  index = [it for it in range(len(JS.JPerExp)) if JS.JPerExp[it][0] == JS.ExpidR ][0]
  F_R = JS.JPerExp[index][1]

  X_e = JS.Paras[JS.ParasJexpids.index(JS.Expide)]

  if F_C > F_R :
    X = np.zeros((0,JS.ndim))
    for iexp in range(JS.gdim) :
      X = np.append( X, [JS.Paras[JS.ParasJexpids.index(JS.JPerExp[iexp][0])]], 0)
    #print JS.gdim, iexp, X
    for iexp in range(JS.gdim-1):
      X[iexp+1][:] = sig*X[iexp+1][:] + (1-sig) * sig*X[0][:]
      x_n = X[:JS.gdim]
    JS.simplexStatus = "Shrinks"
  else:
    JS.simplexStatus = "Init"
    x_n = X_e    # null results
  print JS.simplexStatus
  JS.newPara = x_n
  return JS

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
# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)

if len(sys.argv) < 2:
  print "The job id and the number of parallel jobs are necessary!!!"
  sys.exit()

# --------------------------------------------------------------------
#  Define Job status
#
pid = int(sys.argv[1])  # id for parallel jobs
g_dim = int(sys.argv[2])
pyfname = "ML_NM" + str(pid).zfill(2) + ".pickle"

try:
  with open(pyfname) as pyfc: pass
  JobSta = pickle.load(file(pyfname))
  newExpid = sys.argv[3]
  newPerf = sys.argv[4]
  ifparas = 5; ifperfs = 6
  IsSuccession = True 
except IOError as e:
  ifparas = 3; ifperfs = 4
  JobSta = JobStatus()
  # computing the reflection point for the initial run
  JobSta.simplexStatus = "Init"
  JobSta.pid = pid # id for parallel jobs
  IsSuccession = False
  newExpid = None

print "new expid is: ", newExpid
if len(sys.argv) <= ifparas:
  #JParameters="jobParameters"
  JParameters="ML_NMInputs"
else:
  JParameters = sys.argv[ifparas]

if len(sys.argv) <= ifperfs:
  #JPerformance = "Performance"
  JPerformance = "ML_NMOutputs"
else:
  JPerformance = sys.argv[ifperfs]

if len(sys.argv) <= ifperfs+1:
  JPerformance = "jobParameters"
else:
  JPerformance = sys.argv[ifperfs]




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
for line in open(JPerformance,'r'):
  temp = line.strip().split(' ')
  LJPerExp.append([temp[0], float(temp[1])])


if g_dim > len(LJPerExp) : 
  g_dim = len(LJPerExp)

# --------------------------------------------------------------------
#  Build initial array
#  STJexp: store only g_dim the sorted job expids
if IsSuccession == False or JobSta.simplexStatus == "Init"  :
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
for line in open(JParameters,'r'):
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
#  Store all necessary list into JobSta
#   predefined or loaded -> JobSta.simplexStatus, JobSta.nPT
# 
JobSta.gdim = g_dim; JobSta.ndim = n_dim
JobSta.Paras = JParasAll
JobSta.ParasJexpids = JexpidParas
JobSta.JPerExp = LJPerExp
if IsSuccession == False or JobSta.simplexStatus == "Init" :
  JobSta.SLJPerExp = SortJP
# --------------------------------------------------------------------
#  Define algorithm constants
#
rho = 1;    # rho > 0
xi  = 2;    # xi  > max(rho, 1)
gam = 0.5;  # 0 < gam < 1
sig = 0.5;  # 0 < sig < 1
tolerance = 1.0E-03;
#print JobSta.simplexStatus
# --------------------------------------------------------------------
if JobSta.simplexStatus == "Init" or JobSta.simplexStatus == "ExpP" : 
# computing the reflection point for the initial run 
  if JobSta.simplexStatus == "Init" :
    JobSta.ExpidE = None
  else :
    JobSta.ExpidE = newExpid

  JobSta  = Sim_Init( JobSta )
  print JobSta.simplexStatus, 
  if np.sum(np.shape(JobSta.newPara)) <= JobSta.ndim:
    for para in JobSta.newPara:
      print para,
  else:
    for para1,para2 in JobSta.newPara:
      print para1,para2,
  #print JobSta.newPara, JobSta.simplexStatus
elif JobSta.simplexStatus == "RefP": 
# the following-up process for reflection point
  JobSta.ExpidR = newExpid
  JobSta = Sim_Ref( JobSta )
  print JobSta.simplexStatus, 
  if np.sum(np.shape(JobSta.newPara)) <= JobSta.ndim:
    for para in JobSta.newPara:
      print para,
  else:
    for para1,para2 in JobSta.newPara:
      print para1,para2,
elif JobSta.simplexStatus == "ConP": 
# the following-up process for the contraction point
  JobSta.ExpidC = newExpid 
  JobSta = Sim_Con( JobSta )
  print JobSta.simplexStatus, 
  if np.sum(np.shape(JobSta.newPara)) <= JobSta.ndim:
    for para in JobSta.newPara:
      print para,
  else:
    for para1,para2 in JobSta.newPara:
      print para1,para2,
else: # inside contraction
  JobSta.ExpidC = newExpid
  JobSta = Sim_Con( JobSta )
  print JobSta.simplexStatus, 
  if np.sum(np.shape(JobSta.newPara)) <= JobSta.ndim:
    for para in JobSta.newPara:
      print para,
  else:
    for para1,para2 in JobSta.newPara:
      print para1,para2,


pickle.dump(JobSta, file(pyfname,'w'))




# the end
