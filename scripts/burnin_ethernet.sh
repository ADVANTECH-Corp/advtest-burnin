#!/bin/bash
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/ethernet
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/ethernet/${testTime}.txt"

ethernet_test() {
	declare -i count
	count=0
	if [[ ! -e "${ROOT_DIR}/scripts/burnin_ping_IP_config.sh" ]]; then 
		WEBSERVER=`ifconfig $1 |grep 'inet addr' |cut -d : -f2 | awk 'BEGIN {FS="."} {print $1 "." $2 "." $3 "."}'`1
		echo "Don't edit Ping IP test configuration in main menu, currently use default $1 ping IP \"$WEBSERVER\" " 
		echo "[`date +%Y%m%d.%H.%M.%S`]    use default $1 ping IP \"$WEBSERVER\" " >> $LOGFILE
	else
		WEBSERVER=`cat ${ROOT_DIR}/scripts/burnin_ping_IP_config.sh |grep "$1_PING_IP" |awk 'BEGIN {FS="="} {print $2}'` 
		echo "Currently use $1 ping IP \"$WEBSERVER\" that has been configured in ./scripts/burnin_ping_IP_config.sh "
		echo "[`date +%Y%m%d.%H.%M.%S`]    use $1 ping IP \"$WEBSERVER\" " >> $LOGFILE
	fi

	if [[ $2 -eq 0 ]]; then
		while true;do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			(ping $WEBSERVER -c 1 2>&1 | tee -a $LOGFILE) 2>&1 > /dev/null
		done
	else	
		for((i=1;i<=$2;i++)) do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
			(ping $WEBSERVER -c 1 2>&1 | tee -a $LOGFILE) 2>&1 > /dev/null
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Ethernet Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
ethernet_test $1 $2
