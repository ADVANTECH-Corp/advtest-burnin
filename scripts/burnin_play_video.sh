#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/play_video
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/play_video/${testTime}.txt"

VIDEO_FILE="/home/root/advtest/burnin/data/video/MIB3.mp4"

export GSTL=gst-launch-1.0
export PLAYBIN=playbin
	


play_video() {
        declare -i count
        count=0
	if [[ $3 -eq 1 ]]; then
        if [[ $2 -eq 0 ]]; then
            while true
            do
                ((count++))
                #echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
				echo "[`date +%Y%m%d.%H.%M.%S`]     play video: ${VIDEO_FILE}/$i (count:$count / infinite)" >> $LOGFILE
				$GSTL $PLAYBIN uri=file://$1 video-sink="imxv4l2sink device=/dev/video18" 1>/dev/null 2>/dev/null

				
                sleep 3

             done
        else
            for ((j=0; j<$2; j++))
            do
                ((count++))
                #echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
				echo "[`date +%Y%m%d.%H.%M.%S`]     play video: ${VIDEO_FILE}/$i (count:$count / $2)" >> $LOGFILE
				$GSTL $PLAYBIN uri=file://$1 video-sink="imxv4l2sink device=/dev/video18" 1>/dev/null 2>/dev/null     
				
                sleep 3
            done
            echo "Test is completed!!!" >> $LOGFILE
        fi
	else
		 if [[ $2 -eq 0 ]]; then
                	while true
                	do
                        	((count++))
                        	echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
                        	#$GSTL $PLAYBIN uri=file://$1 1>/dev/null 2>/dev/null
                        	$GSTL $PLAYBIN uri=file://$1 video-sink="imxv4l2sink device=/dev/video17" 1>/dev/null 2>/dev/null
                        	#$GSTL $PLAYBIN uri=file://$1 video-sink="imxv4l2sink device=/dev/video18"
                        	sleep 5
                	done
        	else
                	for ((j=0; j<$2; j++))
                	do
                        	((count++))
                        	echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $2)" >> $LOGFILE
                        	$GSTL $PLAYBIN uri=file://$1 1>/dev/null 2>/dev/null
                        	sleep 5
                	done
                	echo "Test is completed!!!" >> $LOGFILE
        	fi
	fi
}
echo "Play_video Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt

#HDMI=1
#play_video $VIDEO_FILE $1 $HDMI &
HDMI=0
play_video $VIDEO_FILE $1 $HDMI &
