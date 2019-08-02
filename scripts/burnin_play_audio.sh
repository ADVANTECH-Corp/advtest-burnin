#!/bin/bash


mountpoint=/home/root/advtest/burnin/log

mkdir -p ${mountpoint}/play_audio
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/play_audio/${testTime}.txt"
AUDIO_DIR="/home/root/advtest/burnin/data/audio"

play_audio() {
	declare -i count	
	count=0
	audios=`ls ${AUDIO_DIR}`
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinite)" >> $LOGFILE
			for i in $audios		
			do			
				echo "[`date +%Y%m%d.%H.%M.%S`]    play audio: ${AUDIO_DIR}/$i (count:$count / infinite)" >> $LOGFILE
#				aplay ${AUDIO_DIR}/$i &>/dev/null			
				aplay -D hw:0,0 ${AUDIO_DIR}/$i &>/dev/null
#				aplay -D plughw:0,0 ${AUDIO_DIR}/$i &>/dev/null
				sleep 1
			done			
		done
	else	
		for ((j=0; j<$1; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE
			for i in $audios		
			do			
				echo "[`date +%Y%m%d.%H.%M.%S`]    play audio: ${AUDIO_DIR}/$i (count:$count / $1)" >> $LOGFILE
#				aplay ${AUDIO_DIR}/$i &>/dev/null			
				aplay -D hw:0,0 ${AUDIO_DIR}/$i &>/dev/null
				#aplay -D plughw:0,0 ${AUDIO_DIR}/$i &>/dev/null
				sleep 1
			done				
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Play_audio Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
play_audio $1
