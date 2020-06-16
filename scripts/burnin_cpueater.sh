#!/bin/bash
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/cpueater
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/cpueater/${testTime}.txt"

kill_stress_process() {
	pidofcat=`ps | grep "stress-ng" | head -n 1 | awk '{print $1}'`
	if [ ! -z "$pidofcat" -a "$pidofcat" != " " ]; then
			kill -9 $pidofcat &>/dev/null
			ps &>/dev/null
	fi
}

do_cpueater() {
	kill_stress_process
	stress-ng -c $1 &
	echo "[`date +%Y%m%d.%H.%M.%S`] (process : $1)" >> $LOGFILE
	echo "Test is completed!!!" >> $LOGFILE
}
echo "CPUeater Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_cpueater $1

