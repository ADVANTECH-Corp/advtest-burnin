#!/bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/play_video
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/play_video/${testTime}.txt"
VIDEO_FILE=$ROOT_DIR/data/video/bbb.mp4

sudo cp /home/linaro/.Xauthority /root/.Xauthority
export DISPLAY=:0.0

play_video() {
	declare -i count
	count=0
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`] play video: ${VIDEO_FILE} (count:$count / infinite)" >> $LOGFILE
			#mplayer ${VIDEO_FILE} >/dev/null
			gst-launch-1.0 playbin uri=file:///${VIDEO_FILE} >/devnull
			sleep 1
		done
	else
		for ((j=0; j<$1; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`] play video: ${VIDEO_FILE} (count:$count / $1)" >> $LOGFILE
			echo ${VIDEO_FILE}
			#mplayer ${VIDEO_FILE} >/dev/null
			gst-launch-1.0 playbin uri=file:///${VIDEO_FILE} >/dev/null
			sleep 1
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Play_video Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
play_video $1
