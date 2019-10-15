#!/bin/bash
#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/cpueater
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/cpueater/${testTime}.txt"

echo "CPUeater Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
if [[ $1 -eq 0 ]]; then
	echo "Test is Failed!!!" >> $LOGFILE
else
	stress -c $1
	echo "[`date +%Y%m%d.%H.%M.%S`] $1 process" >> $LOGFILE
	echo "Test is completed!!!" >> $LOGFILE
fi



