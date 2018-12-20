#!/bin/bash

# SSID:    MC-RaspberryPi
# PW:      0123456789
# Network: 192.168.10.0/24
# Channel: 9


#variables init
run_time=`date +%Y%m%d%H%M`
log_file="ap_setup_log.${run_time}"

cat /dev/null > ${log_file}

AP_SSID="MC-RaspberryPi"
AP_CHANNEL="9"
AP_WPA_PASSPHRASE="0123456789"


if [ `lsusb | grep "RTL8188CUS\|RTL8192CU" | wc -l` -ne 0 ]; then
    echo ""
    echo "Your WiFi is based on the chipset that requires special version of hostapd."          | tee -a ${log_file}
    echo "Setup will download it for you."                                                      | tee -a ${log_file}
    CHIPSET="yes"
fi

echo "Checking network interfaces..."                                                           | tee -a ${log_file}
NONIC=`netstat -i | grep ^wlan | cut -d ' ' -f 1 | wc -l`

if [ ${NONIC} -lt 1 ]; then
    echo "There are no wireless network interfaces... Exiting"                                  | tee -a ${log_file}
    exit 1
elif [ ${NONIC} -gt 1 ]; then
    echo "You have more than one wlan interface. Please select the interface to become AP: "    | tee -a ${log_file}
    select INTERFACE in `netstat -i | grep ^wlan | cut -d ' ' -f 1`
    do
        NIC=${INTERFACE}
        break
    done
    exit 1
else
    NIC=`netstat -i | grep ^wlan | cut -d ' ' -f 1`
fi


WAN="eth0"
DNS=`netstat -rn | grep ${WAN} | grep UG | tr -s " " "X" | cut -d "X" -f 2`
echo "DNS will be set to " ${DNS}                                               | tee -a ${log_file}
echo "You can change DNS addresses for the new network in /etc/dhcp/dhcpd.conf"   | tee -a ${log_file}



# Specify subnet
NETWORK="192.168.10.0/24"
#Extract the subnet address and the subnet mask
SUBNET=`echo ${NETWORK} | grep -E -o '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'`
NETWORKPREFIX=`echo ${NETWORK} | grep -E -o "/[0-9]{1,2}" | grep -E -o [0-9]\{1,2\}`

AP_ADDR_PRT_1=`echo ${SUBNET} | cut -d "." -f 1`
AP_ADDR_PRT_2=`echo ${SUBNET} | cut -d "." -f 2`
AP_ADDR_PRT_3=`echo ${SUBNET} | cut -d "." -f 3`
AP_ADDR_PRT_4=`echo ${SUBNET} | cut -d "." -f 4`

#This part of the script converts the /[0-9]{1,2} netmask into a dot-seperated decimal netmask (i. e. /29 -> 255.255.255.248)
#Determine how many "parts" of the netmask are FULL with '1's; those who are filled with only '0's I call EMPTY
PART_COUNT_FULL=0
until [ ${NETWORKPREFIX} -lt 8 ]
do
    NETWORKPREFIX=`expr ${NETWORKPREFIX} - 8`
    PART_COUNT_FULL=`expr ${PART_COUNT_FULL} + 1`
done
if [ ${NETWORKPREFIX} -gt 0 ]
then
    PART_COUNT_EMPTY=`expr 3 - ${PART_COUNT_FULL}`
else
    PART_COUNT_EMPTY=`expr 4 - ${PART_COUNT_FULL}`
fi

#Convert the decimal notated netmask into a dot-seperated decimal netmask
COUNT=0
while [ ${COUNT} -lt ${PART_COUNT_FULL} ]
do
    DEC_NETMASK=255.${DEC_NETMASK}
    COUNT=`expr ${COUNT} + 1`
