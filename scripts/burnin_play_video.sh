#!/bin/bash
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/play_video
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/play_video/${testTime}.txt"
VIDEO_FILE="${ROOT_DIR}/data/video/test.mp4"

export GSTL=gst-launch-1.0
export PLAYBIN=playbin
export GPLAY=gplay-1.0
export GSTINSPECT=gst-inspect-1.0

play_video() {
	declare -i count
	count=0
	echo -n 0 > /sys/class/graphics/fb0/blank
	sleep 1
	if [[ $2 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			$GSTL $PLAYBIN uri=file://$1 video-sink="overlaysink display-slave=true" 1>/dev/null 2>/dev/null
			sleep 5
		done
	else
		for ((j=0; j<$2; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
			$GSTL $PLAYBIN uri=file://$1 video-sink="overlaysink display-slave=true" 1>/dev/null 2>/dev/null
			sleep 5
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}

play_video $VIDEO_FILE $1
