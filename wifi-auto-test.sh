export timeout=20

export op_ip="192.168.10.1"
export op_user=root

export agl_ip="192.168.1.101"
export agl_user=root


declare -a arr=("psk-aes"  "psk2-aes"  "psk-tkip"  "psk2-tkip")


wifi_switch() {
	      echo "Switch Openwrt WiFi setting to $1"
	      ssh $op_user@$op_ip "test222.sh $1"
	     
	      # need to add code to check return value
}


wifi_connect() {
	      
	      wifi_ssid="openwrt_"$2"_"$1
	      
              ssh $agl_user@$agl_ip "connmanctl scan wifi"
              sleep 5	      
               
	      while [ $timeout -gt 0 ]
	      do
	        ssid_list=`ssh $agl_user@$agl_ip "connmanctl services | grep $wifi_ssid"`
	      	if [ -z "$ssid_list" ];then
			echo "can not find the ssid, try again 2 sec later ..."
	      		sleep 3
			((timeout--))
		else
			ssid_status=${ssid_list%%\ *}
			ssid_hash=${ssid_list##*\ }
                        echo "ssid_list: $ssid_list"                     
                        echo "ssid_status: $ssid_status"                      
                        echo "ssid_hash: $ssid_hash"                      
                        
			if [ -z $ssid_status ]; 
			then
				:
				echo "$1 $2: Skip. Password not avaiable" >> results.log
                                return 0
			elif [ $ssid_status = "*Aa" ]; 
			then
				echo "Aleaday connected to the given ssid."
				return 0
			fi

			echo "connecting to the given ssid"
			connection_result=`ssh $agl_user@$agl_ip "connmanctl connect $ssid_hash"`
			echo $connection_result
			
			if [[ $connection_result =~ "Connected" ]];
			then
				echo "$1 $2: Pass" >> results.log
				return 0
                        else
			        echo "$1 $2: Fail" >> results.log
			        return 0
		        fi	
		fi
	      done
	      echo "$1 $2 connection failed. timeout error" >> results.log
	      return 0

	      # need to add code to check return value
}

echo "################################" >> results.log
date >> results.log
echo "################################" >> results.log

for  element in ${arr[@]}; do
	echo "element $element"
        wifi_switch $element
	wifi_connect $element 2.4g
	wifi_connect $element 5g
done


