# Mobile Computing: Notification Matrix


## Introduction
This is the backend on the Raspberry Pi 3, that receives input (text and images) from a smartphone and displays it on an 16x16 dot matrix.

To achieve this, the Raspberry Pi activates the WiFi-Chip in Access Point mode, enabling the smartphone to connect to the Raspberry Pi. To sustain normal use of the smartphone, the Raspberry Pi uses NAT and DHCP to act as any normal WiFi router.

The Raspberry Pi only listens on a special port to receive the data, that is to be displayed on the dot matrix.


## Installation
1. Install Raspian on a microSD card for your Raspberry Pi 3
2. Connect your Raspberry Pi to the Internet via LAN
3. Clone this repo on your Raspberry Pi
4. Run setup.sh as root
5. Reboot the Raspberry Pi
6. Connect your Smartphone to the Pi's WiFi network
7. Run the App
8. Done :thumbsup:


## Technical

### Datenblatt zu MAX7219

[Max7219](https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf)

[netter Guide](https://tutorials-raspberrypi.de/led-max7219-dot-matrix-projekt-uebersicht/)
[Python Guide](https://codingworld.io/project/8x8-led-matrix-anschliessen-und-programmieren)


![pinout](http://images.gutefrage.net/media/fragen-antworten/bilder/137534877/0_big.jpg)

[händler Seite](https://www.az-delivery.de/products/4-x-64er-led-matrix-display?ls=de#description)

