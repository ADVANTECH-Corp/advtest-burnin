#!/bin/bash
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/comport
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/comport/${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

kill_test_port() {
	pidofcat=`ps | grep "cat /dev/${1}" | head -n 1 | awk '{print $1}'`
	if [ ! -z "$pidofcat" -a "$pidofcat" != " " ]; then
			kill -9 $pidofcat &>/dev/null
			ps &>/dev/null
	fi
}

configure_uart() {
	chmod o+rw /dev/${1}
	stty -F /dev/${1} 115200 #cs7 -parodd -parenb -cstopb -icanon -iexten -ixon -ixoff -crtscts -cread -clocal -echo -echoe -echok -echoctl
}

file_RW_test() {
	
	# Uart rx port
	uart_rx_port=ttymxc$2 #RX port
	kill_test_port $uart_rx_port

	sleep 1 && sync

	declare -i count
	count=0
	configure_uart $uart_rx_port
	cat /dev/$uart_rx_port & >/dev/null
	cat_pid=$!
	sleep 3 && sync
	
	# Uart tx port
	uart_tx_port=2  #there are ttymxc2 or ttymxc3 have to be tested.
	if [ $2 -eq 2 ]; then
		uart_tx_port=ttymxc3
	else
		uart_tx_port=ttymxc2
	fi
	kill_test_port $uart_tx_port
	configure_uart $uart_tx_port

	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			sync
			echo "1234567890abcdefghijklmnopqrstuvwxyz!" >/dev/$uart_tx_port
			echo "[`date +%Y%m%d.%H.%M.%S`] transfer from /dev/$uart_tx_port to /dev/$uart_rx_port (count:$count / infinte)" >> $LOGFILE
			sleep 1 && sync
		done	
	else			
		for((i=1;i<=$1;i++)) do
			((count++))
			sync
			echo "1234567890abcdefghijklmnopqrstuvwxyz!" >/dev/$uart_tx_port
			echo "[`date +%Y%m%d.%H.%M.%S`] transfer from /dev/$uart_tx_port to /dev/$uart_rx_port (count:$count / $1)" >> $LOGFILE
			sleep 1 && sync
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
	disown $cat_pid
	kill -9 $cat_pid &>/dev/null
}
echo "Comport Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
file_RW_test $1 $2

