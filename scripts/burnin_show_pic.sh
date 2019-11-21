#!/bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/show_pic
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/show_pic/${testTime}.txt"
IMAGES_DIR=$ROOT_DIR/data/image
Hostname=`cat /etc/hostname`

sudo cp /home/linaro/.Xauthority /root/.Xauthority
export DISPLAY=:0.0

show_pic() {
	declare -i count	
	count=0
	images=`ls ${IMAGES_DIR}`
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			for i in $images		
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / infinite)" >> $LOGFILE
				gpicview ${IMAGES_DIR}/$i & >/dev/null
				PID=$!
				sleep 5
				kill -9 $PID 2>&1 > /dev/null				
				
			done
		done	
	else 
		for ((j=0; j<$1; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE
			for i in $images
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / $1)" >> $LOGFILE
				gpicview ${IMAGES_DIR}/$i & >/dev/null
				PID=$!
				sleep 5
				kill -9 $PID 2>&1 > /dev/null			
			done
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Show_pic_lvds Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
show_pic $1
