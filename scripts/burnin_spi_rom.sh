#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/spi
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/spi/${testTime}.txt"
read_test_res() {
	#echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2"
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE	
}

function Test_Function
{
	declare -i count	
	count=0
	DEVICE=$2

	if [ ! -e "$DEVICE" ]; then
		read_test_res "${DEVICE} : not found"
		return 1
	fi
	if [[ $1 -eq 0 ]]; then
		while true							
		do
			((count++))					
						
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`
			if [[ $READ == "HELLOWORLD!" ]];then
				WRITE_DATA="GOODMORNING"
			else
				WRITE_DATA="HELLOWORLD!"
			fi
			#echo "Write = $WRITE_DATA"
	
			echo "$WRITE_DATA" > $DEVICE
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`
	
			#echo "Read = $READ"
			if [[ $READ == $WRITE_DATA ]];then
				read_test_res "$3($1) : Read/Write" "Pass (count:$count / infinite)"
			else
				read_test_res "$3($1) : Read/Write" "Failed (count:$count / infinite)"
			fi
			sleep 1
		done
	else	
		for ((i=0; i<$1;i++))
		do
			((count++))
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`
			if [[ $READ == "HELLOWORLD!" ]];then
				WRITE_DATA="GOODMORNING"
			else
				WRITE_DATA="HELLOWORLD!"
			fi
			#echo "Write = $WRITE_DATA"
	
			echo "$WRITE_DATA" > $DEVICE
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`
	
			#echo "Read = $READ"
			if [[ $READ == $WRITE_DATA ]];then
				read_test_res "$3($1) : Read/Write" "Pass (count:$count / $1)"
			else
				read_test_res "$3($1) : Read/Write" "Failed (count:$count / $1)"
			fi
			sleep 1
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi	
	
}


echo "SPI Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
Test_Function $1 $2 $3
