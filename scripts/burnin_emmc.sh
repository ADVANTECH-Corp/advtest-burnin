#!/bin/bash

ROOT_DIR=`pwd`
echo ${ROOT_DIR}
mountpoint=$ROOT_DIR/burnin/log
sudo mkdir -p ${mountpoint}/emmc
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/emmc/${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"
#TMPDIR=`mktemp -d`

format_emmc(){
	sudo dd if=/dev/zero of=/dev/$1  bs=1M  count=10
	sudo echo -e "n\np\n1\n2048\n20479\nw" | sudo fdisk /dev/$1
	sync && sleep 1
	sudo partprobe /dev/$1p9
	sudo mkfs.ext4 /dev/$1p9
}

read_test_res() {
	#echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2"
	echo "[`date +%Y%m%d.%H.%M.%S`]    $1 $2" >> $LOGFILE
}

rw_test_core() {
	sudo echo $fifoStr > "$1/test.txt"
	ReadStr=`sudo cat $1/test.txt`
	if [ $fifoStr == $ReadStr ]; then
		read_test_res "$3($1) : Read/Write" "Pass (count:$4 / $5)"
	else
		read_test_res "$3($1) : Read/Write" "Failed (count:$4 / $5)"
	fi
}
# 1:block 2:mount folder 3:current index 4:total count
file_rw_test_core() {
	if [[ $4 -eq 0 ]]; then
		total_count="infinite"
	else
		total_count=$4
	fi
	if [[ ! -e "/dev/$1p9" ]]; then
		read_test_res "$2($1p9) : /dev/$1p9 no exist" "Failed (count:$3 / $total_count)"
	else
		path=`mount | grep $1p9 | awk '{print $2}'`
		if [[ $path == "" ]]; then
			path="/tmp"
			TMPDIR=$path/burnin_test_$1p9
			sudo mkdir -p $TMPDIR > /dev/null
			sudo mount -t ext4 /dev/$1p9 $TMPDIR > /dev/null
			if [ $? -ne 0 ]; then
				read_test_res "$2($1p9) : /dev/$1p9 cannot be mounted correctly" "Failed (count:$3 / $total_count)"
			else
				rw_test_core $TMPDIR $1 $2 $3 $total_count
			fi
			sudo umount $TMPDIR >> /dev/null
			sudo rm -rf $TMPDIR
		else
			if [[ $path == "/" ]]; then
				TMPDIR=burnin_test_$1p9
			else
				TMPDIR=$path/burnin_test_$1p9
			fi
			sudo mkdir -p $TMPDIR >/dev/null
			rw_test_core $TMPDIR $1 $2 $3 $total_count
			sudo rm -rf $TMPDIR
		fi
	fi
	sleep 2
	sync
}

file_RW_test() {
	declare -i count
	count=0
	
	if [[ $3 == "" ]]; then
		echo "Test is failed!!!" >> $LOGFILE
		return 0;
	fi

	if [[ $2 -eq 0 ]]; then
		while true
		do
			((count++))
			# 1:block 2:mount folder 3:current index 4:total count
			file_rw_test_core $1 $3 $count $2
		done
	else
		for((i=1;i<=$2;i++));
		do
			((count++))
			file_rw_test_core $1 $3 $count $2
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
	sync && sudo umount "/dev/$1p9" &>/dev/null && sync && sleep 1
}
sudo echo "eMMC Log file : ${LOGFILE}"
sudo echo "${LOGFILE} \\" >> ./cache.txt
#format_emmc $1
file_RW_test $1 $2 $3 