done
case ${NETWORKPREFIX} in 
    7)
        DEC_NETMASK=${DEC_NETMASK}254
    ;;
    6)
        DEC_NETMASK=${DEC_NETMASK}252
    ;;
    5)
        DEC_NETMASK=${DEC_NETMASK}248
    ;;
    4)
        DEC_NETMASK=${DEC_NETMASK}240
    ;;
    3)
        DEC_NETMASK=${DEC_NETMASK}224
    ;;
    2)
        DEC_NETMASK=${DEC_NETMASK}192
    ;;
    1)
        DEC_NETMASK=${DEC_NETMASK}128
    ;;
    0)
        DEC_NETMASK=${DEC_NETMASK}0
    ;;
esac
COUNT=`expr ${COUNT} + 1`
while [ ${COUNT} -lt 4 ] 
do
    DEC_NETMASK=${DEC_NETMASK}.0
    COUNT=`expr ${COUNT} + 1`
done
AP_NETMASK=${DEC_NETMASK}
unset DEC_NETMASK


#Check if all bits in the subnet address are '0' where the netmask bits are '0'
#First check the parts of the subnet address where are only '0's in the subnet mask
COUNT=4
LOOP_END=`expr 4 - ${PART_COUNT_EMPTY}`
while [ ${COUNT} -gt ${LOOP_END} ]
do
    if [ `echo ${SUBNET} | cut -d "." -f ${COUNT}` -ne 0 ]
    then
        echo ""
        echo "Your entered subnet address does not match with your subnet mask!"
        read -n 1 -p "Do you want me to correct it? (y/n)" terms_answer
        echo "" 
        if [ "${terms_answer,,}" = "n" ]
        then
            echo "Exit setup because of wrong user input. You can restart and input an other subnet address."
            exit 1
        else
            case ${COUNT} in 
            1)
                AP_ADDR_PRT_1=0
            ;;
            2)
                AP_ADDR_PRT_2=0
            ;;
            3)
                AP_ADDR_PRT_3=0
            ;;
            4)
                AP_ADDR_PRT_4=0
            ;;
            esac
            SUBNET=${AP_ADDR_PRT_1}.${AP_ADDR_PRT_2}.${AP_ADDR_PRT_3}.${AP_ADDR_PRT_4}
        fi
    fi
    COUNT=`expr ${COUNT} - 1`
done


#Now check also the part were subnet mask has '1's and '0's
#Convert the current part of the subnet address into binary system
CURRENTPART=${COUNT}
if [ `expr ${PART_COUNT_EMPTY} + ${PART_COUNT_FULL}` -ne 4 ]
then
    DecNum=`echo ${SUBNET} | cut -d "." -f ${CURRENTPART}`
    Binary=
    COUNT=0
    while [ ${DecNum} -ne 0 ]
    do
        Bit=`expr ${DecNum} % 2`
        Binary=${Bit}${Binary}
        DecNum=`expr ${DecNum} / 2`
        
        COUNT=`expr ${COUNT} + 1`
    done
    #Fill binary number with '0's
    while [ ${COUNT} -lt 8 ]
    do
        Binary=0${Binary}
        COUNT=`expr ${COUNT} + 1`
    done
    
    #Check the last part of the subnet address
    if [ ${Binary:${NETWORKPREFIX}:8} -ne 0 ]
    then
        echo ""
        echo "Your entered subnet address does not match with your subnet mask!"
        read -n 1 -p "Do you want me to correct it? (y/n)" terms_answer
        echo "" 
        if [ "${terms_answer,,}" = "n" ]
        then
            echo "Exit setup because of wrong user input. You can restart and input an other subnet address."
            exit 1
        else
            echo "Good! - Your new subnet address will be corrected and displayed below."
            
            NEW_PART=${Binary:0:${NETWORKPREFIX}}
            echo "The subnet part to change is: ${NEW_PART}"
            COUNT=`expr 8 - ${NETWORKPREFIX}`
            while [ ${COUNT} -gt 0 ]
            do
                NEW_PART=${NEW_PART}0
                COUNT=`expr ${COUNT} - 1`
            done
            
            echo ""
            echo "The new subnet part is: ${NEW_PART}"
            
            #Convert the binary subnet part into decimal
            Binary=${NEW_PART}
            Decimal=0
            power=1
            while [ $Binary -ne 0 ]
            do
                rem=$(expr $Binary % 10 )
                Decimal=$((Decimal+(rem*power)))
                power=$((power*2))
                Binary=$(expr $Binary / 10)
            done
            
            #Write back the changed part to the subnet address
            case ${CURRENTPART} in 
            1)
                AP_ADDR_PRT_1=${Decimal}
            ;;
            2)
                AP_ADDR_PRT_2=${Decimal}
            ;;
            3)
                AP_ADDR_PRT_3=${Decimal}
            ;;
            4)
                AP_ADDR_PRT_4=${Decimal}
            ;;
            esac
        fi

        SUBNET=${AP_ADDR_PRT_1}.${AP_ADDR_PRT_2}.${AP_ADDR_PRT_3}.${AP_ADDR_PRT_4}
    fi
