#!/bin/bash

#ROOT_DIR="$(cd ../; pwd)"
ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/ssd
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/ssd/$1_${testTime}.txt"
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

Hostname=`cat /etc/hostname`

format_ssd(){
	umount "/dev/${1}1" &> /dev/null
	sudo dd if=/dev/zero of=/dev/$1  bs=1M  count=10
	sudo echo -e "n\np\n1\n2048\n20479\nw" | sudo fdisk /dev/$1
	sync && sleep 1
	sudo partprobe /dev/${1}1
	sudo mkfs.ext4 /dev/${1}1
}

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
				TMPDIR=`mktemp -d`
				umount "/dev/${1}1" &>/dev/null
				sleep 3 && sync
				if `mount "/dev/${1}1" $TMPDIR &>/dev/null` ;then
					sync
					((count++))
					
					path=`mount | grep ${1}1 | awk '{print $3}'`
					if [[ $path == "" ]]; then
						read_test_res "$3(${1}1) (count:$count / infinite): /dev/${1}1 cannot be mounted correctly" "Failed"
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_${1}1
						else
							TMPDIR=$path/burnin_test_${1}1
						fi
						mkdir $TMPDIR
					echo $fifoStr > "$TMPDIR/test.txt"
					ReadStr=`cat $TMPDIR/test.txt`
					if [ $fifoStr == $ReadStr ]; then
						read_test_res "$3(${1}1) : Read/Write" "Pass (count:$count / infinite)"
					else
						read_test_res "$3(${1}1) : Read/Write" "Failed (count:$count / infinite)"
						fi
					fi
					sleep 1 && sync
				else
					read_test_res "$3($1) : /dev/${1}1 cannot be mounted correctly" "Failed"
				fi
				
				rm -rf $TMPDIR
				umount $TMPDIR &> /dev/null
				umount "/dev/${1}1" &> /dev/null
				sleep 1 && sync	
			done	
		else			
			for((i=1;i<=$2;i++)) do
				((count++))
				TMPDIR=`mktemp -d`
				umount "/dev/${1}1" &>/dev/null
				sleep 3 && sync
				if `mount "/dev/${1}1" $TMPDIR &>/dev/null` ;then
					sync
					path=`mount | grep ${1}1 | awk '{print $3}'`

					if [[ $path == "" ]]; then
						read_test_res "$3(${1}1) : /dev/${1}1 cannot be mounted correctly" "Failed (count:$count / $2)"
					else
						if [[ $path == "/" ]]; then
							TMPDIR=burnin_test_${1}1
						else
							TMPDIR=$path/burnin_test_${1}1
						fi
						mkdir $TMPDIR
					echo $fifoStr > "$TMPDIR/test.txt"
					ReadStr=`cat $TMPDIR/test.txt`
					if [ $fifoStr == $ReadStr ]; then
						read_test_res "$3(${1}1) : Read/Write" "Pass (count:$count / $2)"
					else
						read_test_res "$3(${1}1) : Read/Write" "Failed (count:$count / $2)"
						fi
					fi
					sleep 1 && sync
				else
					read_test_res "$3($1) : /dev/${1}1 cannot be mounted correctly" "Failed count:$count / $2)"
				fi
				rm -rf $TMPDIR
				umount $TMPDIR &> /dev/null
				umount "/dev/${1}1" &> /dev/null
				sleep 1 && sync	
			done
			echo "Test is completed!!!" >> $LOGFILE
		fi
	fi
}
echo "uDisk Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
format_ssd $1
file_RW_test $1 $2 $3
