function prepare_test()
{
	#run task manager
	su - linaro -c "DISPLAY=:0.0 lxtask" &

	su - linaro -c "DISPLAY=:0.0 xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled --create -t bool -s true"
	su - linaro -c "DISPLAY=:0.0 xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off --create -t int -s 0"
	su - linaro -c "DISPLAY=:0.0 xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep --create -t int -s 0"
	su - linaro -c "DISPLAY=:0.0 xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac --create -t int -s 0"
	su - linaro -c "DISPLAY=:0.0 xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-switch --create -t int -s 0"
	
	sleep 2
	WID=`su - linaro -c "DISPLAY=:0.0 xdotool search -onlyvisible -name \"Task Manager\""`
	su - linaro -c "DISPLAY=:0.0 xdotool windowmove $WID 100 10"
}

function print_menu_self_defined() 
{
	echo 
	echo -e "\e[39m"
	echo "Test item list for "$MODEL
	echo "Please add test items in self-defined test list"
	echo "=========================================="	
	echo "(0)	CPU test"
	echo "(1)	Memory test"
	echo "(2)	eMMC test"
	echo "(3)	SD test"
#	echo "(4)	uDisk test"	
	echo "(5) 	Ethernet test"	
#	echo "(14) 	Boradr-Reach test"	
#	echo "(6) 	Wifi test"	
	echo "(7)	Show picture"
#	echo "(8)	Play music to speaker"
	echo "(9)	Get system temperature"
	echo "(10)	Get CPU frequency"			
#	echo "(11)	I2C test"	
	echo "(11)	Play video"			
#	echo "(15)	SPI ROM"	
#	echo "(16)	H Pattern"		
	echo "(22)	Get ALS"		
	echo "(12)	Check the test items in self-defined test list"
	echo "(13)	Clear all test items in self-defined test list"
	#echo "(21)	can bus loopback"
	echo "(E/e)	exit the self-defined test list menu"
	echo "=========================================="
}

#print_menu_self_defined() {
#	
#	declare -a TEST_SCRIPTS
#	pushd ./scripts/tmp/ #2>&1 | /dev/null
#	TEST_SCRIPTS=`find .  -maxdepth 1 -iname "*.sh" | sort`
#	echo $TEST_SCRIPTS | awk '{
#	  len=split($TEST_SCRIPTS,arr," ");
#	  for (i=0;++i <=len;){
#		  split(arr[i],val,"/");
#		  split(val[2],val1,"-|\.");
#		     printf("%d,\"[%02d] %s\",%d-%s.sh \n",val1[1], val1[1],val1[2], val1[1],val1[2]);
#	 }
#  }' > /tmp/items
#
#	
#	popd #2>&1 | /dev/null
#	
#}
