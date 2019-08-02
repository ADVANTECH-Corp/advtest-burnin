#!/bin/bash

mountpoint=/home/root/advtest/burnin/log
mkdir -p ${mountpoint}/wifi_ap
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/wifi_ap/${testTime}.txt"

Hostname=`cat /etc/hostname`

wifi_ap_test() {	

	TEST_IP=$2
	PASSWORD=$3
	
	DRIVERTYPE=nl80211
	if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
		INTERFACE=ap0
	else
		INTERFACE=wlan0
	fi
	
	Google=216.239.32.6
	Gateway=192.168.0.1
	WEBSERVER=$Google

		
	declare -i count                                                        
	declare -i total_fail
	declare -i total_pass
	count=0
	total_fail=0
	total_pass=0
	
	echo "[`date +%Y%m%d.%H.%M.%S`]    ping IP \"$TEST_IP\" " >> $LOGFILE	

	
	if [[ $1 -eq 0 ]]; then		
		while true;do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			(ping $TEST_IP -I $INTERFACE -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
			log_result=`tail -n 2 $LOGFILE`			
			if [[ $log_result == *"1 received"* ]]; then
				((total_pass++))
			else
				((total_fail++))
			fi			
			echo ">> pass/fail/count:$total_pass/$total_fail/$count" >> $LOGFILE
			echo "" >> $LOGFILE
			sleep 1	
		done
	else			
		for((i=1;i<=$1;i++)) do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE
			(ping $TEST_IP -I $INTERFACE -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
			log_result=`tail -n 2 $LOGFILE`			
			if [[ $log_result == *"1 received"* ]]; then
				((total_pass++))
			else
				((total_fail++))
			fi			
			echo ">> pass/fail/count:$total_pass/$total_fail/$count" >> $LOGFILE
			echo "" >> $LOGFILE
			sleep 1	
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi	     
}

echo "Wifi Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
wifi_ap_test $1 $2
