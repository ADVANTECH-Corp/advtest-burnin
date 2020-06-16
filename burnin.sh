#!/bin/bash 
# DMS-SA37
Ver=1.0.0
LANG=C
LANGUAGE="en_US.UTF-8"
app_root_dir=`pwd`

if [ $USER != "root" ]
then
	echo "is not root ?"
	exit
fi

declare -A mmc_type_group
for i in `ls /sys/bus/mmc/devices/`
do
	mmc_type_group[$i]=`cat /sys/bus/mmc/devices/$i/type`
done

return_emmc_dev() {
for i in "${!mmc_type_group[@]}"
do
	if [[ "${mmc_type_group[$i]}" == "MMC" ]];then
		echo | ls /sys/bus/mmc/devices/$i/block/
	fi
done
}
return_sd_dev() {
for i in "${!mmc_type_group[@]}"
do
	if [[ "${mmc_type_group[$i]}" == "SD" ]];then
		echo | ls /sys/bus/mmc/devices/$i/block/
	fi
done
}

declare -A udisk_content_group
declare -A udisk_group
for i in `ls /sys/bus/usb/devices/`
do
	udisk_content_group[$i]=`ls /sys/bus/usb/devices/$i/host*/target*:0:0/*:0:0:0/block 2>&1`
done

return_udisk_dev() {
for i in "${!udisk_content_group[@]}" 
do
	#echo $i
	#echo ${udisk_content_group[$i]}
	if [[ "${udisk_content_group[$i]}" == sd* ]];then
		udisk_group[$i]="${udisk_content_group[$i]}"
	fi
done
}

emmcdev=`return_emmc_dev`
sddev=`return_sd_dev`
return_udisk_dev

end_test() {
	echo "Finish."
}

h_pattern() {
	exit_h_parttern=0
	declare -i h_count
	#h_count=0
	while true;do
		#echo -ne "$h_count H "
		for coln in  39 30 31 32 33 34 35 36 37
		do
			#echo -ne "H"
			echo -ne "\e[${coln}mH"
			usleep $h_delay
		done
		#h_count=h_count+1
	done
}

exit_h_pattern() {
	kill $h_pid &>/dev/null
	trap - SIGINT
	exit_h_parttern=1
	print_menu_main
}

emmc_init() {
	umount /dev/$1p1 &>/dev/null
	sync && sleep 1
	emmcpart=`fdisk -l /dev/$1 |grep "$1p1"`
	if [[ $emmcpart == "" ]]; then
	#if [[ ! -e "/dev/$1p1" ]]; then
		echo "Create eMMC partition"
		sfdisk --force -D -uM /dev/$1 &>/dev/null << EOF
1,200,83
EOF
	
		sync && sync && sleep 1
		mkfs.ext4 /dev/$1p1 &>/dev/null
		sync && sync && sleep 1
	else
		echo "eMMC partition exist" 
	fi
}

