#!/bin/bash

# Run as root!
#
# What this script does:
# - Updates packages of raspberry pi
# - Installs needed packages for the project
# - Registers services to run at startup


## Test if I²C is enabled and enable I²C otherwise
## Add Pi to i2c group to easy usage
ITWOCLOADED=`lsmod | grep i2c_`
if [[ -z "$ITWOCLOADED" ]]
then
	echo "dtparam=i2c1=on" >> /boot/config.txt
	adduser pi i2c
fi

## Update repo
apt-get update && apt-get upgrade


# Install needed packages
apt-get install i2c-tools
# Install Python 2 packages
apt-get install python-dev  python-numpy
# Install Python 3 packages
apt-get install python3-dev python3-numpy


# ToDo: Clone adafruit repos and install for our wrapper


# Set up WiFi-Network AP
# ToDo: Set constant IP for Smartphone and listen to it
./WLAN/setup_AccessPoint.sh


# Install our server to receive data from smartphone


echo "Please reboot your Raspberry Pi!"
