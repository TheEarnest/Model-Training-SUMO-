#!/bin/bash
#------------------------------------------------------------------------------
#   check older jobs
set -ex
#------------------------------------------------------------------------------
 . ${home}/setup/nametable
#------------------------------------------------------------------------------
expidPrefix=` echo ${home} | awk -F '/' '{print ( $(NF) )}' | cut -c1-3 `
linesep='#----------------------------------------------------------------------'
ExpNum=$1
if [[ -n $2 ]] ; then
  BaseExpID=$2
else
  BaseExpID=" "
fi
MaxExpNum=${Max_job_number}

PSep=" "
if [ -f "${GParaTable}" ]; then
  if [ "${BaseExpID}" == " " ] ; then   # ** set up a new job  **
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
    expid=`echo ${ExpNum} | cut -c4-8 `
    (( id = expid - Base_job_count ))
    if (( ${id} <= ${Base_MLB_number} + ${Max_job_number} )) ; then
      R1=${RANDOM}; R2=${RANDOM}; R3=${RANDOM}; R4=${RANDOM};
      R5=${RANDOM}; R6=${RANDOM}; R7=${RANDOM};
      input1=`echo "(${R1}-0)/32767*1.0" | bc -l | cut -c1-8`
      input2=`echo "(${R2}-0)/32767*1.0" | bc -l | cut -c1-8`
      input3=`echo "(${R3}-0)/32767*1.0" | bc -l | cut -c1-8`
      echo  ${ExpNum}${PSep}${input1}${PSep}${input2}${PSep}${input3} >> ${GParaTable}
      echo " |-> Parameters for job "${ExpNum}" is setup."       
    else  # Machine Learning started
      if [ ! -f "${LUTable}" ]; then # lookup table is not written
#------------------------------------------------------------------------------
#       build the main inputs used by python code
        . ${fpath}/writeNMIOfiles.sh        

#------------------------------------------------------------------------------
        python ${fpath}/test_Nelder_Mead.py 1 ${Base_MLB_number} ${NMInputTable} ${NMOutputTable} ${GParaTable}  ${GPerfTable}
        Parameters=`python ${fpath}/load_and_print_parameters.py 1  `
        echo "1 -> "${ExpNum}" "${Parameters} >> ${LUTable}
        echo "1 -> "${ExpNum}" "${Parameters} >> ${LUlog}
        . ${fpath}/NM_write_param.sh
#------------------------------------------------------------------------------
      else  # lookup table is written
#------------------------------------------------------------------------------
# Init and Shrinks have to be concurrent!!!!
# code for making Init and Shrinks run concurrent.......
  #      . ${fpath}/NM_parallel_job_synCheck.sh # using for checking the status in pikle file 
#------------------------------------------------------------------------------
        BStatus=` grep "${MaxExpNum} ->" ${LUTable} `  || BStatus=" "
      #  for new parallel analysis  --------
        if [ "${BStatus}" == " " ]; then
          pid=1; IsAssigned=no
          while (( ${pid} < ${MaxExpNum}  )) ; do
            (( pid = pid + 1  ))
            if [ "${IsAssigned}" == "no" ]; then
              BStatus=` grep "${pid} ->"  ${LUTable}  ` || BStatus=" "
              if [ "${BStatus}" == " "  ]  ; then
                python ${fpath}/test_Nelder_Mead.py ${pid} ${BaseMLNMNum} ${NMInputTable} ${NMOutputTable} ${GParaTable}  ${GPerfTable} 
                Parameters=`python ${fpath}/load_and_print_parameters.py ${pid} ` 
                echo "${pid} -> "${ExpNum}" "${Parameters} >> ${LUTable}
                echo "${pid} -> "${ExpNum}" "${Parameters} >> ${LUlog}
#------------------------------------------------------------------------------
                . ${fpath}/NM_write_param.sh
#------------------------------------------------------------------------------
              fi
            fi
          done
        else
    #    for exist parallel analysis  ------------
          pid=0; IsAssigned=no 
          while (( ${pid} < ${Max_job_number} )) ; do
            (( pid = pid + 1  ))
            if [ "${IsAssigned}" == "no" ]; then
              BStatus=` grep "${pid} ->"  ${LUTable}  `
              OldExpid=`echo ${BStatus} | awk -F " " '{print $3}' `
              # check if the experiment was finished.
              expStatus=`grep ${OldExpid} ${GParaTable} | awk -F " " '{print $NF}' `
              if [ "${expStatus}" == "done" ] ; then
                if [ -f ${MLprefix}0${pid}.pickle ]; then
                  Parameters=`python ${fpath}/load_and_print_parameters.py ${pid}`
                  preStatus=`echo ${Parameters} | awk -F " " '{print $1}'`
                else
                  preStatus=" "
                fi
                jPerf=`grep ${OldExpid} ${GPerfTable} | awk -F " " '{print $2}' `

                if [ "${preStatus}" != "Init" ] ; then
                  python ${fpath}/test_Nelder_Mead.py ${pid} ${Base_MLB_number} ${OldExpid} ${jPerf}  ${NMInputTable} ${NMOutputTable} ${GParaTable}
                  Parameters=`python ${fpath}/load_and_print_parameters.py ${pid}`
                  PataStatus=`echo ${Parameters} | awk -F " " '{print $1}'  `
                  if [ "${PataStatus}" == "Shrinks" ] ; then
                    . ${fpath}/NM_param_ctl_Shrinks.sh
                  elif [ "${PataStatus}" == "Init" ] ; then
                    echo ${linesep}
                    echo "this thread is into Init status."
                    echo ${linesep}
                  else
                    . ${fpath}/NM_param_ctl_Contract.sh
                  fi
                elif [ "${preStatus}" == "Init" ]  ; then
                    . ${fpath}/NM_param_ctl_Init.sh
#------------------------------------------------------------------------------
                fi # preJobStatus is "Init"
              fi  # exp status is "done" 
            fi # job is not assigned
          done # check for all pid 
        fi
      fi 
    fi
  else # do nothing for jobs
    echo  ' |-> Continue an old run or an unfinished run!!   '
    (( id = ExpNum + BaseExpID ))
  	grep ${expidPrefix}${id}${PSep} ${GParaTable}  || { 
  	  echo "The number of Job is wrong!!!"
  	}
  fi
else
  echo  ' |-> Setup a new run!!  '
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
  expidn=0; id=0
	while (( ${expidn} < ${ExpNum} )); do # for Jobs
    (( expidn = expidn + 1))
    (( id = expidn + BaseExpID ))
    set -ex
    R1=${RANDOM}; R2=${RANDOM}; R3=${RANDOM}; R4=${RANDOM};
    R5=${RANDOM}; R6=${RANDOM}; R7=${RANDOM};
    input1=`echo "(${R1}-0)/32767*1.0" | bc -l | cut -c1-8`
    input2=`echo "(${R2}-0)/32767*1.0" | bc -l | cut -c1-8`
    input3=`echo "(${R3}-0)/32767*1.0" | bc -l | cut -c1-8`
    echo  ${expidPrefix}${id}${PSep}${input1}${PSep}${input2}${PSep}${input3} >> ${GParaTable} 
  done
fi
#------------------------------------------------------------------------------
