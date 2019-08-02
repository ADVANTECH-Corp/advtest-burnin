#!/bin/bash


mountpoint=/home/root/advtest/burnin/log
mkdir -p ${mountpoint}/cpueater
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/cpueater/${testTime}.txt"

declare -i count	
count=0
do_cpueater() {
	for ((i=0;i<10;i++))
#	for ((i=0;i<$1;i++))
	do                                                                              
        	((count++))                                                             
        	echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / 10)" >> $LOGFILE
		./scripts/cpueater &>/dev/null
	done
	echo "Test is completed!!!" >> $LOGFILE
}
echo "CPUeater Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_cpueater $1

