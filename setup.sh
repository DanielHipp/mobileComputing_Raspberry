#!/bin/bash

# Run as root!
#
# What this script does:
# - Updates packages of raspberry pi
# - Installs needed packages for the project
# - Registers services to run at startup


## Enable I²C and Add Pi to i2c group to easy usage
echo "dtparam=i2c1=on" >> /boot/config.txt
adduser pi i2c

## Update repo
apt-get update && apt-get upgrade -y


# Install needed packages
apt-get install -yq i2c-tools build-essential python-dev  python-numpy python-smbus python-imaging python-setuptools


# Clone adafruit repos and install for our wrapper
git clone https://github.com/adafruit/Adafruit_Python_LED_Backpack.git
cd Adafruit_Python_LED_Backpack
sudo python setup.py install
cd ..

# Set up WiFi-Network AP
USB=0
OPTIND=1         # Reset in case getopts has been used previously in the shell
while getopts "u:" opt; do
    case "$opt" in
    u)  USB=1
        ;;
    esac
done
shift $((OPTIND-1))

if [ $USB -eq 1 ]
then
	./WLAN/setup_AccessPoint.sh -u
else
	./WLAN/setup_AccessPoint.sh
fi

# Install our server to receive data from smartphone
dir=$(pwd)
(crontab -l 2>/dev/null; echo "python $(dir)/start_matrix_server.py &") | crontab -


echo "
Please reboot your Raspberry Pi!"