fi


AP_ADDRESS=${AP_ADDR_PRT_1}.${AP_ADDR_PRT_2}.${AP_ADDR_PRT_3}.`expr ${AP_ADDR_PRT_4} + 1`
AP_LOWER_ADDR=${AP_ADDR_PRT_1}.${AP_ADDR_PRT_2}.${AP_ADDR_PRT_3}.`expr ${AP_ADDR_PRT_4} + 2`
#Calculate the parts of the Broadcast IP
BC_PART_1=${AP_ADDR_PRT_1}
BC_PART_2=${AP_ADDR_PRT_2}
BC_PART_3=${AP_ADDR_PRT_3}
BC_PART_4=${AP_ADDR_PRT_4}
END_LOOP=`expr 4 - ${PART_COUNT_EMPTY}`

COUNT=4
while [ ${COUNT} -gt ${END_LOOP} ]
do
    case ${COUNT} in 
    1)
        BC_PART_1=255
    ;;
    2)
        BC_PART_2=255
    ;;
    3)
        BC_PART_3=255
    ;;
    4)
        BC_PART_4=255
    ;;
    esac
    COUNT=`expr ${COUNT} - 1`
done
#Check if there is a part where are '0's and '1's in the subnet mask
if [ `expr ${PART_COUNT_EMPTY} + ${PART_COUNT_FULL}` -ne 4 ]
then
    #Convert the current subnet IP part into decimal
    DecNum=`echo ${SUBNET} | cut -d "." -f ${COUNT}`
    Binary=
    COUNT=0
    while [ ${DecNum} -ne 0 ]
    do
        Bit=`expr ${DecNum} % 2`
        Binary=${Bit}${Binary}
        DecNum=`expr ${DecNum} / 2`
        
        COUNT=`expr ${COUNT} + 1`
    done
    #Create new Boradcast IP part with the subnet part of the curent subnet IP part
    NEW_PART=${Binary:0:${NETWORKPREFIX}}
    
    #Append '1's until the new part is 8 chars long
    COUNT=`expr 8 - ${NETWORKPREFIX}`
    while [ ${COUNT} -gt 0 ]
    do
        NEW_PART=${NEW_PART}1
        COUNT=`expr ${COUNT} - 1`
    done
    #Reconvert into decimal
    Binary=${NEW_PART}
    Decimal=0
    power=1
    while [ $Binary -ne 0 ]
    do
        rem=$(expr $Binary % 10 )
        Decimal=$((Decimal+(rem*power)))
        power=$((power*2))
        Binary=$(expr $Binary / 10)
    done
    
    case `expr 4 - ${PART_COUNT_EMPTY}` in 
    1)
        BC_PART_1=${Decimal}
    ;;
    2)
        BC_PART_2=${Decimal}
    ;;
    3)
        BC_PART_3=${Decimal}
    ;;
    4)
        BC_PART_4=${Decimal}
    ;;
    esac
fi

AP_BROADCAST=${BC_PART_1}.${BC_PART_2}.${BC_PART_3}.${BC_PART_4}
AP_UPPER_ADDR=${BC_PART_1}.${BC_PART_2}.${BC_PART_3}.`expr ${BC_PART_4} - 1`