udisk_init() {
	if [[ ${#udisk_group[@]} -eq 0 ]];then
		echo "udisk no exist"
		udisk_exist=0
	else
		udisk_exist=1
		for i in "${!udisk_group[@]}"
		do
			echo "udisk ${udisk_group[$i]} exist"
		done
	fi
}

log_partition_init() {
	if [[ ! -e "/dev/$1p2" ]]; then
		echo "Create log partition"
		fdisk /dev/$1 &>/dev/null << EOF
n
p
2
+1024M
+2048M
w
EOF
		partprobe
		sync && sync && sleep 1
		mkfs.ext4 /dev/$1p2 &>/dev/null
		sync && sync && sleep 1
		mkdir -p /usr/advtest/tool/burnin/log/
		echo "Mount log partition to /usr/advtest/tool/burnin/log"
		mount /dev/$1p2 /usr/advtest/tool/burnin/log &>/dev/null
	else
		echo "log partition exist"
		mountpoint=`mount |grep "/dev/${1}p2" |awk '{print $3}'`
		if [[ $mountpoint == "" ]]; then
			mkdir -p /usr/advtest/tool/burnin/log/
			echo "Mount log partition to /usr/advtest/tool/burnin/log"
			mount /dev/$1p2 /usr/advtest/tool/burnin/log &>/dev/null
		else
			echo "The log partition has been mounted on the $mountpoint"
		fi
		
	fi

}

log_range=`fdisk -l |grep "Disk $emmcdev:" |awk '{print $3}'`
log_rangemax=`expr $log_range - 1054`
log_partition_change() {
	if [[ -e "/dev/$1p2" ]]; then
		mountpoint=`mount |grep "/dev/${1}p2" |awk '{print $3}'`
		if [[ $mountpoint != "" ]]; then
			read -p "Do you want to delete the current log partition(\"/dev/$1p2\") (Warning:Make sure you have a backup) (Y/N) " res
			case $res in 
				Y|y|"")
					umount /dev/$1p2 &>/dev/null
					fdisk /dev/$1 &>/dev/null << EOF
d
2
w
EOF
					partprobe
				echo "delete \"/dev/$1p2\" partition succeed"
					while true
					do
						read -p "Please enter the size(M) of the partition you want(range: 1 ~ $log_rangemax) " size
						if [[ $size == +([0-9]) ]] && [[ $size -ge 1 ]] && [[ $size -le $log_rangemax ]];then
							echo "Are operating Please wait..."
							fdisk /dev/$1 &>/dev/null << EOF
n
p
2
+1024M
+${size}M
w
EOF
							partprobe
							sync && sync && sleep 1
							mkfs.ext4 /dev/$1p2 &>/dev/null
							sync && sync && sleep 1
							mkdir -p /usr/advtest/tool/burnin/log/
							echo "Mount log partition to /usr/advtest/tool/burnin/log"
							mount /dev/$1p2 /usr/advtest/tool/burnin/log &>/dev/null
							echo "change log_partition succeed"
							pause 'Press any key to return to the main menu...'
							break
						else
							echo "Your input is illegal, please enter again"
						fi
					done
					;;
				*)
					echo "change log_partition failed"
					pause 'Press any key to return to the main menu...'
					return
					;; 
			esac		
		else
			read -p "Do you want to delete the current log partition(\"/dev/$1p2\") (Warning:Make sure you have a backup) (Y/N) " res
			case $res in 
				Y|y|"")
					fdisk /dev/$1 &>/dev/null << EOF
d
2
w
EOF
					partprobe
					echo "delete \"/dev/$1p2\" partition succeed"
					while true
					do
						read -p "Please enter the size(M) of the partition you want(range: 1 ~ $log_rangemax) " size
						if [[ $size == +([0-9]) ]] && [[ $size -ge 1 ]] && [[ $size -le $log_rangemax ]];then
							echo "Are operating Please wait..."
							fdisk /dev/$1 &>/dev/null << EOF
n
p
2
+1024M
+${size}M
w
EOF
							partprobe
							sync && sync && sleep 1
							mkfs.ext4 /dev/$1p2 &>/dev/null
							sync && sync && sleep 1
							mkdir -p /usr/advtest/tool/burnin/log/
							echo "Mount log partition to /usr/advtest/tool/burnin/log"
							mount /dev/$1p2 /usr/advtest/tool/burnin/log &>/dev/null
							echo "change log_partition succeed"
							pause 'Press any key to return to the main menu...'
							break
						else
							echo "Your input is illegal, please enter again"
						fi
					done
						;;
				*)
					echo "change log_partition failed"
					pause 'Press any key to return to the main menu...'
					return
					;;
			esac
		fi
	else
		while true
		do
			read -p "Please enter the size(M) of the partition you want(range: 1 ~ $log_rangemax) " size
			if [[ $size == +([0-9]) ]] && [[ $size -ge 1 ]] && [[ $size -le $log_rangemax ]];then
				echo "Are operating Please wait..."
				fdisk /dev/$1 &>/dev/null << EOF
n
p
2
+1024M
+${size}M
w
EOF
				partprobe
				sync && sync && sleep 1
				mkfs.ext4 /dev/$1p2 &>/dev/null
				sync && sync && sleep 1
				mkdir -p /usr/advtest/tool/burnin/log/
				echo "Mount log partition to /usr/advtest/tool/burnin/log"
				mount /dev/$1p2 /usr/advtest/tool/burnin/log &>/dev/null
				echo "change log_partition succeed"
				pause 'Press any key to return to the main menu...'
				break
			else
				echo "Your input is illegal, please enter option again"
			fi
		done
	fi
}

audio_init() {
	amixer cset numid=5,iface=MIXER,name='Headphone Playback Volume' 127 &>/dev/null
}

