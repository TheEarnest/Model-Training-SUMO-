#!/bin/bash
#------------------------------------------------------------------------------
# parameters control factors
set -ex
#---------------
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

