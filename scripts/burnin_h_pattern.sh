#! /bin/bash

ROOT_DIR="$(cd ../; pwd)"
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/hpattern
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/hpattern/$1_${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

do_hpattern() {
	if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
			./scripts/advantech-hpattern.w105  2>/dev/null
	else
			#systemctl stop xserver-nodm.service
			#echo 0 > /sys/class/vtconsole/vtcon1/bind

			advantech_hpattern &
	fi
	echo "[`date +%Y%m%d.%H.%M.%S`]" >> $LOGFILE

	sleep 1
	read -p "Do you'd like to exit H pattern test ? (y) : " result
	if [ "$result" = "y" ]; then
			ps -C advantech-hpattern -o pid=|xargs kill -9
			sudo systemctl restart display-manager
	fi
}

echo "hpattern Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_hpattern $1