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
# define functions
# --------------------------------------------------------------------  
# function for initial run
def Sim_Init( JS ):
#
#  Compute the centroid of the simplex opposite the worst point.
#
  JS.SParas = np.zeros((0,JS.ndim))
  for iexp in range(JS.gdim+JS.pid):
  # find the parameters for the gdim sorted members
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
  JS.ExpidT = JS.SLJPerExp[JS.gdim+JS.pid-1][0] # the target or the temp worst
  JS.simplexStatus = "RefP"
  return JS
# --------------------------------------------------------------------  
# function for the processure after refection 
def Sim_Ref( JS ): 
  print JS.JPerExp
  F_1 = JS.SLJPerExp[0][1]
  F_e = JS.SLJPerExp[JS.gdim-1][1]
  F_T = JS.SLJPerExp[JS.gdim+JS.pid-1][1]
  F_R = JS.NPerf
  JS.PerfR = F_R
  JS.SParas = np.zeros((0,JS.ndim))
  for iexp in range(JS.gdim):
    JS.SParas = np.append( JS.SParas, [JS.Paras[JS.ParasJexpids.index(JS.SLJPerExp[iexp][0])]], 0)
  print JS.SParas
  x_bar = np.mean( JS.SParas[:JS.gdim][:], axis=0)
  X_T = JS.Paras[JS.ParasJexpids.index(JS.ExpidT)]
  JS.xbar = x_bar
#
#  if F[0] < F_r < F[-2], the point will be accepted 
#  
  print "x_bar: ", x_bar 
  if F_1 <= F_R and F_R <= F_e:
    JS.simplexStatus = "Init"
    JS.SLJPerExp[JS.gdim+JS.pid-1][0] = JS.ExpidR
    JS.SLJPerExp[JS.gdim+JS.pid-1][1] = F_R
    x_n = x_bar
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
# function for the processure after expansion 
def Sim_Exp( JS ):
  F_E = JS.NPerf
  F_R = JS.PerfR


  if F_E < F_R :
    JS.SLJPerExp[JS.gdim+JS.pid-1][0] = JS.ExpidE
    JS.SLJPerExp[JS.gdim+JS.pid-1][1] = F_E
  else:
    JS.SLJPerExp[JS.gdim+JS.pid-1][0] = JS.ExpidR
    JS.SLJPerExp[JS.gdim+JS.pid-1][1] = F_R

  JS.simplexStatus = "Init" 
  print JS.simplexStatus
  JS.newPara = JS.xbar
  return JS

# --------------------------------------------------------------------  
# function for the processure after refection 
def Sim_Shrinks( JS ):

  JS.totalN = JS.SLJPerExp.__len__()
#  print JS.totalN
  X = np.zeros((0, JS.ndim))
  for iexp in range( JS.totalN ) :
    print "appending : ", JS.Paras[JS.ParasJexpids.index(JS.SLJPerExp[iexp][0])]
    print "X is : ", X
    X = np.append( X, [JS.Paras[JS.ParasJexpids.index(JS.SLJPerExp[iexp][0])]], 0)
  for iexp in range(JS.gdim-1):
    X[iexp+1][:] = sig*X[iexp+1][:] + (1-sig) * X[0][:]

  JS.newPara = X
  return JS

#--------------------------------------------------------------------  
# function for the processure after refection 
def Sim_Con( JS ):
  F_C = JS.NPerf
  F_R = JS.PerfR

  X_e = JS.Paras[JS.ParasJexpids.index(JS.Expide)]

  if F_C > F_R :
    Sim_Shrinks(JS)
    JS.simplexStatus = "Shrinks"
  else:
    JS.SLJPerExp[JS.gdim+JS.pid-1][0] = JS.ExpidC
    JS.SLJPerExp[JS.gdim+JS.pid-1][1] = F_C
    JS.simplexStatus = "Init"
    x_n = JS.xbar   # null results
  print JS.simplexStatus
  return JS

# --------------------------------------------------------------------  
# function for the processure after refection 
def Sim_ICon( JS ):
  F_C = JS.NPerf
  F_T = JS.SLJPerExp[JS.gdim+JS.pid-1][1]

  X_e = JS.Paras[JS.ParasJexpids.index(JS.Expide)]

  if F_C > F_T :
    Sim_Shrinks(JS)
    JS.simplexStatus = "Shrinks"
    x_n = JS.newPara
  else:
    JS.SLJPerExp[JS.gdim+JS.pid-1][0] = JS.ExpidC
    JS.SLJPerExp[JS.gdim+JS.pid-1][1] = F_C
    JS.simplexStatus = "Init"
    x_n = JS.xbar   # null results
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


