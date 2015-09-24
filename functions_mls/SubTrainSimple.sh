#!/bin/bash
#------------------------------------------------------------------------------
expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
JobPeriod=$1
  . ${home}/setup/nametable
BaseExpID=${Base_job_count}
set -ex
if [ -f ${home}/Jobs/firstjobid ] ; then
  FJobID=`cat ${home}/Jobs/firstjobid`
fi

IsFirstUnDone=.TRUE.
#------------------------------------------------------------------------------
# check available jobs
ExpNum=${Max_job_number}
IsEOF=.FALSE. ; nline=${FJobID}; ActJobN=0;

while [ ${IsEOF} == .FALSE. ] ; do
  (( nline = nline + 1 ))
  JobParam=`cat coefficients | sed -n "${nline}p"  `
  if [ "${JobParam}" == ""  ] ; then
    IsEOF=.TRUE.
  else
  	JobEND=`echo ${JobParam} | awk -F " " '{print $NF}'  `
		Expid=`echo ${JobParam} | awk -F " " '{print $1}'  `
		if [ "${JobEND}" != "done" ] ; then
 	  	if [ -f ${home}/Jobs/${Expid}_JobCtl* ]  ; then
 		    (( ActJobN = ActJobN + 1 ))
			else
			  ${fpath}/SingleJobCtl.sh ${Expid} ${JobPeriod}  &> ${home}/log/odata_SingleJobCtl_${Expid}_`date +%Y_%m%d_%H%M_%S` &
				echo '|-> Run '${Expid}'.'
			  (( ActJobN = ActJobN + 1 ))
 	  	fi
			if [ "${OldJobEND}" == "done" ] && [ ${IsFirstUnDone} == .TRUE. ] ; then
			  echo `expr ${nline} - 1` > ${home}/Jobs/firstjobid
				IsFirstUnDone=.FALSE.
			fi
		fi
     OldJobEND=JobEND
	fi  # job parameters check
   if (( ${ActJobN} >= ${ExpNum} )) ; then
     IsEOF=.TRUE.
  fi
done
# ------------------------------------------------------------------------
# add new jobs
id=`echo ${Expid} | cut -c4-6 `
  while (( ${ActJobN} < ${ExpNum}  )) ; do
	(( id = id + 1))
  (( ActJobN = ActJobN + 1 ))
	Expid=${expidPrefix}${id}; R1=${RANDOM};
  ${fpath}/checkJobStatus_Learing.sh  ${Expid} &> ${home}/log/odata_checkJobStatus_`date +%Y_%m%d_%H%M_%S`_${R1}

  ${fpath}/SingleJobCtl.sh ${Expid} ${JobPeriod}  &> ${home}/log/odata_SingleJobCtl_${Expid}_`date +%Y_%m%d_%H%M_%S` &
done
#------------------------------------------------------------------------------