echo ""
echo ""
echo "+========================================================================"
echo "Your network settings will be:"                                                                   | tee -a ${log_file}
echo "AP NIC address: ${AP_ADDRESS}  "                                                                  | tee -a ${log_file}
echo "Subnet:  ${SUBNET} "                                                                              | tee -a ${log_file}
echo "Addresses assigned by DHCP will be from  ${AP_LOWER_ADDR} to ${AP_UPPER_ADDR}"                    | tee -a ${log_file}
echo "Netmask: ${AP_NETMASK}"                                                                           | tee -a ${log_file}
echo "DNS: ${DNS}        "                                                                              | tee -a ${log_file}
echo "WAN: ${WAN}"                                                                                      | tee -a ${log_file}

echo "Setting up  $NIC"                                                                                 | tee -a ${log_file}


echo "Downloading and installing packages: hostapd isc-dhcp-server iptables."                           | tee -a ${log_file}
echo ""
apt-get -y install hostapd isc-dhcp-server iptables                                                     | tee -a ${log_file} 
service hostapd stop | tee -a ${log_file} > /dev/null
service isc-dhcp-server stop  | tee -a ${log_file}  > /dev/null
echo ""                                                                                                 | tee -a ${log_file} 

echo "Backups:"                                                                                         | tee -a ${log_file}

if [ -f /etc/dhcp/dhcpd.conf ]; then
        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak.${run_time}
        echo " /etc/dhcp/dhcpd.conf to /etc/dhcp/dhcpd.conf.bak.${run_time}"                            | tee -a ${log_file}
fi

if [ -f /etc/hostapd/hostapd.conf ]; then
        cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak.${run_time}
        echo "/etc/hostapd/hostapd.conf to /etc/hostapd/hostapd.conf.bak.${run_time}"                   | tee -a ${log_file}
fi

if [ -f /etc/default/isc-dhcp-server ]; then
        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak.${run_time}
        echo "/etc/default/isc-dhcp-server to /etc/default/isc-dhcp-server.bak.${run_time}"             | tee -a ${log_file}
fi