system_init() {
	clear
	stty erase '^H'
	stty erase '^?'
	echo "wait ... "
	emmc_init $emmcdev
	udisk_init
	#log_partition_init $emmcdev
#	audio_init
	enptest=$(ifconfig -a | grep eth[^0] | awk '{print $1}')
	if [[ "$enptest" == "" ]] ; then
	   enptest=$(ifconfig -a | grep enp | awk '{print $1}')
	fi
	eths=$(ifconfig -a | grep Ethernet | awk '{print $1;}')
	for i in ${eths[@]}; do
		ifconfig $i down 2>/dev/null 1>/dev/null
	done
}

print_menu_main() {
	echo 
	echo -e "\e[39m"
	echo "Test script Version : $Ver"
	echo "=========================================="
	echo "(0)	Run the pre-defined all-test list"
	echo "(1)	Run the self-defined test list"
	echo "(2)	Add test items in self-defined test list"
	echo "(3)	Check the test items in self-defined test list"
	echo "(4)	Clear all test items in self-defined test list"
	echo "(5) 	Stop the current running test processes"
	echo "(6)	Edit the WiFi test configuration"
	echo "(7)	Edit Ping IP test configuration"
	echo "(8)	Dynamic view the log file"
	echo "(9)	Re-create the log partition"
	echo "(E/e)	exit the main menu"
	echo "=========================================="
}
print_menu_self_defined() {
	echo 
	echo -e "\e[39m"
	echo "Please add test items in self-defined test list"
	echo "=========================================="
	echo "(0)	CPU test"
	echo "(1)	I/O test"
	echo "(2)	Memory test"
	echo "(3)	eMMC test"
	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"
	echo "(6) 	Wifi test"
	echo "(7)	Show picture to LVDS"
	echo "(8)	Play music to speaker"
	echo "(9)	Run H pattern test"
	echo "(10)	Get system temperature"
	echo "(11)	Get CPU frequency"
#	echo "(12)	I2C test"
	echo "(13)	COM port test"
	echo "(14)	Check the test items in self-defined test list"
	echo "(15)	Clear all test items in self-defined test list"
	echo "(E/e)	exit the self-defined test list menu"
	echo "=========================================="
}
pause() {
	read -n 1 -p "$*" INP
	if [[ $INP != '' ]] ; then
		echo -ne '\b \n'
	fi
}

