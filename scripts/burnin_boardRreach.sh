#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/boardRreach
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/boardRreach/$1_${testTime}.txt"

ethernet_test() {
	declare -i count                                                        
	declare -i total_fail
	declare -i total_pass
	count=0
	total_fail=0
	total_pass=0
		
	if [[ "$4" == "1" ]]; then
		echo 0 >  /sys/devices/soc0/soc/2100000.aips-bus/2188000.ethernet/2188000.ethernet:07/tja1100/phy_master
		echo "BoardR-reach slave"  >> $LOGFILE
		
		HOST_IP=`cat /home/root/advtest/burnin/scripts/burnin_ping_IP_config.sh |grep "$3_boardR_IP" |awk 'BEGIN {FS="="} {print $2}'`
		eth_IP=`cat /home/root/advtest/burnin/scripts/burnin_ping_IP_config.sh |grep "$1_boardR_IP" |awk 'BEGIN {FS="="} {print $2}'` 	
		echo "Slave: Currently use $eth_IP ping IP $HOST_IP that has been configured in ./scripts/burnin_ping_IP_config.sh "
		echo "[`date +%Y%m%d.%H.%M.%S`]    use $eth_IP ping $HOST_IP" >> $LOGFILE		
	else 
		echo "BoardR-reach master"  >> $LOGFILE
		echo 1 >  /sys/devices/soc0/soc/2100000.aips-bus/2188000.ethernet/2188000.ethernet:07/tja1100/phy_master
		eth_IP=`cat /home/root/advtest/burnin/scripts/burnin_ping_IP_config.sh |grep "$3_boardR_IP" |awk 'BEGIN {FS="="} {print $2}'`
		HOST_IP=`cat /home/root/advtest/burnin/scripts/burnin_ping_IP_config.sh |grep "$1_boardR_IP" |awk 'BEGIN {FS="="} {print $2}'` 	
		echo "Master: Currently use $eth_IP ping IP $HOST_IP that has been configured in ./scripts/burnin_ping_IP_config.sh "
		echo "[`date +%Y%m%d.%H.%M.%S`]    use $eth_IP ping $HOST_IP" >> $LOGFILE
	fi	
	
	ifconfig $1 down
	sleep 1
	ifconfig $1 $eth_IP up
	sleep 1

	if [[ $2 -eq 0 ]]; then
		while true;do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			(ping $HOST_IP -I $1 -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
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
		for((i=1;i<=$2;i++)) do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
			(ping $HOST_IP -I $1 -c 1 | tee -a $LOGFILE) 2>&1 > /dev/null
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
echo "Ethernet Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
ethernet_test $1 $2 $3 $4
