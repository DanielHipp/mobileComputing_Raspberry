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
# ToDo: Set constant IP for Smartphone and listen to it
./WLAN/setup_AccessPoint.sh


# Install our server to receive data from smartphone


echo "Please reboot your Raspberry Pi!"
