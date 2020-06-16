#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/show_pic_lvds
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/show_pic_lvds/${testTime}.txt"
IMAGES_DIR="/home/root/advtest/data/image"

LVDS_DEV=fb0
LVDS_FB="/sys/class/graphics/${LVDS_DEV}"
LVDS_BLANK="${LVDS_FB}/blank"

HDMI_DEV=fb2
HDMI_FB="/sys/class/graphics/${HDMI_DEV}"
HDMI_BLANK="${HDMI_FB}/blank"

show_pic_weston() {
	if [ -z "$RUNTIMEDIR" ]; then                   
		XDG_RUNTIME_DIR=/var/run/user/1000/     
	fi                                              
	weston-image $1&     
	PID=$!                                          
	sleep 5
	kill $PID 
}
show_pic() {
	declare -i count	
	count=0
	images=`ls ${IMAGES_DIR}`
	if [[ $2 -eq 0 ]]; then
		while true
		do
			((count++))
			killall fbi 2>/dev/null 1>/dev/null
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			for i in $images		
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / infinite)" >> $LOGFILE
				fbi -d ${1} -T 1 ${IMAGES_DIR}/$i &>/dev/null
				sleep 5
#				DISPLAY=:0 display.im6 -delay 5 -loop 1 ${IMAGES_DIR}/$i &>/dev/null
#				show_pic_weston ${IMAGES_DIR}/$i 1>/dev/null 2>/dev/null
			done
		done	
	else 
		for ((j=0; j<$2; j++))
		do
			((count++))
			killall fbi 2>/dev/null 1>/dev/null
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
			for i in $images
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / $2)" >> $LOGFILE
				fbi -d ${1} -T 1 ${IMAGES_DIR}/$i &>/dev/null
				sleep 5
#				DISPLAY=:0 display.im6 -delay 5 -loop 1 ${IMAGES_DIR}/$i &>/dev/null
#				show_pic_weston ${IMAGES_DIR}/$i 1>/dev/null 2>/dev/null
			done
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
show_pic_lvds() {
	#show_pic "/dev/fb0" $1
	pushd ../bin/ >/dev/null
	./display & >/dev/null
	popd >/dev/null
	echo "Test is completed!!!" >> $LOGFILE
}
show_pic_hdmi() {
	echo -n 0 > $HDMI_BLANK	
	sleep 1
	show_pic "/dev/fb2" $1
}
echo "Show_pic_lvds Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
show_pic_lvds $1
#show_pic_hdmi $1
