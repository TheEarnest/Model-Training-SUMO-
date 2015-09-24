#!/bin/bash
#------------------------------------------------------------------------------
# parameters control factors
set -ex
#---------------
if [ -f ${MLprefix}0${pid}.pickle ]; then
  Parameters=`python ${fpath}/load_and_print_parameters.py ${pid}`
  PataStatus=`echo ${Parameters} | awk -F " " '{print $1}'`
fi

echo ${pid}" -> "${ExpNum}" "${PataStatus} >> ${LUlog}
PExpid=`python ${fpath}/load_and_check_parameters.py ${pid} -1 | awk -F " " '{print $NF}' `
Parameters=`python ${fpath}/load_and_check_parameters.py ${pid} 0`
RExpid=`echo ${Parameters} | awk -F " " '{print $2}'`
if [ "${PExpid}" != "${RExpid}"  ]; then
  PJobParam=`grep ${PExpid} ${NMInputTable} `
  RJobParam=`echo ${Parameters} | awk -F " " '{print $2" "$4" "$5" "$6}' `
  ed -s ${NMInputTable}  <<EOFE
g/${PJobParam}/s/${PJobParam}/${RJobParam}/
w
q
EOFE
  PJobParam=`grep ${PExpid} ${NMOutputTable} `
  RJobParam=`echo ${Parameters} | awk -F " " '{print $2" "$3" "$4" "$5" "$6}' `
  ed -s ${NMOutputTable}  <<EOFIO
g/${PJobParam}/s/${PJobParam}/${RJobParam}/
w
q
EOFIO

fi

python ${fpath}/test_Nelder_Mead.py ${pid} ${Base_MLB_number} ${OldExpid} ${jPerf}  ${NMInputTable} ${NMOutputTable} ${GParaTable}

Parameters=`python ${fpath}/load_and_print_parameters.py ${pid}`
PataStatus=`echo ${Parameters} | awk -F " " '{print $1}' `
NBStatus=${pid}" -> "${ExpNum}" "${Parameters}
echo ${NBStatus} >> ${LUlog}
ed -s ${LUTable}  <<EOF1
g/${BStatus}/s/${BStatus}/${NBStatus}/
w
q
EOF1


#------------------------------------------------------------------------------
 . ${fpath}/NM_write_param.sh
#------------------------------------------------------------------------------
