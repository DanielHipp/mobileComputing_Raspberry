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
    echo "Your WiFi is based on the chipset that requires special version of hostapd."    | tee -a ${log_file}
    echo "Setup will download it for you."                                                | tee -a ${log_file}
    CHIPSET="yes"
fi


NIC="wlan0"
WAN="eth0"
DNS=`netstat -rn | grep ${WAN} | grep UG | tr -s " " "X" | cut -d "X" -f 2`
echo "DNS will be set to " ${DNS}                                                 | tee -a ${log_file}
echo "You can change DNS addresses for the new network in /etc/dhcp/dhcpd.conf"   | tee -a ${log_file}



# Specify subnet
SUBNET="192.168.10.0"
AP_ADDRESS="192.168.10.1"
AP_NETMASK="255.255.255.0"
BROADCAST="255.255.255.255"
AP_LOWER_ADDR="192.168.10.2"
AP_UPPER_ADDR="192.168.10.4"


echo ""
echo ""
echo "+========================================================================"
echo "Your network settings will be:"                              | tee -a ${log_file}
echo "AP NIC address: ${AP_ADDRESS}  "                             | tee -a ${log_file}
echo "Subnet:  ${SUBNET} "                                         | tee -a ${log_file}
echo "Addresses assigned by DHCP will be from  ${AP_LOWER_ADDR} to ${AP_UPPER_ADDR}" | tee -a ${log_file}
echo "Netmask: ${AP_NETMASK}"                                      | tee -a ${log_file}
echo "DNS: ${DNS}        "                                         | tee -a ${log_file}
echo "WAN: ${WAN}"                                                 | tee -a ${log_file}

echo "Setting up  $NIC"                                            | tee -a ${log_file}


echo "Downloading and installing packages: hostapd isc-dhcp-server iptables." | tee -a ${log_file}
echo ""
# Remove current DHCP client because new one will be installed
apt-get -y remove dhcpcd5
apt-get -y install hostapd isc-dhcp-server iptables                | tee -a ${log_file} 
service hostapd stop | tee -a ${log_file} > /dev/null
service isc-dhcp-server stop  | tee -a ${log_file}  > /dev/null
echo ""                                                            | tee -a ${log_file} 

echo "Backups:"                                                    | tee -a ${log_file}

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
        echo "/etc/sysctl.conf /etc/sysctl.conf.bak.${run_time}"   | tee -a ${log_file}
fi

if [ -f /etc/network/interfaces ]; then
        cp /etc/network/interfaces /etc/network/interfaces.bak.${run_time}
        echo "/etc/network/interfaces to /etc/network/interfaces.bak.${run_time}"                       | tee -a ${log_file}
fi

 
echo "Setting up AP..."                                       | tee -a ${log_file} 


echo "Configure: /etc/default/isc-dhcp-server"                | tee -a ${log_file} 
echo "DHCPD_CONF=\"/etc/dhcp/dhcpd.conf\""                    >  /etc/default/isc-dhcp-server
echo "INTERFACES=\"${NIC}\""                                  >> /etc/default/isc-dhcp-server

echo "Configure: /etc/default/hostapd"                        | tee -a ${log_file} 
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""              > /etc/default/hostapd

echo "Configure: /etc/dhcp/dhcpd.conf"                         tee -a ${log_file} 
echo "ddns-update-style none;"                                >  /etc/dhcp/dhcpd.conf
echo "default-lease-time 86400;"                              >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 86400;"                                  >> /etc/dhcp/dhcpd.conf
echo "subnet ${SUBNET} netmask ${AP_NETMASK} {"               >> /etc/dhcp/dhcpd.conf
echo "  interface ${NIC};"                                    >> /etc/dhcp/dhcpd.conf
echo "  range ${AP_LOWER_ADDR} ${AP_UPPER_ADDR};"             >> /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 46.182.19.48, 8.8.8.8;"    >> /etc/dhcp/dhcpd.conf
echo "  option domain-name \"home\";"                         >> /etc/dhcp/dhcpd.conf
echo "  option routers "${AP_ADDRESS}";"                      >> /etc/dhcp/dhcpd.conf
echo "}"                                                      >> /etc/dhcp/dhcpd.conf

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
    echo "driver=rtl871xdrv"                             >> /etc/hostapd/hostapd.conf
    echo "ieee80211n=1"                                  >> /etc/hostapd/hostapd.conf
    echo "device_name=RTL8192CU"                         >> /etc/hostapd/hostapd.conf
    echo "manufacturer=Realtek"                          >> /etc/hostapd/hostapd.conf
else
    echo "driver=nl80211"                                >> /etc/hostapd/hostapd.conf
fi

echo "hw_mode=g"                                         >> /etc/hostapd/hostapd.conf

echo "Configure: /etc/sysctl.conf"                       | tee -a ${log_file} 
echo "net.ipv4.ip_forward=1"                             >> /etc/sysctl.conf 

echo "Configure: iptables"                               | tee -a ${log_file} 
iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE
iptables -A FORWARD -i ${WAN} -o ${NIC} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${NIC} -o ${WAN} -j ACCEPT
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "Configure: /etc/network/interfaces"                                                       | tee -a ${log_file} 
echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
"                                                      > /etc/network/interfaces
echo "auto ${NIC}"                                     >>  /etc/network/interfaces
echo "allow-hotplug ${NIC}"                            >> /etc/network/interfaces
echo "iface ${NIC} inet static"                        >> /etc/network/interfaces
echo "        address ${AP_ADDRESS}"                   >> /etc/network/interfaces
echo "        netmask ${AP_NETMASK}"                   >> /etc/network/interfaces
echo "up iptables-restore < /etc/iptables.ipv4.nat"    >> /etc/network/interfaces


if [ ${CHIPSET,,} = "yes" ]
then 
    echo "Download and install: special hostapd version"    | tee -a ${log_file}
    wget "http://raspberry-at-home.com/files/hostapd.gz"    | tee -a ${log_file}
    gzip -d hostapd.gz
    chmod 755 hostapd
    cp hostapd /usr/sbin/
fi



ifdown ${NIC}                         | tee -a ${log_file}
ifup ${NIC}                           | tee -a ${log_file}
service hostapd start                 | tee -a ${log_file}
service isc-dhcp-server start         | tee -a ${log_file}

echo "Configure: startup"             | tee -a ${log_file}
update-rc.d hostapd enable            | tee -a ${log_file}
update-rc.d isc-dhcp-server enable    | tee -a ${log_file}

exit 0
