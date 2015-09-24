#!/bin/bash
#------------------------------------------------------------------------------
# control single job 
set -ex

expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
JobPeriod=$2
ExpID=$1
if (( ${JobPeriod} > 1 )); then
  (( JobPeriod = JobPeriod + 1 ))
fi
jobstamp=`date +%Y%m%d%H%M%S`
echo ${ExpID}" is running!" > ${home}/Jobs/${ExpID}_JobCtl_${jobstamp}
expCont=.TRUE.
IsFirstRun=.TRUE.
#while [ ${expCont} == .TRUE. ]; do #
  if [ -f ${home}/Jobs/MainJobCtl ] ; then
    expid=${ExpID}
	  exphome=${homedir}/${expid}
	else
	  exit
	fi
# ------------------------------------------------------------------------
# run script 
  	Param=`grep ${expid} coefficients  `
		input1=`echo ${Param} | awk -F " " '{print $2}' `
		input2=`echo ${Param} | awk -F " " '{print $3}' `
    
    output=`python ${fpath}/beale.py 0.1 ${input1} ${input2}  ` 
    echo ${expid}" "${output} >> ${fpath}/../outputs
# ------------------------------------------------------------------------

#done  # while loop for this job


JobParam=`grep ${expid} coefficients `
JobEND=` echo ${JobParam} | awk -F " " '{print $NF}' `
if [ "${JobEND}" != "done" ] ; then
  JobEND=${JobParam}" done"
  ed -s coefficients  <<EOF1
g/${JobParam}/s/${JobParam}/${JobEND}/
w
q
EOF1
fi
echo ' |-> Jobs was finished.'
rm ${home}/Jobs/${ExpID}_JobCtl_${jobstamp}
echo " |-------------------------------|"
echo " |- $(date) |"
echo " |-------------------------------|"

