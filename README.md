# Mobile Computing: Notification Matrix


## Introduction
This is the backend on the Raspberry Pi 3, that receives input (text and images) from a smartphone and displays it on a 16x16 dot matrix.

To achieve this, the Raspberry Pi activates its WiFi-Chip in Access Point mode, enabling the smartphone to connect to the Raspberry Pi. To sustain normal use of the smartphone, the Raspberry Pi uses NAT and DHCP to act as any normal WiFi router.

The Raspberry Pi listens only on a special port to receive the data to be displayed on the dot matrix.

Here is an overview of the networking with the Raspberry Pi, smartphone and the existing internet router:

![Overview](pics/RasPi-MC.svg)


## Installation
1. Install Raspian lite on a microSD card for your Raspberry Pi 3
2. Connect your Raspberry Pi to the Internet via LAN
3. Install Git ($ sudo apt-get install git)
4. Clone this repo on your Raspberry Pi
5. Run setup.sh as root
6. Connect the dot matrix via SPI to the Raspberry Pi
7. Reboot the Raspberry Pi
8. Connect your Smartphone to the Pi's WiFi network ("MC-RaspberryPi")
    - Password is: "0123456789"
    - You still will have internet access through the LAN connection of the Raspberry Pi
9. Run the App
10. Done :thumbsup:


## Technical

### Datenblatt zu MAX7219

[Max7219 Datenblatt](https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf)

[Netter Guide](https://tutorials-raspberrypi.de/led-max7219-dot-matrix-projekt-uebersicht/)
[Python Guide](https://codingworld.io/project/8x8-led-matrix-anschliessen-und-programmieren)


![pinout](http://images.gutefrage.net/media/fragen-antworten/bilder/137534877/0_big.jpg)

[Händler-Seite](https://www.az-delivery.de/products/4-x-64er-led-matrix-display?ls=de#description)

