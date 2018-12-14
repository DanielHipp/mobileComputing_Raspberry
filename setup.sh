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
apt-get install python-dev


# Set up WiFi-Network AP
./WLAN/setup_AccessPoint.sh



echo "Please reboot your Raspberry Pi!"
