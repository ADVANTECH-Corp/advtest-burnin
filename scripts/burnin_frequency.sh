#!/bin/bash

ROOT_DIR=`pwd`
mountpoint=$ROOT_DIR/burnin/log
mkdir -p ${mountpoint}/frequency
testTime=`date +%Y%m%d.%H.%M.%S`
LOGFILE="${mountpoint}/frequency/${testTime}.txt"

get_cpu_cur_freq() {
	CPU_FREQ=`cat /sys/devices/system/cpu/cpu$1/cpufreq/cpuinfo_cur_freq`

}
get_frequency() {
	declare -i count	
	count=0
	if [[ $1 -eq 0 ]]; then
		while true
		do                                      
                        ((count++))     
                        for j in 0 1 2 3
			do
				get_cpu_cur_freq $j
				echo "[`date +%Y%m%d.%H.%M.%S`]    CPU $j FREQ: $((CPU_FREQ/1000000)).$((CPU_FREQ%1000000))GHz (count: $count / infinite)" >> $LOGFILE
			done
                        sleep $2                                                
                done
	else	
		for ((i=0; i<$1;i++))
		do
			((count++))
			for j in 0 1 2 3                                                  
         		do                                                                     
                 		get_cpu_cur_freq $j                                            
                 		echo "[`date +%Y%m%d.%H.%M.%S`]    CPU $j FREQ: $((CPU_FREQ/1000000)).$((CPU_FREQ%1000000))GHz (count: $count / $1)" >> $LOGFILE
         		done 
			sleep $2
		done
		echo "Test is completed!!!" >> $LOGFILE
	fi
}
echo "Get_CPU_frequency Log file : ${LOGFILE}"
echo "${LOGFILE} \\" >> ./cache.txt
get_frequency $1 $2
