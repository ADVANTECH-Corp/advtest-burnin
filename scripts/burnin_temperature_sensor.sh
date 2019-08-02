#!/bin/bash

#mountpoint=`mount |grep "/dev/mmcblk0p2" |awk '{print $3}'`
#if [[ $mountpoint == "" ]]; then
#	echo "The log partition has not been mounted, exit"
#	exit 0
#fi

mountpoint=/home/root/advtest/burnin/log
mkdir -p ${mountpoint}/temperature_sensor
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/temperature_sensor/${testTime}.txt"

Hostname=`cat /etc/hostname`

get_temperator() {
	SYSTEM_TEMP=`i2cget -f -y 2 0x4d`
        
}
get_temperature() {
	declare -i count	
	count=0
	if [[ $1 -eq 0 ]]; then
		while true
		do                                      
                        ((count++))     
                        get_temperator                                          
                        echo "[`date +%Y%m%d.%H.%M.%S`]    temperature: ${SYSTEM_TEMP} (count: $count / infinite)" >> $LOGFILE 
                        sleep $2                                                
                done
	else	
		for ((i=0; i<$1;i++))
		do
			((count++))
			get_temperator
                        echo "[`date +%Y%m%d.%H.%M.%S`]    temperature: ${SYSTEM_TEMP} (count: $count / $1)" >> $LOGFILE
			sleep $2
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Get_temperature Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
get_temperature $1 $2
