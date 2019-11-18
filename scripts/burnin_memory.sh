#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/memory
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/memory/${testTime}.txt"
RAMDISK="/tmp"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"


read_test_res() {
	#echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2"
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE	
}
memory_test() {	
	declare -i count	
	count=0
	if [[ $1 -eq 0 ]]; then
		while true				
		do
			((count++))
			echo $fifoStr > "$RAMDISK/$i.txt"
			#printf "%s" "W" && sleep 1
			sleep 1			
			ReadStr=`cat $RAMDISK/$i.txt`			
			#printf "\b%s" "R" && sleep 1
			sleep 1
			if [ ${fifoStr} == ${ReadStr} ]; then
				#printf "\b%s" "P"
				read_test_res "Memory : Read/Write" "Pass (count:$count / infinite)"
			else
				#printf "\b%s" "F"
				read_test_res "Memory : Read/Write" "Failed (count:$count / infinite)"
			fi
			sleep 1
		done		
	else	
		for ((i=0;i<$1;i++))				
		do
			((count++))
			echo $fifoStr > "$RAMDISK/$i.txt"
			#printf "%s" "W" && sleep 1
			sleep 1			
			ReadStr=`cat $RAMDISK/$i.txt`			
			#printf "\b%s" "R" && sleep 1
			sleep 1
			if [ ${fifoStr} == ${ReadStr} ]; then
				#printf "\b%s" "P"
				read_test_res "Memory : Read/Write" "Pass (count:$count / $1)"
			else
				#printf "\b%s" "F"
				read_test_res "Memory : Read/Write" "Failed (count:$count / $1)"
			fi
			sleep 1
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi		
}
echo "Memory Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
memory_test $1
