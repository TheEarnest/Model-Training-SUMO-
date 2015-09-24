#!/bin/bash
#------------------------------------------------------------------------------
# control single job 
set -ex
 . ${home}/setup/nametable
expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
#JobPeriod=$2
ExpID=$1
if (( ${JobPeriod} > 1 )); then
  (( JobPeriod = JobPeriod + spinupyrs +1 ))
fi
jobstamp=`date +%Y%m%d%H%M%S`
echo ${ExpID}" is running!" > ${home}/Jobs/${ExpID}_JobCtl_${jobstamp}
IsFirstRun=.TRUE.
if [ -f ${home}/Jobs/MainJobCtl ] ; then
  expid=${ExpID}
  exphome=${homedir}/${expid}
else
  exit
fi
if [ ! -d ${exphome}  ]; then # for jobnum 1
# ------------------------------------------------------------------------
# work dir
  if [ ! -d ${workdir}/${expid} ]; then mkdir -p  ${workdir}/${expid}; fi
# ------------------------------------------------------------------------
# run script 
  if [ ! -d ${exphome}/scripts ]; then mkdir -p ${exphome}/scripts; fi
  if [ ! -d ${exphome}/log ]; then mkdir -p ${exphome}/log; fi
	Param=`grep ${expid} ${GParaTable}  ` || Param=""
	PmMoCoef=`echo ${Param} | awk -F " " '{print $2}' `
  PmMaCoef=`echo ${Param} | awk -F " " '{print $3}' `
  PmMeCoef=`echo ${Param} | awk -F " " '{print $4}' `

 	cd ${exphome}/scripts
	if [ -f ${expid}.run ]; then # check job status
    OmMoCoef=`grep "mcoefs=" ${expid}.run | awk -F "\"" '{print $2}' | awk -F " " '{print $1}' ` 
		if [ "${PmMoCoef}"  != "${OmMoCoef}" ] ; then
      rm -rf   ${exphome}/scripts/* ${exphome}/log/*
    # rebuild the job
  	  cd ${exphome}/scripts
	    . ${fpath}/buildjobscript.sh
  	fi
	else # there is no old job
	  rm -rf   ${exphome}/scripts/* ${exphome}/log/*
    # rebuild the job
    #tar xf ${workdir}/cosmos-ao/CT31L19GR30L40_restart.tar -C ${workdir}/${expid}
    ${fpath}/renewCOSMOSrun ${RSSExpid} ${RSSyear} ${expid} ${RSyear} ${atmres} ${atmlev} ${oceres} ${ocelev}
		cd ${exphome}/scripts
 		. ${fpath}/buildjobscript.sh

  fi  # check the run number of the job

  cp ${home}/setup/date_templet local_reference_file
  
  chkfn=${exphome}/work/namcouple
  if [ -f ${chkfn}  ]; then
    # check if the log is too old 
    TLastJob=`date --reference=${chkfn}  +%s `; Tnow=`date +%s  `
    ((  Tdiff = Tnow - TLastJob ))
    if (( ${Tdiff} > ${TimeUsed} )); then
   	  qsub ${expid}.run; sleep 2
    fi
  else
    qsub ${expid}.run; sleep 2
  fi
  outdir=${CPIdir}/${expid}
	mkdir -p ${outdir}
	cp ${expid}.run  ${outdir}
	#${home}/submitCHK ${expid}
  sleep ${SleepSec}
# ------------------------------------------------------------------------
else # for the rest job submit
	export CLimit=${MCLimit}
  cd ${exphome}/scripts
  #save_file_mod oasis3 log ${expid}.date temp_${expid}.date  || {
  #  echo '  |- file '${expid}'.date not yet updated!!!!!' 
  #}
	if [ -f ${expid}.date ]; then
		JobNum=`cat ${expid}.date | awk -F " " '{print $NF}' `
  else
	  JobNum=0
	fi

  if (( ${JobNum} > ${JobPeriod} )) ; then
	  expCont=.FALSE. 
 	  echo 'exp '${expid}' is finished!!'
	else
    if [ -f ${expid}.log ]; then
      # check if the log is too old
      TLastJob=`date --reference=${expid}.log +%s `; Tnow=`date +%s  `
      ((  Tdiff = Tnow - TLastJob ))
      if (( ${Tdiff} > ${TimeUsed} )); then
        qsub ${expid}.run; sleep 2
      fi
    else
      if [ -f ${expid}.run ]; then
        qsub ${expid}.run; sleep 2
      else
        cd ${exphome}/../
        rm -rf ${exphome}
      fi
    fi
	fi
fi

cd ${home}

if [ ${JobNum} -gt ${JobPeriod} ] ; then

  echo ' |-> Jobs was finished.'
  echo " |-------------------------------|"
  echo " |- $(date) |"
  echo " |-------------------------------|"
  rm ${home}/Jobs/${ExpID}_JobCtl_${jobstamp} || echo "Jobs/"${ExpID}"_JobCtl_"${jobstamp}" has been removed!!  "
#------------------------------------------------------------------------------
# post process
  if (( ${JobPeriod} > 1 )) ; then
    (( JobPeriod = JobPeriod - spinupyrs  ))
  fi
  JobR=`grep ${expid} ${GPerfTable} ` || JobR=" "
  if [ ! -f ${home}/Jobs/${ExpID}_PostCPI_* ] && [ "${JobR}"==" "  ]; then
    ${fpath}/SinglePostCPI ${expid} ${JobPeriod}  &> log/odata_postCPI_${expid}_`date +%Y%m%d%H%M%S`
    #cp -rf ${CPIdir}/${expid} ${home}/out_CPI
    echo ' |-> Post processing was finished.'
    echo " |-------------------------------|"
    echo " |- $(date) |"
    echo " |-------------------------------|" 
    echo " Delete old run job."
    #rm -rf ${exphome}/outdata/ ${exphome}/restart ${exphome}/log

    JobR=`grep ${expid} ${GPerfTable} ` || JobR=" "
    if [ "${JobR}" != " "  ]; then
      JobParam=`grep ${expid} ${GParaTable} `
      JobEND=` echo ${JobParam} | awk -F " " '{print $NF}' `
      if [ "${JobEND}" != "done" ] ; then
        JobEND=${JobParam}" done"
        ed -s ${GParaTable}  <<EOF1
g/${JobParam}/s/${JobParam}/${JobEND}/
w
q
EOF1
      fi # end job
    fi #
  fi # PostCPI check
fi

# delete handler
  rm ${home}/Jobs/${ExpID}_JobCtl_${jobstamp} || {
    echo ${ExpID}"_JobCtl_"${jobstamp}" has been deleted!!!"
}

