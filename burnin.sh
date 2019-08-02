#!/bin/bash

Ver=0.2.3
LANG=C
LANGUAGE="en_US.UTF-8"


if [ $USER != "root" ]
then
	echo "is not root ?"
	exit
fi


Hostname=`cat /etc/hostname`

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
	#		echo -ne "H"
			echo -ne "\e[${coln}mH"
			usleep $h_delay
		done
		#	h_count=h_count+1
	done
}

exit_h_pattern() {
	kill $h_pid &>/dev/null
	trap - SIGINT
	exit_h_parttern=1
	print_menu_main
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

audio_init() {
	amixer cset numid=5,iface=MIXER,name='Headphone Playback Volume' 127 &>/dev/null      		
}

log_partition_init() {
	mmcpart=`blkid /dev/$1p2`
	if [[ "$mmcpart" == *"ext4"* ]]; then
		echo "eMMC partition exist"
	else
		echo "Create eMMC partition"
        if [ -d "/run/media/$1p1" ]; then
                rm -rf /run/media/$1p1
        fi
        if [ -d "/run/media/$1p2" ]; then
                rm -rf /run/media/$1p2
        fi

		dd if=/dev/zero of=/dev/$1  bs=512  count=1
fdisk /dev/$1 &>/dev/null << EOF
n
p
1

+1024M
n
p
2



w
q
EOF

		sync && sync && sleep 1
		if [ -d "/run/media/$1p1" ]; then
                rm -rf /run/media/$1p1
        fi
        if [ -d "/run/media/$1p2" ]; then
                rm -rf /run/media/$1p2
        fi

		partprobe /dev/$1p1
		partprobe /dev/$1p2
		sync && sync && sleep 1
		mkfs.ext4 -F /dev/$1p1 &>/dev/null
		mkfs.ext4 -F /dev/$1p2 &>/dev/null
	fi
	sync && sync && sleep 1
}


if [ -d /home/root/advtest/burnin/log ]; then
	rm -rf /home/root/advtest/burnin/log/
fi



echo "Check eMMC partition"
log_partition_init $emmcdev &>/dev/null
log_partition_init $sddev &>/dev/null


system_init() {
	clear
	stty erase '^H'
	stty erase '^?'
	echo "wait ... "
#	emmc_init $emmcdev 
	udisk_init
#	log_partition_init mmcblk0
#	audio_init
#        enptest=$(ifconfig -a | grep eth[^0] | awk '{print $1}')
#        if [[ !$enptest ]] ; then
#           enptest=$(ifconfig -a | grep enp | awk '{print $1}')
#        fi
	
#        eths=$(ifconfig -a | grep Ethernet | awk '{print $1;}')
#        for i in ${eths[@]}; do
#                ifconfig $i down 2>/dev/null 1>/dev/null
#        done


}


print_menu_main() {
	echo 
	echo -e "\e[39m"
	echo "Test script Version : $Ver"
	echo "=========================================="
#	echo "(0)	Run the pre-defined all-test list"
	echo "(1)	Run the self-defined test list"
	echo "(2)	Add test items in self-defined test list"	
	echo "(3)	Check the test items in self-defined test list"
	echo "(4)	Clear all test items in self-defined test list"	
	echo "(5) 	Stop the current running test processes"	
#	echo "(6)	Edit the WiFi test configuration"
#	echo "(7)	Edit Ping IP test configuration"	
#	echo "(8)	Run H pattern test"		
	echo "(9)	Dynamic view the log file"
	echo "(E/e)	exit the main menu"
	echo "=========================================="
}
print_menu_self_defined_imsse01() {
	echo 
	echo -e "\e[39m"
	echo "Please add test items in self-defined test list"
	echo "=========================================="	
	echo "(0)	CPU test"
	echo "(1)	Memory test"
	echo "(2)	eMMC test"
	echo "(3)	SD test"
	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"	
	echo "(14) 	Boradr-Reach test"	
	echo "(6) 	Wifi test"	
#	echo "(7)	Show picture to LVDS"
	echo "(8)	Play music to speaker"
	echo "(9)	Get system temperature"
	echo "(10)	Get CPU frequency"			
#	echo "(11)	I2C test"	
	echo "(11)	Play video to display/speaker"			
	echo "(15)	SPI ROM"	
    echo "(16)	H Pattern"		
	echo "(12)	Check the test items in self-defined test list"
	echo "(13)	Clear all test items in self-defined test list"
	echo "(21)	can bus loopback"
	echo "(E/e)	exit the self-defined test list menu"
	echo "=========================================="
}
print_menu_self_defined_dmsse23() {
	echo 
	echo -e "\e[39m"
	echo "Please add test items in self-defined test list"
	echo "=========================================="	
	echo "(0)	CPU test"
	echo "(1)	Memory test"
	echo "(2)	eMMC test"
	echo "(3)	SD test"
	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"	
#	echo "(6) 	Wifi test"	
	echo "(7)	Show picture to LVDS"	
	echo "(8)	Play music to speaker"
	echo "(9)	Get system temperature"
	echo "(10)	Get CPU frequency"			
#	echo "(11)	I2C test"
	echo "(11)	Play video to display/speaker"	
	echo "(15)	SPI ROM"	
	echo "(16)	H Pattern"	
	echo "(12)	Check the test items in self-defined test list"
	echo "(13)	Clear all test items in self-defined test list"
#	echo "(21)	can bus loopback"
	echo "(E/e)	exit the self-defined test list menu"
	echo "=========================================="
}
print_menu_self_defined_w105() {
	echo 
	echo -e "\e[39m"
	echo "Please add test items in self-defined test list"
	echo "=========================================="	
	echo "(0)	CPU test"
	echo "(1)	Memory test"
	echo "(2)	eMMC test"
	echo "(3)	SD test"
	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"	
#	echo "(14) 	Boradr-Reach test"	
	echo "(6) 	Wifi station test"	
	echo "(17) 	Wifi ap test"	
	echo "(7)	Show picture to LVDS"	
	echo "(8)	Play music to speaker"
	echo "(18)	Get sensor temperature"
	echo "(9)	Get system temperature"
	echo "(10)	Get CPU frequency"			
#	echo "(11)	I2C test"	
#	echo "(11)	Play video to display/speaker"			
#	echo "(15)	SPI ROM"	
	echo "(16)	H Pattern"		
	echo "(19)	comport loopback"
	echo "(20)	IR transmission test"
	echo "(12)	Check the test items in self-defined test list"
	echo "(13)	Clear all test items in self-defined test list"
#	echo "(21)	can bus loopback"
	echo "(E/e)	exit the self-defined test list menu"
	echo "=========================================="
}

print_menu_self_defined_magmon() {
	echo 
	echo -e "\e[39m"
	echo "Please add test items in self-defined test list"
	echo "=========================================="	
	echo "(0)	CPU test"
	echo "(1)	Memory test"
	echo "(2)	eMMC test"
	echo "(3)	SD test"
	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"	
	echo "(9)	Get system temperature"
	echo "(10)	Get CPU frequency"			
	echo "(19)	comport loopback"
	echo "(12)	Check the test items in self-defined test list"
	echo "(13)	Clear all test items in self-defined test list"
#	echo "(21)	can bus loopback"
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
is_self_defined_config="true"
do_test_self_defined() {		
	is_self_defined_config="true"
	while [[ $is_self_defined_config == "true" ]];do
		if [[ "$Hostname" == *"imsse01"* ]]; then
			print_menu_self_defined_imsse01
		elif [[ "$Hostname" == *"dmsse23"* ]]; then
			print_menu_self_defined_dmsse23
		elif [[ "$Hostname" == *"imx6q-cv1"* ]]; then
			print_menu_self_defined_w105
		elif [[ "$Hostname" == *"magmon"* ]]; then
			print_menu_self_defined_magmon
		fi
		
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
			#1)
			#	read -p "I/O test times:(0 for infinite loop) " loop
			#	if [[ $loop == +([0-9]) ]]; then
			#		echo "./scripts/burnin_bonnie.sh $loop 2>&1 &" >> ./run/burnin.sh
			#		echo "The configuration of the I/O test has been written to the script ./run/burnin.sh"
			#	else                                                                    
            #    			echo "Your input is illegal, please configure this option again"
        	#		fi 
			#	pause 'Press any key to continue...'
			#	;;
			1)
				read -p "Memory Write/Read times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_memory.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the Memory test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi
				pause 'Press any key to continue...'
				;;
			2)
				read -p "eMMC Write/Read times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_emmc.sh $emmcdev $loop "eMMC" 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the eMMC($emmcdev) test has been written to the script ./run/burnin.sh"
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
        			fi 
				pause 'Press any key to continue...'
				;;	
			3)
				read -p "eMMC Write/Read times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_emmc.sh $sddev $loop "eMMC" 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the eMMC($sddev) test has been written to the script ./run/burnin.sh"
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
				if [[ "$Hostname" == *"imsse01"* ]]; then
					read -p "Ping ehternet times:(0 for infinite loop) " loop
					if [[ $loop == +([0-9]) ]]; then
						read -p "add enp1s0 ethernet test in self-defined test list? (Y/N) " res
						case $res in 
							Y|y|"")
								echo "./scripts/burnin_ethernet.sh enp1s0 $loop HOST0 2>&1 &" >> ./run/burnin.sh
								echo "The \"enp1s0 Ethernet test\" has been written to the script ./run/burnin.sh"
								;;
							*)
								echo "Don't add enp1s0 ethernet test in self-defined test list"
								;; 
						esac				
					else                                                                    
								echo "Your input is illegal, please configure this option again"
					fi 
				elif [[ "$Hostname" == *"dmsse23"* || "$Hostname" == *"imx6q-cv1"* ]]; then
					read -p "Ping ehternet times:(0 for infinite loop) " loop
					if [[ $loop == +([0-9]) ]]; then
						read -p "add eth0 ethernet test in self-defined test list? (Y/N) " res
						case $res in 
							Y|y|"")
								echo "./scripts/burnin_ethernet.sh eth0 $loop HOST0 2>&1 &" >> ./run/burnin.sh
								echo "The \"eth0 Ethernet test\" has been written to the script ./run/burnin.sh"
								;;
							*)
								echo "Don't add eth0 ethernet test in self-defined test list"
								;; 
						esac				
					else                                                                    
								echo "Your input is illegal, please configure this option again"
					fi 
				elif [[ "$Hostname" == *"magmon"* ]]; then
					read -p "Choose ethernet interface (eth0/eth1)"  eth_ifc
					case $eth_ifc in
						eth0|eth1)					
							read -p "Ping $eth_ifc ehternet times:(0 for infinite loop) " loop
							if [[ $loop == +([0-9]) ]]; then
								read -p "add $eth_ifc ethernet test in self-defined test list? (Y/N) " res
								case $res in 
									Y|y|"")
										if [[ "$eth_ifc" == "eth0" ]]; then
											echo "./scripts/burnin_ethernet.sh $eth_ifc $loop HOST0 2>&1 &" >> ./run/burnin.sh
										else
											echo "./scripts/burnin_ethernet.sh $eth_ifc $loop HOST1 2>&1 &" >> ./run/burnin.sh
										fi
										echo "The \"$eth_ifc Ethernet test\" has been written to the script ./run/burnin.sh"
										;;
									*)
										echo "Don't add $eth_ifc ethernet test in self-defined test list"
										;; 
								esac
							else                                                                    
								echo "Your input is illegal, please configure this option again"
							fi
							;;
						*)
							echo "Unknown ethernet interface, please configure this option again"
							;;
					esac					
				fi
				pause 'Press any key to continue...'
				;;			
			6)			
				read -p "Ping webserver times:(0 for infinite loop) " loop
				read -p "Please input SSID: " TEST_SSID
				read -p "Please input Password:  " TEST_PASSWORD
				read -p "Please input PING server IP:  " TEST_SERVER_IP
	
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_wifi.sh $loop $TEST_SSID  $TEST_PASSWORD $TEST_SERVER_IP 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the Wifi test has been written to the script ./run/burnin.sh"
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
        			fi 				
				pause 'Press any key to continue...'
				;;
			17)	
				#systemctl enable hostapd.service
				#systemctl start hostapd.service
				
				read -p "Ping webserver times:(0 for infinite loop) " loop
				echo "Wait for AP mode enable..."
				read -p "Please input device (connect to CV1_202) IP: " TEST_IP
	
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_wifi_ap.sh $loop $TEST_IP 2>&1 &" >> ./run/burnin.sh
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
			18)
				read -p "Read system temperature times:(0 for infinite loop) " loop
				read -p "Reflash time(sec): " temp_reflash_time
				if [[ $loop == +([0-9]) ]] && [[ $temp_reflash_time == +([0-9]) ]]; then
					echo "./scripts/burnin_temperature_sensor.sh $loop $temp_reflash_time 2>&1 &" >> ./run/burnin.sh 
					echo "The configuration of the \"Get system temperature\" has been written to the script ./run/burnin.sh"  
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
        			fi 
				pause 'Press any key to continue...'
				;;
			10)
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
			11)
				#read -p "I2C test times:(0 for infinite loop) " loop
				#if [[ $loop == +([0-9]) ]]; then
				#	echo "./scripts/burnin_i2c.sh $loop 2>&1 &" >> ./run/burnin.sh
				#	echo "The configuration of the I2C test has been written to the script ./run/burnin.sh"
				#else                                                                    
                #			echo "Your input is illegal, please configure this option again"
           		#	fi 
				read -p "Play video test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_play_video.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the play video test has been written to the script ./run/burnin.sh"
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
           			fi 
				
				pause 'Press any key to continue...'
           			;;  
			15)
				read -p "SPI ROM test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					if [[ "$Hostname" == *"dmsse23"* || "$Hostname" == *"imsse01"* ]]; then
						device="/dev/mtdblock2"
					else
						device="/dev/mtdblock0"
					fi

					echo "./scripts/burnin_spi_rom.sh $loop $device 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the spi rom test has been written to the script ./run/burnin.sh"
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
           			fi 
				
				pause 'Press any key to continue...'
           			;; 	
			16)
				echo "./scripts/burnin_h_pattern.sh 0 2>&1 &" >> ./run/burnin.sh
				echo "The configuration of the h-pattern test has been written to the script ./run/burnin.sh"
				
				pause 'Press any key to continue...'
           			;; 						
			19)
				read -p "COMPORT test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_comport.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the comport test has been written to the script ./run/burnin.sh"
				else                                                                    
                			echo "Your input is illegal, please configure this option again"
				fi 				
				pause 'Press any key to continue...'	
           			;; 						
			20)
				read -p "IR test times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					echo "./scripts/burnin_IR.sh $loop 2>&1 &" >> ./run/burnin.sh
					echo "The configuration of the comport test has been written to the script ./run/burnin.sh"
				else                                                                    
					echo "Your input is illegal, please configure this option again"
				fi 				
				pause 'Press any key to continue...'
				;;
			12)                                                                           
           			if [[ ! -e "/home/root/advtest/burnin/run/burnin.sh" ]]; then         
                   			echo "There is no test items in self-defined test list, please configure again"
                   			pause 'Press any key to continue...'                                      
           			else
                   			echo "The following is the test items in self-defined test list"
                   			echo ""          
                   			cat /home/root/advtest/burnin/run/burnin.sh
                   			echo ""          
                   			pause 'Press any key to continue...'
           			fi  
           			;;                                                                   
   			13)                                                                           
           			rm ./run/burnin.sh &>/dev/null                                       
           			echo "All test items in self-defined test list has been cleaned up"                  
           			pause 'Press any key to continue...'                                 
           			;;
			Q|q|E|e)
				is_self_defined_config="false"
				echo "Exit the self-defined test list menu, return to the main menu"
				;;
			14)
				read -p "Ping Boardr-Reach times:(0 for infinite loop) " loop
				if [[ $loop == +([0-9]) ]]; then
					read -p "add Boardr-Reach test in self-defined test list? (Y/N) " res
					case $res in 
						Y|y|"")
							read -p "Please input BoradR-Reach slave(1) or master(0): " TEST_BoradRreach
							if [[ $TEST_BoradRreach == +([0-1]) ]]; then
								echo "./scripts/burnin_boardRreach.sh eth0 $loop HOST0 $TEST_BoradRreach 2>&1 &" >> ./run/burnin.sh
								echo "The \"Boardr-Reach test\" has been written to the script ./run/burnin.sh"
							else       
								echo "Your input is illegal, please configure this option again"
							fi
							;;
						*)
							echo "Don't add Boardr-Reach test in self-defined test list"
							;; 
					esac				
				else                                                              
					echo "Your input is illegal, please configure this option again"
				fi 
				pause 'Press any key to continue...'
				;;				
			21)
				read -p "can bus loopback times:(0 for infinite loop)" loop
				if [[ $loop == +([0-9]) ]];  then
					read -p "show log:(0:disable 1:enable):" en_log
					if [[ "$en_log"=="1" || "$en_log"=="0" ]]; then
						def_log="$en_log"
					else
						def_log="1"
					fi
					echo "./scripts/burnin_can_bus_loop.sh can $loop $def_log >&1 &" >> ./run/burnin.sh
					echo "The configuration of the can bus test has been written to the script ./run/burnin.sh"
				else
					echo "Your input is illegal, please configure this option again"
				fi
				pause 'Press any key to continue...'
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
			1)
				if [[ ! -e "/home/root/advtest/burnin/run/burnin.sh" ]]; then					
					echo "There is no test items in self-defined test list, please use the following menu to configure "
					do_test_self_defined
				else					
					echo "The following is the test items in self-defined test list" 
        				echo ""                                                                 
        				cat /home/root/advtest/burnin/run/burnin.sh                              
        				echo ""
					read -p "Run the self-defined test list using current configuration? (Y/N) " res
					case $res in 
						Y|y|"")
							is_wlan0_config=`cat /home/root/advtest/burnin/run/burnin.sh |grep 'wifi'`
							if [[ $is_wlan0_config == "" ]]; then
								is_wlan0_config=disable
							else
								is_wlan0_config=enable
							fi
							is_eth0_config=`cat /home/root/advtest/burnin/run/burnin.sh |grep 'eth0'`
							if [[ $is_eth0_config == "" ]]; then
								is_eth0_config=disable
							else
								is_eth0_config=enable
							fi
							is_eth1_config=`cat /home/root/advtest/burnin/run/burnin.sh |grep "$enptest"`
							if [[ $is_eth1_config == "" ]]; then
								is_eth1_config=disable
							else
								is_eth1_config=enable
							fi
							#check_system_config -$is_wlan0_config wlan0 -$is_eth0_config eth0 -$is_eth1_config $enptest
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
                   		if [[ ! -e "/home/root/advtest/burnin/run/burnin.sh" ]]; then         
                   			echo "There is no test items in self-defined test list, please use the following menu to configure"
           			else                                                                 
                   			echo "The following is the test items in self-defined test list currently"
                   			echo ""
                   			cat /home/root/advtest/burnin/run/burnin.sh                                              
                   			echo ""	                                                
           			fi
				do_test_self_defined                                               
           			;;			
			3)                                                                           
           			if [[ ! -e "//home/root/advtest/burnin/run/burnin.sh" ]]; then         
                   			echo "There is no test items in self-defined test list, please use the following menu to configure"
					do_test_self_defined
           			else                                                                 
                   			echo "The following is the test items in self-defined test list"
                   			echo ""
                   			cat /home/root/advtest/burnin/run/burnin.sh                                              
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
				killall cpueater &>/dev/null				
				ps |grep 'burnin[_/]' |awk '{print $1;}' |xargs kill -9 &>/dev/null
				ps |grep 'advantech*' |awk '{print $1;}' |xargs kill -9 &>/dev/null
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
				
				read -p "$enptest ping IP: " eth1_PING_IP
				while [[ $eth1_PING_IP == "" ]]; do                   
                    echo "Your input is empty, please enter again"
                    read -p "$enptest ping IP: " eth1_PING_IP 
                done
				
				read -p "wlan0 ping IP: " wlan0_PING_IP
                while [[ $wlan0_PING_IP == "" ]]; do                   
                    echo "Your input is empty, please enter again"
                    read -p "wlan0 ping IP: " wlan0_PING_IP         
				done
				
				echo "eth0_PING_IP=$eth0_PING_IP" > ./scripts/burnin_ping_IP_config.sh 
                echo ""$enptest"_PING_IP=$eth1_PING_IP" >> ./scripts/burnin_ping_IP_config.sh
				echo "wlan0_PING_IP=$wlan0_PING_IP" >> ./scripts/burnin_ping_IP_config.sh
                echo "The \"Ping IP configuration\" has been written to the ./scripts/burnin_ping_IP_config.sh"
                pause 'Press any key to continue...'
				;;	
			8)
				declare -i h_speed
				declare -i h_delay
				#read -p "Delay time (usec) : " h_delay
				#h_delay=$(($h_delay*1000))
				h_pattern &
				h_pid=$!
				trap 'exit_h_pattern' SIGINT
				;;
			9)
				trap 'exit_h_pattern' SIGINT
				./scripts/burnin_view_log.sh
				trap  SIGINT
				;;
			#10)
			#	log_partition_change $emmcdev 
			#	;;
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




