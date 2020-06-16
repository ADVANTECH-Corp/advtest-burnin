#!/bin/bash
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/hpattern
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/hpattern/${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

#!/bin/bash

Hostname=`cat /etc/hostname`

exit_h_pattern() {
	kill $h_pid &>/dev/null
	trap - SIGINT
}

do_hpattern() {
	scripts_advantech-hpattern.w105 &
	h_pid=$!
	trap 'exit_h_pattern' SIGINT
	
	echo "[`date +%Y%m%d.%H.%M.%S`]" >> $LOGFILE
}
echo "hpattern Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_hpattern $1

