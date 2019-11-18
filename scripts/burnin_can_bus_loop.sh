#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/can_bus
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/can_bus/${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"
#TMPDIR=`mktemp -d`

read_test_res() {
	#echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2"
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE	
}
file_RW_test() {
	declare -i count	
	count=0	

	if [[ $3 != "" ]]; then
		if [[ $2 -eq 0 ]]; then
			for((i=1;i>$2;i++)) do
				((count++))
			### echo "reset can bus"
			./scripts/can_bus/reset.sh
			### echo "can bus loop "
			./scripts/can_bus/cantest/cantest > res_can
			RES_TEMP=`cat res_can`
			### echo "$RES_TEMP"
			RES_CAN=`cat res_can | grep OK`
				if [ -z "$RES_CAN"  ]; then
					if [ "$3" == "1" ]; then
						echo "$i:0can bus loop test fail"
					fi
					echo "$i:can bus loop test fail!" >> $LOGFILE
					RESULT=1
				else
					if [ "$3" == "1" ]; then
						echo "$i:can bus loop pass!"
					fi
					echo "$i:can bus loop test pass!" >> $LOGFILE
					RESULT=0
				fi
			 
			rm -f res_can
				sleep 2
			done
		else
			for((i=1;i<=$2;i++)) do
				((count++))

				### echo "reset can bus"
				./scripts/can_bus/reset.sh
				### echo "can bus loop "
				./scripts/can_bus/cantest/cantest > res_can
				RES_TEMP=`cat res_can`
				### echo "$RES_TEMP"
				RES_CAN=`cat res_can | grep OK`
					if [ -z "$RES_CAN"  ]; then
						if [ "$3" == "1" ]; then
							echo "$i:can bus loop test fail"
						fi
						echo "$i:can bus loop test fail!" >> $LOGFILE
						RESULT=1
					else
						if [ "$3" == "1" ]; then
							echo "$i:can bus loop test pass!"
						fi
						echo "$i:can bus loop is pass!!!" >> $LOGFILE
						RESULT=0
					fi
				 
				rm -f res_can
				sleep 2
			done
			if [ "$3" == "1" ]; then
				echo "Test is completed!!!"
			fi
			echo "Test is completed!!!" >> $LOGFILE
		fi
	fi
}
echo "can_bus Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt

file_RW_test $1 $2 $3
