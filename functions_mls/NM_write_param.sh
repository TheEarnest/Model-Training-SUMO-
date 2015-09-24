#!/bin/bash
input1=`echo ${Parameters} | awk -F " " '{print $2}'  `
input2=`echo ${Parameters} | awk -F " " '{print $3}'  `
input3=`echo ${Parameters} | awk -F " " '{print $4}'  `
echo  ${ExpNum}${PSep}${input1}${PSep}${input2}${PSep}${input3} >>  ${GParaTable}
echo " |-> Parameters for job "${ExpNum}" is setup."   
IsAssigned=yes
#--------------------------------------------------------------
