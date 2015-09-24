#!/bin/bash
### Batch Queuing System is PBS pro
#PBS -N OPa_GLa
#PBS -l walltime=60:00:00
#PBS -l select=1:ncpus=1:mpiprocs=1
#PBS -A nn9207k
#PBS -M maolin.shen@gfi.uib.no
###PBS -M earnestshen@gmail.com
###  Specify mail sent when the job starts (b), ends (e), or if it aborts (a)
#PBS -m a

#------------------------------------------------------------------------------
export home=`pwd`
cd  ${home}
 . ${home}/setup/nametable
rm -f ${home}/Jobs/* ${home}/log/* || echo 'old data were removed!!'  # remove old job handler
export expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
export logdir=${home}/log
#export CPIdir=/work/earnest/Analysis/out_CPI
#export homedir=${home}/Jobs
#export hometarget=`echo ${homedir} | sed 's/\//\\\\\//g'`
export homedir=${workdir}
export hometarget=`echo ${workdir} | sed 's/\//\\\\\//g'` # on hexagon
export worktarget=`echo ${workdir} | sed 's/\//\\\\\//g'`
export fpath=${home}/functions_mls
export PATH=${fpath}:$PATH
# build handler 
echo "Job id: "${Base_job_count}" is running!" > ${home}/Jobs/MainJobCtl
#------------------------------------------------------------------------------
# reset parameters to initial value
# 
MaxInitCounter=0; InitHasDone=1;
OldMICStatus=`grep MaxInitCounter ${home}/setup/nametable`
OldIHSStatus=`grep InitHasDone ${home}/setup/nametable`
ed -s ${home}/setup/nametable  <<EOFPC
g/${OldMICStatus}/s/${OldMICStatus}/MaxInitCounter=${MaxInitCounter}/
g/${OldIHSStatus}/s/${OldIHSStatus}/InitHasDone=${InitHasDone}/
w
q
EOFPC
# remove all old scripts & data
#------------------------------------------------------------------------------
# cleaning old files
#   This will not be done before job check
#oldlogdata=`ls odata_* ` || echo 'No old log filesNo old log files!!'
#for log in ${oldlogdata} ; do
#  mv ${log} log
#done
#------------------------------------------------------------------------------
# check jobs status (setup a new one or continue an old one)
R1=${RANDOM};
${fpath}/checkJobStatus_Learing.sh  ${Max_job_number} ${Base_job_count}  &> ${home}/log/odata_checkJobStatus_`date +%Y_%m%d_%H%M_%S`_${R1}
#-----------------------------------------------------------------------------
# submit jobs
echo "0" > ${home}/Jobs/firstjobid
expDone=.FALSE.; checkcount=0;
OldPerf=99999; NowPerf=0;
while [ ${expDone} == .FALSE. ] ; do # all experiments start and check
  if [ -f ${home}/Jobs/MainJobCtl ] ; then
    mv ${home}/odata_* ${home}/log || echo 'There is no new log yet.'
  else
	  exit;
	fi
#set -ex
 	(( checkcount = checkcount + 1 ))
  ${fpath}/SubTrainSimple.sh ${JobPeriod} ${Base_job_count}  &> ${home}/odata_${checkcount}_SubTrainJobs_${dPerf}
  NowPerf=`tail -c 30 ${GPerfTable} | grep ${expidPrefix} | awk -F " " '{print $NF}'` || NowPerf=0

  if [ "${NowPerf}" != "${OldPerf}" ]; then
    dPerf=`python ${fpath}/sub.py ${NowPerf} ${OldPerf} `
    OldPerf=${NowPerf}
  fi
  #echo "CHK-> "${checkcount}": "` date +%m-%d-%H-%M `"  <- dPerf = "${dPerf}
  echo "CHK-> "${checkcount}": "` date +%m-%d-%H-%M `"  <- dPerf = "${NowPerf}
sleep 29 
#exit

done
echo ' |-> All jobs were finished.'
#------------------------------------------------------------------------------
# post analysis
#${fpath}/postCPIonly ${ExpNum} ${JobPeriod} ${BaseExpID}   &> odata_postCPI_`date +%Y%m%d%H%M%S` 
exit
