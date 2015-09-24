#!/bin/bash
#------------------------------------------------------------------------------
# physical parameters control factors
set -e
#------------------------------------------------------------------------------
# relat. cloud massflux at level above nonbuoyanc
# default value for T31L19: cmfctop = 0.30, 0.1~0.333
cmfctop=0.3
Maxcmfctop=`echo "${cmfctop}+0.033" | bc -l | cut -c1-8`
Mincmfctop=`echo "${cmfctop}-0.250" | bc -l | cut -c1-8`
Dcmfctop=`echo "${Maxcmfctop}-${Mincmfctop}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# entrainment rate for penetrative convection
# default value for T31L19: entrpen = 1.0E-04, 3e-5~5e-4
entrpen=0.0001
Maxentrpen=`echo "${entrpen}+0.00010" | bc -l | cut -c1-8`
Minentrpen=`echo "${entrpen}-0.00000" | bc -l | cut -c1-8`
Dentrpen=`echo "${Maxentrpen}-${Minentrpen}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# entrainment rate for shallow convection
# default value for T31L19: entrscv = 3.0E-04, 3e-4~1e-3
entrscv=0.0003
Maxentrscv=`echo "${entrscv}+0.00010" | bc -l | cut -c1-8`
Minentrscv=`echo "${entrscv}-0.00010" | bc -l | cut -c1-8`
Dentrscv=`echo "${Maxentrscv}-${Minentrscv}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# cloud inhomogeneity factor (liquid)
# default value for T31L19: zinhoml = 0.7, 0.65~1
zinhoml=0.7
Maxzinhoml=`echo "${zinhoml}+0.10" | bc -l | cut -c1-8`
Minzinhoml=`echo "${zinhoml}-0.10" | bc -l | cut -c1-8`
Dzinhoml=`echo "${Maxzinhoml}-${Minzinhoml}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# cloud inhomogeneity factor (ice)
# default value for T31L19: zinhomi = 0.8, 0.65~1
zinhomi=0.8
Maxzinhomi=`echo "${zinhomi}+0.1000" | bc -l | cut -c1-8`
Minzinhomi=`echo "${zinhomi}-0.1000" | bc -l | cut -c1-8`
Dzinhomi=`echo "${Maxzinhomi}-${Minzinhomi}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# correction for asymmetry
# default value for T31L19: zasic = 0.91,   0.8~1 
zasic=0.91
Maxzasic=`echo "${zasic}+0.10000" | bc -l | cut -c1-8`
Minzasic=`echo "${zasic}-0.10000" | bc -l | cut -c1-8`
Dzasic=`echo "${Maxzasic}-${Minzasic}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
# COEFFICIENT FOR CONVERSION FROM CLOUD WATER TO RAIN
# default value for T31L19: cprcon = 0.0004, 0.0002~0.001
cprcon=0.0004
Maxcprcon=`echo "${cprcon}+0.00010" | bc -l | cut -c1-8`
Mincprcon=`echo "${cprcon}-0.00010" | bc -l | cut -c1-8`
Dcprcon=`echo "${Maxcprcon}-${Mincprcon}" | bc -l | cut -c1-8`
#------------------------------------------------------------------------------
