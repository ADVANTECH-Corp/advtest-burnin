#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/hpattern

testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/hpattern/${testTime}.txt"

Hostname=`cat /etc/hostname`

declare -i count	
count=0
do_hpattern() {
		if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
			./scripts/advantech-hpattern.w105  2>/dev/null
		else
			systemctl stop xserver-nodm.service
			echo 0 > /sys/class/vtconsole/vtcon1/bind
											 
			advantech-hpattern &
		fi
		
		echo "[`date +%Y%m%d.%H.%M.%S`]" >> $LOGFILE
}
echo "hpattern Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_hpattern $1





