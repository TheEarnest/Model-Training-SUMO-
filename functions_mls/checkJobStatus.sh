#!/bin/bash
#------------------------------------------------------------------------------
#   check older jobs
set -ex
expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
linesep='#------------------------------------------------------------------------------'
ExpNum=$1
if [[ -n $2 ]] ; then
  BaseExpID=$2
else
  BaseExpID=""
fi
		
PSep=" "
if [ -f "jobParameters" ]; then
  if [ "${BaseExpID}" == "" ] ; then   # set up a new job
#------------------------------------------------------------------------------
# physical parameters control factors
    . ${home}/setup/phys_param_ctl.sh
#------------------------------------------------------------------------------
    R1=${RANDOM}; R2=${RANDOM}; R3=${RANDOM}; R4=${RANDOM};
    R5=${RANDOM}; R6=${RANDOM}; R7=${RANDOM};
    Pcmfctop=`echo "${Mincmfctop}+${R1}/32767*${Dcmfctop}" | bc -l | cut -c1-8`
    Pentrpen=`echo "${Minentrpen}+${R2}/32767*${Dentrpen}" | bc -l | cut -c1-8`
    Pentrscv=`echo "${Minentrscv}+${R3}/32767*${Dentrscv}" | bc -l | cut -c1-8`
    Pzinhoml=`echo "${Minzinhoml}+${R4}/32767*${Dzinhoml}" | bc -l | cut -c1-8`
    Pzinhomi=`echo "${Minzinhomi}+${R5}/32767*${Dzinhomi}" | bc -l | cut -c1-8`
    Pzasic=`echo   "${Minzasic}+${R6}/32767*${Dzasic}" | bc -l | cut -c1-8`
    Pcprcon=`echo  "${Mincprcon}+${R7}/32767*${Dcprcon}" | bc -l | cut -c1-8`
    echo ${ExpNum}${PSep}${Pcmfctop}${PSep}${Pentrpen}${PSep}${Pentrscv}${PSep}${Pzinhoml}${PSep}${Pzinhomi}${PSep}${Pzasic}${PSep}${Pcprcon} >> jobParameters
    echo " |-> Parameters for job "${ExpNum}" is setup." 
  else # do nothing for jobs
    echo  ' |-> Continue an old run or an unfinished run!!   '
    (( id = ExpNum + BaseExpID ))
  	grep ${expidPrefix}${id}${PSep} jobParameters  || { 
  	  echo "The number of Job is wrong!!!" 
  	}
  fi
else
  echo  ' |-> Setup a new run!!  '
#------------------------------------------------------------------------------
# physical parameters control factors
  . ${home}/setup/phys_param_ctl.sh
#------------------------------------------------------------------------------
  expidn=0; id=0
	while (( ${expidn} < ${ExpNum} )); do # for Jobs
    (( expidn = expidn + 1))
    (( id = expidn + BaseExpID ))
    set -ex
    R1=${RANDOM}; R2=${RANDOM}; R3=${RANDOM}; R4=${RANDOM};
    R5=${RANDOM}; R6=${RANDOM}; R7=${RANDOM};
    Pcmfctop=`echo "${Mincmfctop}+${R1}/32767*${Dcmfctop}" | bc -l | cut -c1-8`
    Pentrpen=`echo "${Minentrpen}+${R2}/32767*${Dentrpen}" | bc -l | cut -c1-8`
    Pentrscv=`echo "${Minentrscv}+${R3}/32767*${Dentrscv}" | bc -l | cut -c1-8`
    Pzinhoml=`echo "${Minzinhoml}+${R4}/32767*${Dzinhoml}" | bc -l | cut -c1-8`
    Pzinhomi=`echo "${Minzinhomi}+${R5}/32767*${Dzinhomi}" | bc -l | cut -c1-8`
    Pzasic=`echo   "${Minzasic}+${R6}/32767*${Dzasic}" | bc -l | cut -c1-8`
    Pcprcon=`echo  "${Mincprcon}+${R7}/32767*${Dcprcon}" | bc -l | cut -c1-8`
    echo  ${expidPrefix}${id}${PSep}${Pcmfctop}${PSep}${Pentrpen}${PSep}${Pentrscv}${PSep}${Pzinhoml}${PSep}${Pzinhomi}${PSep}${Pzasic}${PSep}${Pcprcon} >> jobParameters
  done
fi
#------------------------------------------------------------------------------
