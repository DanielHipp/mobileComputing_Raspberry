#!/bin/bash

# Run as root!
# What this script does:
# - Updates packages of raspberry pi
# - Installs needed packages for the project
# - Registers services to run at startup



## Update repo
apt-get update
apt-get upgrade


# Install needed packages
apt-get install python-dev python-numpy python3-numpy


# ToDo: Clone adafruit repos and install for our wrapper


# Set up WiFi-Network AP
./WLAN/setup_AccessPoint.sh


# Install our server to receive data from smartphone


echo "Please reboot your Raspberry Pi!"
