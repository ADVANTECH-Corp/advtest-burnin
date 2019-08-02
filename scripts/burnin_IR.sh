#!/bin/bash

testTime=`date +%Y%m%d.%H.%M.%S`
mountpoint=/home/root/advtest/burnin/log
mkdir -p ${mountpoint}/IR
LOGFILE="${mountpoint}/IR/${testTime}.txt"


IR_PWM_SYSFS="/sys/class/pwm/pwmchip1/pwm0"
IR_DEV="/dev/ttymxc4"

infrared_test() {
	declare -i count	
	count=0	
	
	echo 17857 > "${IR_PWM_SYSFS}/period"
	echo 8928 > "${IR_PWM_SYSFS}/duty_cycle"
	echo 1 > "${IR_PWM_SYSFS}/enable"
	stty -F ${IR_DEV} 1200

	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinte)" >> $LOGFILE
			echo "test" > ${IR_DEV}
			sleep 1
		done
	else	
		for ((j=0; j<$1; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE
			echo "test" > ${IR_DEV}
			sleep 1
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi    
}

echo "I/O Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
infrared_test $1