is_correct_config="true"
check_system_config() {
	is_correct_config="true"
	if [[ $1 == "-enable" ]]; then
		if [[ ! -e "${app_root_dir}/scripts/burnin_wifi_config.sh" ]]; then
			echo "No wifi SSID or PASSWORD is currently configured, please run \"Edit the WiFi test configuration\" option of main menu"
			is_correct_config="false"
			return
		else
			SSID=`cat ${app_root_dir}/scripts/burnin_wifi_config.sh |grep 'SSID' |cut -c 6-`
			PASSWORD=`cat ${app_root_dir}/scripts/burnin_wifi_config.sh |grep 'PASSWORD' |cut -c 10-`
			if [[ $SSID == "" ]]; then
				echo "Current wifi SSID is empty,please run \"Edit the WiFi test configuration\" option of main menu"
				is_correct_config="false"
				return
			elif [[ ${#PASSWORD} -lt 8 ]]; then
				echo "Current wifi PASSWORD length is less than 8,please run \"Edit the WiFi test configuration\" option of main menu"
				is_correct_config="false"
				return
			else
				echo "Currently use wifi \"$SSID\" that has been configured in ./scripts/burnin_wifi_config.sh"
				is_correct_config="true"
			fi
		fi
		
		ps |grep 'udhcpc -i wlan0' |awk '{print $1;}' |xargs kill -9 &>/dev/null
		ps |grep 'wpa_supplicant' |awk '{print $1;}' |xargs kill -9 &>/dev/null
		ifconfig wlan0 down &>/dev/null
		ifconfig wlan0 up &>/dev/null
		# Disable RFKill
		if which rfkill > /dev/null; then
			rfkill unblock all
		fi
		wpa_passphrase "$SSID" "$PASSWORD" > /wpa.conf
		wpa_supplicant -Dnl80211 -c/wpa.conf -iwlan0 -B
		
		udhcpc wlan0 &>/dev/null
		is_correct_config="true"
		
		#for((i=0;i<2;i++)) do
		#	udhcpc -i wlan0 -n &>/dev/null
		#	netIP=`ifconfig wlan0 |grep 'inet addr' |cut -d : -f2 | awk '{print $1}'`
		#	if [[ $netIP == "" ]]; then
		#		if [[ $i -eq 1 ]]; then
		#			echo "wlan0 failed to get to IP,Please check the network connection or cancel wifi test"
		#			is_correct_config="false"
		#			return
		#		else
		#			continue
		#		fi
		#	else
		#		echo "wlan0 IP: $netIP"
		#		is_correct_config="true"
		#		break
		#	fi
		#done
	fi
	
	if [[ $3 == "-enable" ]]; then
		ps |grep "udhcpc -i eth0" |awk '{print $1;}' |xargs kill -9 &>/dev/null
#		ifconfig eth0 down &>/dev/null
		ifconfig eth0 up &>/dev/null
		for((i=0;i<2;i++)) do
			udhcpc -i eth0 -n &>/dev/null
			netIP=`ifconfig eth0 |grep 'inet addr' |cut -d : -f2 | awk '{print $1}'`
			if [[ $netIP == "" ]]; then
				if [[ $i -eq 1 ]]; then
					echo "eth0 failed to get to IP,Please check the network connection or cancel eth0 ethernet test"
					is_correct_config="false"
					return
				else
					continue
				fi
			else
				echo "eth0 IP: $netIP"
				is_correct_config="true"
				break
			fi
		done
	fi

	if [[ $5 == "-enable" ]]; then
		ps |grep "udhcpc -i $enptest" |awk '{print $1;}' |xargs kill -9 &>/dev/null
#		ifconfig $enptest down &>/dev/null
		ifconfig $enptest up &>/dev/null
		for((i=0;i<2;i++)) do
			udhcpc -i $enptest -n &>/dev/null
			netIP=`ifconfig $enptest |grep 'inet addr' |cut -d : -f2 | awk '{print $1}'`
			if [[ $netIP == "" ]]; then
				if [[ $i -eq 1 ]]; then
					echo "$enptest failed to get to IP,Please check the network connection or cancel $enptest ethernet test"
					is_correct_config="false"
					return
				else
					continue
				fi
			else
				echo "$enptest IP: $netIP"
				is_correct_config="true"
				break
			fi
		done
	fi
}

is_self_defined_config="true"
do_test_self_defined() {
	is_self_defined_config="true"
	while [[ $is_self_defined_config == "true" ]];do
		print_menu_self_defined
		read -p "select function : " res
		case $res in
			0)
				#echo "#!/bin/bash" >> ./run/burnin.sh
				read -p "How many cpueater : " loop
				if [[ $loop == +([0-9]) ]]; then
					#echo "./scripts/burnin_cpueater.sh $loop 2>&1 >/dev/null &" >> ./run/burnin.sh
					echo "./scripts/burnin_cpueater.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the CPU test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			1)
				read -p "I/O test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_bonnie.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the I/O test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			2)
				read -p "Memory Write/Read times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_memory.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the Memory test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi
				pause 'Press any key to continue...'
				;;
			3)
				read -p "eMMC Write/Read times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_emmc.sh ${emmcdev}p1 $loop "eMMC" 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the eMMC test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			4)
				read -p "uDisk Write/Read times:(0 for infinite loop) " loop 
				if [[ $loop == +([0-9]) ]]; then
					if [[ "$udisk_exist" == "1" ]]; then
						for i in "${!udisk_group[@]}"
						do
							echo "./scripts/burnin_udisk.sh ${udisk_group[$i]}1 $loop "USB" 2>&1 &"  >> ./run/burnin.sh
						done
						echo "The configuration of the uDisk test has been written to the script ./run/burnin.sh"
					else
						echo "udisk no exist"
					fi
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			5)
				read -p "Ping webserver times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					read -p "add eth0 ethernet test in self-defined test list? (Y/N) " res
					case $res in 
						Y|y|"")
						echo "./scripts/burnin_ethernet.sh eth0 $loop 2>&1 &" >> ./run/burnin.sh
						echo "The \"eth0 Ethernet test\" has been written to the script ./run/burnin.sh"
							;;
						*)
						echo "Don't add eth0 ethernet test in self-defined test list"
							;; 
					esac
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			6)
				read -p "Ping webserver times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_wifi.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the Wifi test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi
				pause 'Press any key to continue...'
				;;
			7)
				read -p "Show picture times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_show_pic_lvds.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the \"Show picture to LVDS\" has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			8)
				read -p "Play music times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_play_audio.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the \"Play music to speaker\" has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			9)
				echo "./scripts/burnin_hpattern.sh 2>&1 &" >> ./run/burnin.sh
				echo "The configuration of the \"Run H pattern test\" has been written to the script ./run/burnin.sh"
				pause 'Press any key to continue...'
				;;
			10)
				read -p "Read system temperature times:(0 for infinite loop) " loop
				read -p "Reflash time(sec): " temp_reflash_time
				if [[ $loop == +([0-9]) ]] && [[ $temp_reflash_time == +([0-9]) ]]; then
					echo "./scripts/burnin_temperature.sh $loop $temp_reflash_time 2>&1 &" >> ./run/burnin.sh 
					echo "The configuration of the \"Get system temperature\" has been written to the script ./run/burnin.sh"  
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			11)
				read -p "Read CPU frequency times:(0 for infinite loop) " loop
				read -p "Reflash time(sec): " cpufreq_reflash_time
				if [[ $loop == +([0-9]) ]] && [[ $cpufreq_reflash_time == +([0-9]) ]]; then
					echo "./scripts/burnin_frequency.sh $loop $cpufreq_reflash_time 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the \"Get CPU frequency\" has been written to the script ./run/burnin.sh" 
				else
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;
			12)
				read -p "I2C test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_i2c.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the I2C test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi
				pause 'Press any key to continue...'
				;;
			13)
				read -p "Read Comport times:(0 for infinite loop) " loop
				read -p "Set up data received Comport:(2 or 3) " port
                                if [[ ($loop != +([0-9])) && (( $port > 3 ) || ( $port < 2 )) ]]; then
					echo "Your input is illegal, please configure this option again"
				else
					echo "./scripts/burnin_comport.sh $loop $port 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the Comport test has been written to the script ./run/burnin.sh"
				fi
				;;
			14)
				if [[ ! -e "${app_root_dir}/run/burnin.sh" ]]; then
					echo "There is no test items in self-defined test list, please configure again"
					pause 'Press any key to continue...'
				else
					echo "The following is the test items in self-defined test list"
					echo ""
					cat ${app_root_dir}/run/burnin.sh
					echo ""
					pause 'Press any key to continue...'
				fi
				;;
			15)
				rm ./run/burnin.sh &>/dev/null
				echo "All test items in self-defined test list has been cleaned up"
				pause 'Press any key to continue...'
				;;
			Q|q|E|e)
				is_self_defined_config="false"
				echo "Exit the self-defined test list menu, return to the main menu"
				;;
			*)
				;;
		esac
	done
}

