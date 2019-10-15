#! /bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/msr
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/msr/$1_${testTime}.txt"

Hostname=`cat /etc/hostname`

do_msr_reader() {
	IDTechSDK_Demo &
	echo "[`date +%Y%m%d.%H.%M.%S`]" >> $LOGFILE
}

echo "msr Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_msr_reader $1