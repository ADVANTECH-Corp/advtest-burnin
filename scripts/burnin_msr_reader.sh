#! /bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/msr
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/msr/$1_${testTime}.txt"

Hostname=`cat /etc/hostname`

do_msr_reader() {
	rm /lib/libusb-1.0.so
	ln -s /lib/libusb-1.0.so.0.1.0 /lib/libusb-1.0.so
	IDTechSDK_Demo &
	echo "[`date +%Y%m%d.%H.%M.%S`]" >> $LOGFILE
}

echo "msr Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> cache.txt
do_msr_reader $1