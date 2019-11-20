#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/als
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/als/${testTime}.txt"

Hostname=`cat /etc/hostname`

get_als() {
	ALS=`cat /sys/devices/platform/ff130000.i2c/i2c-3/3-0053/iio:device1/als_data`
}


main() {
	declare -i count
	count=0
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			get_als
			echo "[`date +%Y%m%d.%H.%M.%S`] ALS: ${ALS} (count: $count / infinite)" >> $LOGFILE 
			sleep $2
		done
	else
		for ((i=0; i<$1;i++))
		do
			((count++))
			get_als
			echo "[`date +%Y%m%d.%H.%M.%S`] ALS: ${ALS} (count: $count / $1)" >> $LOGFILE
			sleep $2
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Get_als Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
main $1 $2


