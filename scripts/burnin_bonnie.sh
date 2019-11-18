#!/bin/bash


mkdir -p ${mountpoint}/bonnie
testTime=`date +%Y%m%d.%H.%M.%S`
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
LOGFILE="${mountpoint}/bonnie/${testTime}.txt"

bonnie_test() {
	declare -i count	
	count=0	
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / infinte)" >> $LOGFILE
			bonnie++ -d ./ -m project -u root -s 100 -r 50 &>> $LOGFILE
		done
	else	
		for ((j=0; j<$1; j++))
		do
			((count++))
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE
                  	bonnie++ -d ./ -m project -u root -s 100 -r 50 &>> $LOGFILE
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi	     
}

echo "I/O Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
bonnie_test $1