#if [[ "$Hostname" == *"imsse01"* ]]; then
#    read -p "Please input BoradR-Reach slave(1) or master(0): " TEST_BoradRreach
#	read -p "Please input SSID: " TEST_SSID
#	read -p "Please input Password:  " TEST_PASSWORD
#fi

#=======IMS-SE01===============================================================#
#./scripts/burnin_ethernet.sh enp1s0 0 HOST0 2>&1 &                            #
#./scripts/burnin_boardRreach.sh eth0 0 HOST0 $TEST_BoradRreach 2>&1 &         #
#./scripts/burnin_wifi.sh 0 $TEST_SSID  $TEST_PASSWORD 2>&1 &                  #
#==============================================================================#


#=======DMS-SE23===============================================================#
#./scripts/burnin_ethernet.sh eth0 0 HOST0 2>&1 &							   #
#==============================================================================#


#./scripts/burnin_cpueater.sh 10 2>&1 &
#./scripts/burnin_memory.sh 0 2>&1 &
#./scripts/burnin_emmc.sh mmcblk2 0 eMMC 2>&1 & #eMMC
#./scripts/burnin_emmc.sh mmcblk1 0 eMMC 2>&1 & #SD
#./scripts/burnin_udisk.sh sda1 0 USB 2>&1 &
#./scripts/burnin_udisk.sh sdb1 0 USB 2>&1 &
#./scripts/burnin_play_audio.sh 0 2>&1 &
#./scripts/burnin_temperature.sh 0 1 2>&1 &
#./scripts/burnin_frequency.sh 0 1 2>&1 &
#./scripts/burnin_play_video.sh 0 2>&1 &
#./scripts/burnin_spi_rom.sh 0 2>&1 &
#./scripts/burnin_h_pattern.sh 0 2>&1 &