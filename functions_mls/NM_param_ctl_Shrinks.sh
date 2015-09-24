#!/bin/bash
#------------------------------------------------------------------------------
# parameters control factors
set -ex
#------------------------------------------------------------------------------
 . setup/nametable
#------------------------------------------------------------------------------
Prefix=`echo ${ExpNum} | cut -c1-3 `
sexpid=`echo ${ExpNum} | cut -c4-6 `
#------------------------------------------------------------------------------
# save old data
ShrinksLog=${home}/"Shrinks_"`date +%Y_%m%d_%H%M_%S`
mkdir ${ShrinksLog}
files=`ls ${home}`
for file in ${files}; do
  if [ -f ${file} ]; then
    cp ${home}/${file} ${ShrinksLog}
  fi
done
cp -rf ${home}/log ${ShrinksLog}
rm ${MLprefix}* ${GParaTable} ${GPerfTable}
cp ${ShrinksLog}/*.pickle ${home}
sid=0
#------------------------------------------------------------------------------
# rebuild job list
while (( ${sid} < ${Base_MLB_number} + ${Max_job_number} )) ; do
  (( newexpid = sexpid + sid - 1 ))
  SExpNum=${Prefix}${newexpid}
  Parameters=`python ${fpath}/load_and_print_parameters.py ${pid} ${sid}`
  input1=`echo ${Parameters} | awk -F " " '{print $2}'  `
  input2=`echo ${Parameters} | awk -F " " '{print $3}'  `
  input3=`echo ${Parameters} | awk -F " " '{print $4}'  `
  Paras2ParaTable=${SExpNum}${PSep}${input1}${PSep}${input2}${PSep}${input3}
  if [ "${sid}" == "0" ]; then
    Paras2ParaTable=`grep ${input1} ${ShrinksLog}/${GParaTable}`
    echo  ${Paras2ParaTable} >> ${GParaTable}
    SExpNum=`echo ${Paras2ParaTable} | awk -F " " '{print $1}' `
    Perf2PerTable=`grep ${SExpNum} ${ShrinksLog}/${GPerfTable}`
    echo ${Perf2PerTable} >> ${GPerfTable}
  else
    echo  ${Paras2ParaTable} >> ${GParaTable}
  fi
  echo " |-> Parameters for job "${SExpNum}" is setup."  
  (( sid = sid + 1 ))
done
rm ${home}/*.pickle
NBStatus=${pid}" -> "${SExpNum}" "${Parameters}
echo ${NBStatus} >> ${LUlog}
ed -s ${LUTable}  <<EOF1
g/${BStatus}/s/${BStatus}/${NBStatus}/
w
q
EOF1
IsAssigned=yes
#--------------------------------------------------------------
