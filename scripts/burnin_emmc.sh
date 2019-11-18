#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/emmc
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/emmc/${testTime}.txt"
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
			while true							
			do
				((count++))	
				
				if [[ ! -e "/dev/$1p2" ]]; then			
					read_test_res "$3($1) : /dev/$1p2 no exist" "Failed (count:$count / infinite)"
				else
				
					path=`mount | grep $1p2 | awk '{print $3}'`

					if [[ $path == "" ]]; then
						path="/tmp"	
						TMPDIR=$path/burnin_test_$1
						mkdir -p $TMPDIR	
						
						mount -t ext4 /dev/$1p2 $TMPDIR	 >/dev/null
						if [ $? -ne 0 ]; then
							read_test_res "$3($1) : /dev/$1 cannot be mounted correctly" "Failed (count:$count / infinite)"
						else
							echo $fifoStr > "$TMPDIR/test.txt"
							ReadStr=`cat $TMPDIR/test.txt`
							if [ $fifoStr == $ReadStr ]; then
								read_test_res "$3($1) : Read/Write" "Pass (count:$count / infinite)"
							else
								read_test_res "$3($1) : Read/Write" "Failed (count:$count / infinite)"
							fi
						fi
						umount $TMPDIR >> /dev/null
						rm -rf $TMPDIR
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_$1
						else
							TMPDIR=$path/burnin_test_$1
						fi
						
						mkdir -p $TMPDIR >/dev/null			
						echo $fifoStr > "$TMPDIR/test.txt"
						ReadStr=`cat $TMPDIR/test.txt`
						if [ $fifoStr == $ReadStr ]; then
							read_test_res "$3($1) : Read/Write" "Pass (count:$count / infinite)"
						else
							read_test_res "$3($1) : Read/Write" "Failed (count:$count / infinite)"
						fi
						rm -rf $TMPDIR
					fi	
				fi
				sleep 2
				sync
			done			
		else			
			for((i=1;i<=$2;i++)) do
				((count++))
				if [[ ! -e "/dev/$1p2" ]]; then			
					read_test_res "$3($1) : /dev/$1p2 no exist" "Failed (count:$count / $2)"
				else
						
					path=`mount | grep $1p2 | awk '{print $3}'`

					if [[ $path == "" ]]; then
						path="/tmp"	
						TMPDIR=$path/burnin_test_$1
						mkdir -p $TMPDIR	
						
						mount -t ext4 /dev/$1p2 $TMPDIR	 >/dev/null
						if [ $? -ne 0 ]; then
							read_test_res "$3($1) : /dev/$1 cannot be mounted correctly" "Failed (count:$count / $2)"
						else
							echo $fifoStr > "$TMPDIR/test.txt"
							ReadStr=`cat $TMPDIR/test.txt`
							if [ $fifoStr == $ReadStr ]; then
								read_test_res "$3($1) : Read/Write" "Pass (count:$count / $2)"
							else
								read_test_res "$3($1) : Read/Write" "Failed (count:$count / $2)"
							fi
						fi
						umount $TMPDIR >> /dev/null
						rm -rf $TMPDIR
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_$1
						else
							TMPDIR=$path/burnin_test_$1
						fi
						
						mkdir -p $TMPDIR >/dev/null			
						echo $fifoStr > "$TMPDIR/test.txt"
						ReadStr=`cat $TMPDIR/test.txt`
						if [ $fifoStr == $ReadStr ]; then
							read_test_res "$3($1) : Read/Write" "Pass (count:$count / $2)"
						else
							read_test_res "$3($1) : Read/Write" "Failed (count:$count / $2)"
						fi
						rm -rf $TMPDIR
					fi	
				fi
				sleep 2
				sync

			done
			echo "Test is completed!!!" >> $LOGFILE
		fi
		sync && umount "/dev/$1" &>/dev/null && sync && sleep 1
	fi
}
echo "eMMC Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
file_RW_test $1 $2 $3