if [ -f /etc/sysctl.conf ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak.${run_time}
        echo "/etc/sysctl.conf /etc/sysctl.conf.bak.${run_time}"                                        | tee -a ${log_file}
fi

if [ -f /etc/network/interfaces ]; then
        cp /etc/network/interfaces /etc/network/interfaces.bak.${run_time}
        echo "/etc/network/interfaces to /etc/network/interfaces.bak.${run_time}"                       | tee -a ${log_file}
fi

 
echo "Setting up AP..."                                                                                 | tee -a ${log_file} 


echo "Configure: /etc/default/isc-dhcp-server"                                                          | tee -a ${log_file} 
echo "DHCPD_CONF=\"/etc/dhcp/dhcpd.conf\""                         >  /etc/default/isc-dhcp-server
echo "INTERFACES=\"$NIC\""                                         >> /etc/default/isc-dhcp-server

echo "Configure: /etc/default/hostapd"                                                          | tee -a ${log_file} 
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""                   > /etc/default/hostapd

echo "Configure: /etc/dhcp/dhcpd.conf"                                                          | tee -a ${log_file} 
echo "ddns-update-style none;"                                     >  /etc/dhcp/dhcpd.conf
echo "default-lease-time 86400;"                                     >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 86400;"                                        >> /etc/dhcp/dhcpd.conf
echo "subnet ${SUBNET} netmask ${AP_NETMASK} {"                    >> /etc/dhcp/dhcpd.conf
echo "  range ${AP_LOWER_ADDR} ${AP_UPPER_ADDR};"                >> /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 85.214.20.141, 194.95.202.198;"                       >> /etc/dhcp/dhcpd.conf
echo "  option domain-name \"home\";"                              >> /etc/dhcp/dhcpd.conf
echo "  option routers " ${AP_ADDRESS} " ;"                        >> /etc/dhcp/dhcpd.conf
echo "}"                                                           >> /etc/dhcp/dhcpd.conf

echo "Configure: /etc/hostapd/hostapd.conf"                                                     | tee -a ${log_file} 
if [ ! -f /etc/hostapd/hostapd.conf ]; then
    touch /etc/hostapd/hostapd.conf
fi
    
echo "interface=$NIC"                                    >  /etc/hostapd/hostapd.conf
echo "ssid=${AP_SSID}"                                   >> /etc/hostapd/hostapd.conf
echo "channel=${AP_CHANNEL}"                             >> /etc/hostapd/hostapd.conf
echo "# WPA and WPA2 configuration"                      >> /etc/hostapd/hostapd.conf
echo "macaddr_acl=0"                                     >> /etc/hostapd/hostapd.conf
echo "auth_algs=1"                                       >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0"                           >> /etc/hostapd/hostapd.conf
echo "wpa=2"                                             >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=${AP_WPA_PASSPHRASE}"               >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK"                              >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP"                                 >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP"                                 >> /etc/hostapd/hostapd.conf
echo "# Hardware configuration"                          >> /etc/hostapd/hostapd.conf
if [ ${CHIPSET} = "yes" ]; then
    echo "driver=rtl871xdrv"                         >> /etc/hostapd/hostapd.conf
    echo "ieee80211n=1"                              >> /etc/hostapd/hostapd.conf
    echo "device_name=RTL8192CU"                     >> /etc/hostapd/hostapd.conf
    echo "manufacturer=Realtek"                      >> /etc/hostapd/hostapd.conf
else
    echo "driver=nl80211"                            >> /etc/hostapd/hostapd.conf
fi

echo "hw_mode=g"                                         >> /etc/hostapd/hostapd.conf

echo "Configure: /etc/sysctl.conf"                                                              | tee -a ${log_file} 
echo "net.ipv4.ip_forward=1"                             >> /etc/sysctl.conf 

echo "Configure: iptables"                                                                      | tee -a ${log_file} 
iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE
iptables -A FORWARD -i ${WAN} -o ${NIC} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${NIC} -o ${WAN} -j ACCEPT
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "Configure: /etc/network/interfaces"                                                       | tee -a ${log_file} 
echo "auto lo
iface lo inet loopback

iface eth0 inet dhcp
"                                                                     > /etc/network/interfaces
echo "auto ${NIC}"                                         >>  /etc/network/interfaces
echo "allow-hotplug ${NIC}"                                >> /etc/network/interfaces
echo "iface ${NIC} inet static"                           >> /etc/network/interfaces
echo "        address ${AP_ADDRESS}"                       >> /etc/network/interfaces
echo "        netmask ${AP_NETMASK}"                     >> /etc/network/interfaces
echo "up iptables-restore < /etc/iptables.ipv4.nat"      >> /etc/network/interfaces


if [ ${CHIPSET,,} = "yes" ]; then 
    echo "Download and install: special hostapd version"                                           | tee -a ${log_file}
    wget "http://raspberry-at-home.com/files/hostapd.gz"                                           | tee -a ${log_file}
     gzip -d hostapd.gz
     chmod 755 hostapd
     cp hostapd /usr/sbin/
fi



ifdown ${NIC}                                                                                    | tee -a ${log_file}
ifup ${NIC}                                                                                      | tee -a ${log_file}
service hostapd start                                                                          | tee -a ${log_file}
service isc-dhcp-server start                                                                  | tee -a ${log_file}

echo "Configure: startup"                                                              | tee -a ${log_file}
update-rc.d hostapd enable                                                             | tee -a ${log_file}
update-rc.d isc-dhcp-server enable                                                     | tee -a ${log_file}
update-rc.d tor enable


#Update /etc/rc.local
sed '/exit 0/d' /etc/rc.local | tee /etc/rc.local
echo "sudo service hostapd stop
sudo service isc-dhcp-server stop
sudo ifdown wlan0
sudo ifup wlan0
sudo service hostapd restart
sudo service isc-dhcp-server restart
sudo service tor restart

exit 0
" >> /etc/rc.local

exit 0