do_test() {
	echo 1 > /proc/sys/kernel/printk
	system_init 
	while true;do
		print_menu_main
		read -p "select function : " res
		case $res in 
			0)
				echo "The following is the test items in pre-defined all-test list" 
				echo ""
				cat ${app_root_dir}/run/burnin.sh.default
				echo ""
				read -p "Run the pre-defined all-test list using current configuration? (Y/N) " res
				case $res in 
					Y|y|"")
						check_system_config -enable wlan0 -enable eth0 -enable $enptest
						if [[ $is_correct_config == "true" ]]; then
							read -p "testing times:(0 for infinite loop) " loop
							if [[ $loop == +([0-9]) ]]; then
								if [[ -e "./cache.txt" ]]; then
									rm ./cache.txt &>/dev/null
								fi
								touch ./cache.txt &>/dev/null
								./run/burnin.sh.default $loop ${emmcdev} "${udisk_group[@]}"
								echo ""
								echo "Testing is being performed background..."
								echo ""
								pause
							else
								echo "Your input is illegal, please configure this option again"
								pause 'Press any key to continue...'
							fi 
						else
							pause 'Press any key to return to the main menu...'
						fi
						;;
					*)
						echo "Don't run the pre-defined all-test list"
						pause 'Press any key to return to the main menu...'
						;;
				esac
				;;
			1)
				if [[ ! -e "${app_root_dir}/run/burnin.sh" ]]; then
					echo "There is no test items in self-defined test list, please use the following menu to configure "
					do_test_self_defined
				else
					echo "The following is the test items in self-defined test list" 
					echo ""
					cat ${app_root_dir}/run/burnin.sh
					echo ""
					read -p "Run the self-defined test list using current configuration? (Y/N) " res
					case $res in 
						Y|y|"")
							is_wlan0_config=`cat ${app_root_dir}/run/burnin.sh |grep 'wifi'`
							if [[ $is_wlan0_config == "" ]]; then
								is_wlan0_config=disable
							else
								is_wlan0_config=enable
							fi
							is_eth0_config=`cat ${app_root_dir}/run/burnin.sh |grep 'eth0'`
							if [[ $is_eth0_config == "" ]]; then
								is_eth0_config=disable
							else
								is_eth0_config=enable
							fi
							is_eth1_config=`cat ${app_root_dir}/run/burnin.sh |grep "$enptest"`
							if [[ $is_eth1_config == "" ]]; then
								is_eth1_config=disable
							else
								is_eth1_config=enable
							fi
							check_system_config -$is_wlan0_config wlan0 -$is_eth0_config eth0 -$is_eth1_config $enptest
							if [[ $is_correct_config == "true" ]]; then
								if [[ -e "./cache.txt" ]]; then
									rm ./cache.txt &>/dev/null
								fi
								touch ./cache.txt &>/dev/null
								chmod 777 ./run/burnin.sh
								./run/burnin.sh
								echo ""
								echo "Testing is being performed background..."
								echo ""
								pause 
							else
								pause 'Press any key to return to the main menu...'
							fi
							;;
						*)
							echo "Don't run the self-defined test list"
							pause 'Press any key to return to the main menu...'
							;; 
					esac
				fi
				;;
			2)
				if [[ ! -e "${app_root_dir}/run/burnin.sh" ]]; then
					echo "There is no test items in self-defined test list, please use the following menu to configure"
				else
					echo "The following is the test items in self-defined test list currently"
					echo ""
					cat ${app_root_dir}/run/burnin.sh
					echo ""
				fi
				do_test_self_defined
				;;
			3)
				if [[ ! -e "${app_root_dir}/run/burnin.sh" ]]; then
					echo "There is no test items in self-defined test list, please use the following menu to configure"
					do_test_self_defined
				else
					echo "The following is the test items in self-defined test list"
					echo ""
					cat ${app_root_dir}/run/burnin.sh
					echo ""
					pause 'Press any key to continue...'
				fi
				;;
			4)
				rm ./run/burnin.sh &>/dev/null
				echo "All test items in self-defined test list has been cleaned up"
				pause 'Press any key to continue...'
				;;
			5)
				killall stress-ng &>/dev/null
				ps |grep 'burnin[_/]' |awk '{print $1;}' |xargs kill -9 &>/dev/null
				#ps |grep 'udhcpc -i' |awk '{print $1;}' |xargs kill -9 &>/dev/null
				#ps |grep 'wpa_supplicant' |awk '{print $1;}' |xargs kill -9 &>/dev/null
				killall bonnie++ &>/dev/null
				rm -rf ./Bonnie* &>/dev/null
				echo "The current running test processes has been stopped"
				pause 'Press any key to continue...'
				;;
			6)
				echo "Please configure your wifi SSID and PASSWORD"
				read -p "Wifi SSID: " ssid
				while [[ $ssid == "" ]]; do
					echo "Your input is empty, please enter again"
					read -p "Wifi SSID: " ssid
				done
				read -p "Wifi PASSWORD: " password
				while [[ ${#password} -lt 8 ]]; do
					echo "Wifi password length must be greater than or equal to 8, please enter again" 
					read -p "Wifi PASSWORD: " password
				done
				echo "SSID=$ssid" > ./scripts/burnin_wifi_config.sh
				echo "PASSWORD=$password" >> ./scripts/burnin_wifi_config.sh
				echo "The Wifi \"$ssid\" has been written to the ./scripts/burnin_wifi_config.sh"
				pause 'Press any key to continue...'
				;;
			7)
				read -p "eth0 ping IP: " eth0_PING_IP
				while [[ $eth0_PING_IP == "" ]]; do
					echo "Your input is empty, please enter again"
					read -p "eth0 ping IP: " eth0_PING_IP
				done
				read -p "wlan0 ping IP: " wlan0_PING_IP
				while [[ $wlan0_PING_IP == "" ]]; do
					echo "Your input is empty, please enter again"
					read -p "wlan0 ping IP: " wlan0_PING_IP
				done
				echo "eth0_PING_IP=$eth0_PING_IP" > ./scripts/burnin_ping_IP_config.sh 
				echo "wlan0_PING_IP=$wlan0_PING_IP" >> ./scripts/burnin_ping_IP_config.sh
				echo "The \"Ping IP configuration\" has been written to the ./scripts/burnin_ping_IP_config.sh"
				pause 'Press any key to continue...'
				;;
			8)
				trap 'exit_h_pattern' SIGINT
				./scripts/burnin_view_log.sh
				trap  SIGINT
				;;
			9)
				log_partition_change $emmcdev 
				;;
			Q|q|E|e)
				end_test
				echo 7 > /proc/sys/kernel/printk
				exit 0
				;;
			*)
				;;
		esac
	done
}

do_test $1