#######################################################################
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
g_dim = int(sys.argv[2]) # size of initial guess
pyfname = "ML_NM" + str(pid).zfill(2) + ".pickle"

try:
# --------------------------------------------------------------------
# warm  start  
  with open(pyfname) as pyfc: pass
  JobSta = pickle.load(file(pyfname))
  newExpid = sys.argv[3]
  newPerf = float(sys.argv[4])
  ifparas = 5; ifperfs = 6
  IsSuccession = True 
except IOError as e:
# --------------------------------------------------------------------
# cold  start  
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
  JPerformance = "ML_NMIOTable"
else:
  JPerformance = sys.argv[ifperfs]

if len(sys.argv) <= ifperfs+1:
  GlobJParameters = "jobParameters"
else:
  GlobJParameters = sys.argv[ifperfs+1]

if len(sys.argv) <= ifperfs+2:
  GlobJPerformance = "Performance"
else:
  GlobJPerformance = sys.argv[ifperfs+2]

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

print LJPerExp

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
#  Read parameters, for the sorted one
#
JexpidParas = []
JParas = np.zeros((0,0))
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
        #print tempparas
  if n_dim == 100:
    n_dim = n_dimcheck
    JParas = np.zeros((0,n_dim))
    print "This is a %d-D problem. \n " % n_dim
  print "tempparas are ", tempparas
  JParas = np.append( JParas, [tempparas], 0)  

print JParas, n_dim

# --------------------------------------------------------------------
# Read parameters, for the unsorted one, all of them
#
JAll_expids = []
#JAll_Paras = np.zeros((0,0))
JAll_Paras = np.zeros((0,n_dim))
tempparas = np.zeros((0))
for line in open(GlobJParameters,'r'):
  n_dimcheck = 0
  temp = line.strip().split(' ')
  JAll_expids.append(temp[0])
  tempparas = np.zeros((0,))
  for string in temp[1:] :
    if n_dimcheck < n_dim :
      if string != "done" :
        tempparas = np.append(tempparas, [float(string)],0)
        n_dimcheck += 1
        print temp[0], 'tempparas: ', tempparas, JAll_Paras
  JAll_Paras = np.append( JAll_Paras, [tempparas], 0)  

print JAll_expids, JAll_Paras

# --------------------------------------------------------------------
#  Read all performances, only for finding the new results
#
#print GlobJPerformance
## --------------------------------------------------------------------
#AllExpPerformance = []
#for line in open(GlobJPerformance,'r'):
#  temp = line.strip().split(' ')
#  AllExpPerformance.append([temp[0], float(temp[1])])
##index = [it for it in range(len(AllExpPerformance)) if AllExpPerformance[it][0] == newExpid ][0]
##newPerf = AllExpPerformance[index][1]



# --------------------------------------------------------------------
#  Store all necessary list into JobSta
#   predefined or loaded -> JobSta.simplexStatus, JobSta.nPT
# 
JobSta.gdim = g_dim; JobSta.ndim = n_dim
JobSta.Paras = JParas
JobSta.ParasJexpids = JexpidParas
JobSta.JPerExp = LJPerExp
JobSta.All_expids = JAll_expids
JobSta.All_Paras = JAll_Paras
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
if JobSta.simplexStatus == "Init" : 
# computing the reflection point for the initial run 
  JobSta  = Sim_Init( JobSta )
elif JobSta.simplexStatus == "RefP": 
# the following-up process for reflection point
  JobSta.ExpidR = newExpid
  JobSta.NPerf  = newPerf
  JobSta = Sim_Ref( JobSta )
elif JobSta.simplexStatus == "ExpP":
# the following-up process for expansion point
  JobSta.ExpidE = newExpid
  JobSta.NPerf  = newPerf
  JobSta = Sim_Exp( JobSta )
elif JobSta.simplexStatus == "ConP": 
# the following-up process for the contraction point
  JobSta.ExpidC = newExpid
  JobSta.NPerf  = newPerf 
  JobSta = Sim_Con( JobSta )
else: # inside contraction
  JobSta.ExpidC = newExpid
  JobSta.NPerf  = newPerf
  JobSta = Sim_ICon( JobSta )

print JobSta.simplexStatus, 
print JobSta.newPara


pickle.dump(JobSta, file(pyfname,'w'))




# the end
