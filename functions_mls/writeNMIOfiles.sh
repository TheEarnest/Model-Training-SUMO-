#!/bin/bash
#------------------------------------------------------------------------------
# write the files for NM methods
# NMInputTable="ML_NMInputs"
# NMOutputTable="ML_NMIOTable" 
#------------------------------------------------------------------------------

IsEOF=.FALSE. ; nline=0
rm -f ${NMInputTable}
rm -f ${NMOutputTable}
while [ ${IsEOF} == .FALSE. ] ; do
  (( nline = nline + 1 ))
  JobParam=`cat ${GParaTable} | sed -n "${nline}p"  `
  JobPerfe=`cat ${GPerfTable} | sed -n "${nline}p"  `
  if [ "${JobParam}" == ""  ] ; then
    IsEOF=.TRUE.
  else
    JExpid=`echo ${JobParam} | awk -F " " '{print $1}'  `
    JParam=`echo ${JobParam} | awk -F " " '{print $2" "$3" "$4}'  `
    JPerfe=`echo ${JobPerfe} | awk -F " " '{print $2}'  `
    echo ${JExpid}" "${JParam} >> ${NMInputTable}
    echo ${JExpid}" "${JPerfe}" "${JParam} >> ${NMOutputTable}
  fi
done
#------------------------------------------------------------------------------
