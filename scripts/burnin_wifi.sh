#!/bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/wifi
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/wifi/${testTime}.txt"

Hostname=`cat /etc/hostname`

wifi_test() {	

	NETWORK=$2
	PASSWORD=$3
	
	DRIVERTYPE=nl80211
	if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
		INTERFACE=sta0
	else
		INTERFACE=wlan0
	fi
	Google=216.239.32.6
	Gateway=192.168.0.1
	if [ -z "$4" ]; then
	    WEBSERVER=$WEBSERVER
	else
		WEBSERVER=$4
	fi

	killall wpa_supplicant &>/dev/null
	sleep 1
	wpa_passphrase $NETWORK $PASSWORD > /tmp/wpa.conf
	wpa_supplicant -D $DRIVERTYPE -c/tmp/wpa.conf -i$INTERFACE -B 

	sleep 5
	
	udhcpc -i $INTERFACE
		
	route add -net default gw $Gateway dev $INTERFACE
	
	sleep 1
		
	declare -i count
	declare -i total_fail
	declare -i total_pass
	count=0
	total_fail=0
	total_pass=0

	echo "Don't edit Ping IP test configuration in main menu, currently use default $INTERFACE ping IP \"$WEBSERVER\" "
	echo "[`date +%Y%m%d.%H.%M.%S`]    use default $INTERFACE ping IP \"$WEBSERVER\" " >> $LOGFILE	
	
	if [[ $1 -eq 0 ]]; then		
		while true;do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			(ping $WEBSERVER -I $INTERFACE -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
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
			(ping $WEBSERVER -I $INTERFACE -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
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
wifi_test $1 $2 $3 $4
