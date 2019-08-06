#!/bin/bash

ROOT_DIR="$(cd ../; pwd)"
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/temperature
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/temperature/${testTime}.txt"

Hostname=`cat /etc/hostname`

get_temperator() {
	SOC_TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
	GPU_TEMP=`cat /sys/class/thermal/thermal_zone1/temp`
	BAT_TEMP=`cat /sys/class/thermal/thermal_zone2/temp`
}
get_temperature() {
	declare -i count
	count=0
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			get_temperator
			echo "[`date +%Y%m%d.%H.%M.%S`] temperature: SOC:${SOC_TEMP},GPU:${GPU_TEMP},BATTERY:${BAT_TEMP} (count: $count / infinite)" >> $LOGFILE 
			sleep $2
		done
	else
		for ((i=0; i<$1;i++))
		do
			((count++))
			get_temperator
			echo "[`date +%Y%m%d.%H.%M.%S`] temperature: SOC:${SOC_TEMP},GPU:${GPU_TEMP},BATTERY:${BAT_TEMP} (count: $count / $1)" >> $LOGFILE
			sleep $2
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Get_temperature Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
get_temperature $1 $2
