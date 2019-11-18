#!/bin/bash


ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log

mkdir -p ${mountpoint}/udisk
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/udisk/$1_${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

read_test_res() {
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE	
}
file_RW_test() {
	declare -i count	
	count=0
	if [[ $3 != "" ]]; then
		if [[ $2 -eq 0 ]]; then
			while true
			do
				#fsck.vfat -v -a -w /dev/$1
				TMPDIR=`mktemp -d`
				umount "/dev/$1" &>/dev/null
				sleep 3 && sync
				if `mount "/dev/$1" $TMPDIR &>/dev/null` ;then
					sync
					((count++))
					#if [[ "$Hostname" == *"imsse01"* ]]; then
					#	if [[ -e "/dev/$1" ]]; then
					#		TMPDIR1=`mktemp -d`
					#		mount -t auto /dev/$1 $TMPDIR1
					#	fi
					#fi
				
					path=`mount | grep $1 | awk '{print $3}'`

					if [[ $path == "" ]]; then
						read_test_res "$3($1) (count:$count / infinite): /dev/$1 cannot be mounted correctly" "Failed"
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_$1
						else
							TMPDIR=$path/burnin_test_$1
						fi
					
						mkdir $TMPDIR			
					echo $fifoStr > "$TMPDIR/test.txt"
					ReadStr=`cat $TMPDIR/test.txt`
					if [ $fifoStr == $ReadStr ]; then
						read_test_res "$3($1) : Read/Write" "Pass (count:$count / infinite)"
					else
						read_test_res "$3($1) : Read/Write" "Failed (count:$count / infinite)"
						fi
					fi
					
				
					sleep 1 && sync
				
					#if [[ "$Hostname" == *"imsse01"* ]]; then
					#	if [[ $path != "" ]]; then
					#		umount $TMPDIR1 &>> /dev/null
					#		sync&& umount "/dev/$1" &>/dev/null
					#		rm -rf $TMPDIR1
					#	fi
					#fi
				else
					read_test_res "$3($1) : /dev/$1 cannot be mounted correctly" "Failed"
				fi
				
				rm -rf $TMPDIR
				umount $TMPDIR &> /dev/null
				umount "/dev/$1" &> /dev/null			
				sleep 1 && sync	
			done	
		else			
			for((i=1;i<=$2;i++)) do
				((count++))
				TMPDIR=`mktemp -d`
				umount "/dev/$1" &>/dev/null
				sleep 3 && sync
				if `mount "/dev/$1" $TMPDIR &>/dev/null` ;then
					sync
					#if [[ "$Hostname" == *"imsse01"* ]]; then
					#	if [[ -e "/dev/$1" ]]; then
					#		TMPDIR1=`mktemp -d`
					#		mount -t auto /dev/$1 $TMPDIR1
					#	fi
					#fi
				
					path=`mount | grep $1 | awk '{print $3}'`

					if [[ $path == "" ]]; then
						read_test_res "$3($1) : /dev/$1 cannot be mounted correctly" "Failed (count:$count / $2)"
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_$1
						else
							TMPDIR=$path/burnin_test_$1
						fi
					
						mkdir $TMPDIR			
					echo $fifoStr > "$TMPDIR/test.txt"
					ReadStr=`cat $TMPDIR/test.txt`
					if [ $fifoStr == $ReadStr ]; then
						read_test_res "$3($1) : Read/Write" "Pass (count:$count / $2)"
					else
						read_test_res "$3($1) : Read/Write" "Failed (count:$count / $2)"
						fi
					fi
					
				
					sleep 1 && sync
				
					#if [[ "$Hostname" == *"imsse01"* ]]; then
					#	if [[ $path != "" ]]; then
					#		umount $TMPDIR1 &>> /dev/null
					#		sync&& umount "/dev/$1" &>/dev/null
					#		rm -rf $TMPDIR1
					#	fi
					#fi
				else
					read_test_res "$3($1) : /dev/$1 cannot be mounted correctly" "Failed count:$count / $2)"
				fi
				
				rm -rf $TMPDIR
				umount $TMPDIR &> /dev/null
				umount "/dev/$1" &> /dev/null			
				sleep 1 && sync	
			done
			echo "Test is completed!!!" >> $LOGFILE
		fi		
	fi
}
echo "uDisk Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
file_RW_test $1 $2 $3
