#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/show_pic_lvds
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/show_pic_lvds/${testTime}.txt"
IMAGES_DIR="/home/root/advtest/burnin/data/image"

LVDS_DEV=fb0
LVDS_FB="/sys/class/graphics/${LVDS_DEV}"
LVDS_BLANK="${LVDS_FB}/blank"

HDMI_DEV=fb2
HDMI_FB="/sys/class/graphics/${HDMI_DEV}"
HDMI_BLANK="${HDMI_FB}/blank"

Hostname=`cat /etc/hostname`
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
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			for i in $images		
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / infinite)" >> $LOGFILE
				if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
					fbi -d ${1} -T 1 ${IMAGES_DIR}/$i &>/dev/null
					fbi_id=`pgrep fbi`
					sleep 1
					kill -9 $fbi_id
#				DISPLAY=:0 display.im6 -delay 5 -loop 1 ${IMAGES_DIR}/$i &>/dev/null
				
				#show_pic_weston ${IMAGES_DIR}/$i 1>/dev/null 2>/dev/null
				else
					timeout 5s gst-launch-1.0 filesrc location=${IMAGES_DIR}/$i ! decodebin ! videoconvert ! imagefreeze ! imxv4l2sink device=$1 &>/dev/null
				fi
			done
		done	
	else 
		for ((j=0; j<$2; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
			for i in $images
			do
				echo "[`date +%Y%m%d.%H.%M.%S`]    show picture: ${IMAGES_DIR}/$i (count:$count / $2)" >> $LOGFILE
				if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
					fbi -d ${1} -T 1 ${IMAGES_DIR}/$i &>/dev/null
					fbi_id=`pgrep fbi`
					sleep 1
					kill -9 $fbi_id

#				DISPLAY=:0 display.im6 -delay 5 -loop 1 ${IMAGES_DIR}/$i &>/dev/null
				
				#show_pic_weston ${IMAGES_DIR}/$i 1>/dev/null 2>/dev/null
				else 
					timeout 5s gst-launch-1.0 filesrc location=${IMAGES_DIR}/$i ! decodebin ! videoconvert ! imagefreeze ! imxv4l2sink device=$1 &>/dev/null
				fi
			done
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
show_pic_lvds() {
	if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
		show_pic "/dev/fb0" $1
	else
show_pic "/dev/video16" $1
	fi
}
show_pic_hdmi() {
	if [[ "$Hostname" == *"imx6q-cv1"* ]]; then
		show_pic "/dev/fb0" $1
	else
		show_pic "/dev/video18" $1
	fi
}
echo "Show_pic_lvds Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
show_pic_lvds $1 &>/dev/null
show_pic_hdmi $1 >/dev/null
