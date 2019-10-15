#! /bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/camera
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/camera/$1_${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

read_test_res() {
	echo "[`date +%Y%m%d.%H.%M.%S`] $1 $2" >> $LOGFILE
}

sudo echo "Camera Log file : ${LOGFILE}"
sudo echo "${LOGFILE} \\" >> ./cache.txt


export DISPLAY=:0.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/gstreamer-1.0

gst-launch-1.0 rkv4l2src device=/dev/video$1 ! video/x-raw,format=NV12,width=1280,height=768, framerate=30/1 ! videoconvert ! autovideosink &

sleep 3
read -p "Is the preview window show up? : " result
echo "[`date +%Y%m%d.%H.%M.%S`] $2 test result : ${result}" >> $LOGFILE

ps -C gst-launch-1.0 -o pid=|xargs kill -9