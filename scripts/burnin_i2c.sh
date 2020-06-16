#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/log
mkdir -p ${mountpoint}/i2c
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/i2c/${testTime}.txt"

declare -i count
count=0

out_log(){
	echo -e "[`date +%Y%m%d.%H.%M.%S`]    $1 \t $2 \t [ $3 ]" >> $LOGFILE
}

i2c_test(){
	if [[ $1 -eq 0 ]]; then
		while true
		do
			((count++))
			echo "" >> $LOGFILE
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count)" >> $LOGFILE
	
#channel 0
			ret=`i2cset -f -y 0 0x70 0x8 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0x8" "$ret" "Pass (count:$count / infinite)" 
			else
				out_log "i2cset -f -y 0 0x70 0x8" "$ret" "Failed (count:$count / infinite)"
			fi
		
			ret=`i2cget -f -y 0 0x1c 2>&1`		# 0xff
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x1c    " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0x1c    " "$ret" "Failed (count:$count / infinite)"
			fi

			ret=`i2cget -f -y 0 0x48 2>&1` 		# 0x80
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x48    " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0x48    " "$ret" "Failed (count:$count / infinite)"
			fi

#channel 1
			ret=`i2cset -f -y 0 0x70 0x9 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0x9" "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cset -f -y 0 0x70 0x9" "$ret" "Failed (count:$count / infinite)"
			fi
		
			ret=`i2cget -f -y 0 0x60 2>&1`		# 0x00
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x60    " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0x60    " "$ret" "Failed (count:$count / infinite)"
			fi

			ret=`i2cget -f -y 0 0x50 2>&1`		# 0x63 ///////
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x50    " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0x50    " "$ret" "Failed (coutn:$count / infinite)"
			fi

#channel 2
			ret=`i2cset -f -y 0 0x70 0xa 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xa" "$ret" "Pass (count:$count / infinite)" 
			else
				out_log "i2cset -f -y 0 0x70 0xa" "$ret" "Failed (count:$count / infinite)"
			fi

			ret=`i2cget -f -y 0 0x15 2>&1`		# 0x
			if [[ $? -ne 0 ]]; then
				out_log "i2cget -f -y 0 0x15    " "" "Pass (count:$count / infinite)" 
			else
				out_log "i2cget -f -y 0 0x15    " "$ret" "Failed (count:$count / infinite)" 
			fi

#channel 3
			ret=`i2cset -f -y 0 0x70 0xb 2>&1`
			if [[ $? == 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xb" "$ret" "Pass (count:$count / infinite)" 
			else
				out_log "i2cset -f -y 0 0x70 0xb" "$ret" "Failed (count:$count / infinite)"
			fi
		
			ret=`i2cget -f -y 0 0xa 2>&1`		# 0x6c
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0xa    " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0xa    " "$ret" "Failed (count:$count / infinite)"
			fi

#channel 4
			ret=`i2cset -f -y 0 0x70 0xc 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xc" "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cset -f -y 0 0x70 0xc" "$ret" "Failed (count:$count / infinite)"
			fi
		
			ret=`i2cget -f -y 0 0x74 2>&1`		# 0xff
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x74   " "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cget -f -y 0 0x74   " "$ret" "Failed (count:$count / infinite)"
			fi

#channel 5
			ret=`i2cset -f -y 0 0x70 0xd 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xd" "$ret" "Pass (count:$count / infinite)"
			else
				out_log "i2cset -f -y 0 0x70 0xd" "$ret" "Failed (count:$count / infinite)"
			fi
		
			ret=`/usr/tstp/bin/i2c/i210_test -D/dev/i2c-8 2>&1`

			echo -e "[`date +%Y%m%d.%H.%M.%S`]    /usr/tstp/bin/i2c/i210_test -D/dev/i2c-8\c" >> $LOGFILE
			echo -e "$ret" >> $LOGFILE
		done	
	else
		for((i=0;i<$1;i++))
		do
			((count++))
			echo "" >> $LOGFILE
			echo "[`date +%Y%m%d.%H.%M.%S`]    (count:$count / $1)" >> $LOGFILE

#channel 0
			ret=`i2cset -f -y 0 0x70 0x8 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0x8" "$ret" "Pass (count:$count / $1)" 
			else
				out_log "i2cset -f -y 0 0x70 0x8" "$ret" "Failed (count:$count / $1)"
			fi
		
			ret=`i2cget -f -y 0 0x1c 2>&1`		# 0xff
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x1c    " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0x1c    " "$ret" "Failed (count:$count / $1)"
			fi

			ret=`i2cget -f -y 0 0x48 2>&1` 		# 0x80
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x48    " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0x48    " "$ret" "Failed (count:$count / $1)"
			fi

#channel 1
			ret=`i2cset -f -y 0 0x70 0x9 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0x9" "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cset -f -y 0 0x70 0x9" "$ret" "Failed (count:$count / $1)"
			fi
		
			ret=`i2cget -f -y 0 0x60 2>&1`		# 0x00
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x60    " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0x60    " "$ret" "Failed (count:$count / $1)"
			fi

			ret=`i2cget -f -y 0 0x50 2>&1`		# 0x63 ///////
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x50    " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0x50    " "$ret" "Failed (count:$count / $1)"
			fi

#channel 2
			ret=`i2cset -f -y 0 0x70 0xa 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xa" "$ret" "Pass (count:$count / $1)" 
			else
				out_log "i2cset -f -y 0 0x70 0xa" "$ret" "Failed (count:$count / $1)"
			fi

			ret=`i2cget -f -y 0 0x15 2>&1`		# 0x
			if [[ $? -ne 0 ]]; then
				out_log "i2cget -f -y 0 0x15    " "" "Pass (count:$count / $1)" 
			else
				out_log "i2cget -f -y 0 0x15    " "$ret" "Failed (count:$count / $1)" 
			fi

#channel 3
			ret=`i2cset -f -y 0 0x70 0xb 2>&1`
			if [[ $? == 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xb" "$ret" "Pass (count:$count / $1)" 
			else
				out_log "i2cset -f -y 0 0x70 0xb" "$ret" "Failed (count:$count / $1)"
			fi
		
			ret=`i2cget -f -y 0 0xa 2>&1`		# 0x6c
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0xa    " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0xa    " "$ret" "Failed (count:$count / $1)"
			fi

#channel 4
			ret=`i2cset -f -y 0 0x70 0xc 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xc" "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cset -f -y 0 0x70 0xc" "$ret" "Failed (count:$count / $1)"
			fi
		
			ret=`i2cget -f -y 0 0x74 2>&1`		# 0xff
			if [[ $? -eq 0 ]]; then
				out_log "i2cget -f -y 0 0x74   " "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cget -f -y 0 0x74   " "$ret" "Failed (count:$count / $1)"
			fi

#channel 5
			ret=`i2cset -f -y 0 0x70 0xd 2>&1`
			if [[ $? -eq 0 ]]; then
				out_log "i2cset -f -y 0 0x70 0xd" "$ret" "Pass (count:$count / $1)"
			else
				out_log "i2cset -f -y 0 0x70 0xd" "$ret" "Failed (count:$count / $1)"
			fi
		
			ret=`/usr/tstp/bin/i2c/i210_test -D/dev/i2c-8 2>&1`

			echo -e "[`date +%Y%m%d.%H.%M.%S`]    /usr/tstp/bin/i2c/i210_test -D/dev/i2c-8\c" >> $LOGFILE
			echo -e "$ret" >> $LOGFILE
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}

echo "I2C LOG file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
i2c_test $1
