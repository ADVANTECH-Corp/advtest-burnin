#!/bin/bash
mountpoint=/home/root/advtest/burnin/log

mkdir -p ${mountpoint}/comport
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/comport/${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
systemctl stop serial-getty@ttymxc2.service
fi

read_test_res() {
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE	
}
file_RW_test() {

	UART_PORT=$2

	pidofcat=`ps -o pid,args= -C cat | grep "/dev/$UART_PORT" | head -n 1 | awk '{print $1}'`

	if [ ! -z "$pidofcat" -a "$pidofcat" != " " ]; then
			kill -9 $pidofcat &>/dev/null
			ps &>/dev/null
	fi

	if [ -f $UART_PORT.txt ]; then
	   rm $UART_PORT.txt
	fi
	sleep 1 && sync

	declare -i count	
	count=0
	chmod o+rw /dev/$UART_PORT
	
	stty -F /dev/$UART_PORT 115200 cs7 -parodd -parenb -cstopb -icanon -iexten -ixon -ixoff -crtscts -cread -clocal -echo -echoe -echok -echoctl

	touch "$UART_PORT.txt" && sync

	cat /dev/$UART_PORT > $UART_PORT.txt & >/dev/null
	cat_pid=$!

	sleep 3 && sync

#	if [[ $2 != "" ]]; then
		if [[ $1 -eq 0 ]]; then
			while true
			do
				((count++))
				sync
				
				echo "1234567890abcdefghijklmnopqrstuvwxyz!" >/dev/$UART_PORT
				sleep 5 && sync

				get_num=`grep -wc 1234567890abcdefghijklmnopqrstuvwxyz! $UART_PORT.txt`

				read_test_res "$3($1) : Read/Write" "(data:$get_num count:$count / infinite)"

				sleep 1 && sync	
			done	
		else			
			for((i=1;i<=$2;i++)) do
				((count++))
				sync
				
				echo "1234567890abcdefghijklmnopqrstuvwxyz!" >/dev/$UART_PORT
				sleep 5 && sync

				get_num=`grep -wc 1234567890abcdefghijklmnopqrstuvwxyz! $UART_PORT.txt`

				read_test_res "$3($1) : Read/Write" "(data:$get_num count:$count / infinite)"
		
				sleep 1 && sync	
			done
			echo "Test is completed!!!" >> $LOGFILE
		fi
		disown $cat_pid
		kill -9 $cat_pid &>/dev/null

#	fi
}
echo "uDisk Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt


if [[ "$Hostname" == "magmon-imx6q-dms-ba16" ]]; then
	file_RW_test $1 "ttyUSB1"
else
	file_RW_test $1 "ttymxc2"
fi

