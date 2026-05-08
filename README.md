# Flutter CarPi

A Flutter-based automotive interface designed for cherry-picked Raspberry Pi 5 Hardware.

Designed for a Pi 5 with CarPiHAT Pro 5 and Waveshare 10-inch MIPI-DSI Touchscreen. 
Will run under Wayland on x86 for testing and development.

## Features

- **Bluetooth Support**: Integrated with BlueZ for audio and connectivity.
- **CAN Bus Integration**: Support for vehicle CAN bus communication.
- **Audio Management**: Advanced audio controls including EQ and volume management.
- **Customizable UI**: Support for various wallpapers and shaders.
- **System Integration**: GPIO control and graceful system shutdown capabilities.
- **Great Performance**: 60fps, zero drops. Animations are butter.

## An important note

This is largley bodges built upon bodges. Somehow, its actually really stable even with a bit of torture testing in my own vehicle for a long time. That being said, a lot of this is just "oh I want this" over and over with some loose housekeeping to keep things from completely going to shit. This is also my first Flutter project. Ever. If you and others have an interest in such a project, I could build this "properly" with the community so we all have an open, *free* ~~(you know who you are)~~, well built, extensible carputer OS. I'm too dumb for Yocto.

## Gallery




## State of this project

With the exact expected hardware, with the exact expected wiring and the exact expected setup (below should work from a fresh Pi OS Lite installation), with an expected vehicle (anything PQ35 should work incl. my 2010 Golf 6 GTi), this project is fully functional end to end. Local music, bluetooth audio, CAN communication and more all work perfectly. Even the EQ works an absolute treat. All settings are persistent as they should be. I use this in my own vehicle and have found it to be 100% stable and sound and work perfectly.  It easily boots fast enough off of an SD card not to be annoying or inconvenient. An NVMe HAT could take this even lower... The MZD Connect in my 2016 MX-5 was far inferior in almost every way to what this already is. Bluetooth has some hangups presently and some of the packages need to be changed to ones that Toyota have been working on publicly for thier own use. flutter-elinux is also abandoned and using the community fork is probably not ideal, though perfectly servicable for now (thanks guys, your patches have made this possible for me). If anyone cares to use this for thier own carputer, I could happily rewrite chunks of the source to better accomodate other devices. CAN instructions should already be easy to modify, and there is already code set up for a rotary encoder for a physical volume knob that was present on previous models. 

For anyone wanting to replicate this in their own vehicle (for some reason), I would be happy to provide CAD models for a 3D print of a mount for the display in the factory head unit position which honestly works incredibly well and requires zero modification to the car. Beware the CarPiHAT Pro 5 (remember there is no built in amp too) will require some auto-electrical work to get up and running. This part really isn't too bad though. Conveniently, the amplifiers are designed to be turned on from the CarPi itself, meaning they can stay on without the ignition until the CarPi is shut down either automatically or manually if told to stay on. This is absolutely awesome for a quiet listening environment. 

Video is not implemented, by design currently. Its a distraction, and until I can dig further into CAN messages and *reliably* detect when the vehicle is stationary (zero speed, handbrake up, neutral), I don't want it. I'm pretty sure this thing would already fail ADR but still. Maps also don't exist, not by design. I initially planned for them but Flutter doesn't have good mapping support on Linux at the moment and generating maps using PMTiles is easy enough but ill supported, and the other options just suck to work with. Bottom line, I can't be fucked to deal with it. If anyone cares enough, I could probably change that. My solution? Work on CarPlay/AA support (yes, I have figured out a way to actually do this) and just use that becaue Waze is superior anyway. 

## Installation

Setup hint:

```
sudo apt update
sudo apt full-upgrade -y
sudo apt install git -y
git clone https://github.com/flutter-elinux/flutter-elinux.git
sudo mv flutter-elinux /opt/
export PATH=$PATH:/opt/flutter-elinux/bin
echo "PATH=$PATH:/opt/flutter-elinux/bin" >> ~/.bashrc
sudo apt install unzip curl clang cmake pkg-config -y
sudo apt install libglib2.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav libinput-dev libsystemd-dev libspa-0.2-bluetooth -y
sudo apt install pipewire pipewire-audio wireplumber -y
flutter-elinux doctor

sudo usermod -aG render pi
sudo groupadd -f gpio
sudo usermod -aG gpio pi

sudo tee /etc/udev/rules.d/99-gpio.rules > /dev/null <<EOF
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
EOF

loginctl enable-linger pi

sudo udevadm control --reload-rules
sudo udevadm trigger

sudo apt install plymouth plymouth-themes -y

git clone https://github.com/ethanrushh/Flutter-CarPi
cd Flutter-CarPi
./build.sh

mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/carpi.service

Fill with:
===========================

[Unit]
Description=CarPi
After=pipewire.service pulseaudio.service wireplumber.service
Requires=pipewire.service wireplumber.service pulseaudio.service

[Service]
Type=simple
WorkingDirectory=/home/pi/Flutter-CarPi/build/elinux/arm64/release/bundle
ExecStart=/home/pi/Flutter-CarPi/launch.sh
Restart=on-failure
RestartSec=2
Environment=PATH=/opt/flutter-elinux/bin:/usr/local/bin:/usr/bin:/bin
StandardOutput=file:/home/pi/carpi.log
StandardError=file:/home/pi/carpi.log

[Install]
WantedBy=default.target

===========================

systemctl --user enable --now carpi.service
wpctl set-default <eq node id, seems to usually be 37>

sudo nano /etc/systemd/system/can0.service

Fill with:
===========================

[Unit]
Description=CAN Setup
After=network.target

[Service]
Type=oneshot
User=root
ExecStart=ip link set can0 up type can bitrate 100000
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

===========================

sudo systemctl enable can0.service

sudo mkdir -p /etc/wireplumber/wireplumber.conf.d
sudo nano /etc/wireplumber/wireplumber.conf.d/50-bluez-no-seat.conf


Fill with:
===========================

wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}

===========================


sudo nano /etc/wireplumber/wireplumber.conf.d/50-disable-suspend-all-alsa.conf

Fill with:
===========================

monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "~alsa_output.*"
      },
      {
        node.name = "~alsa_input.*"
      }
    ],
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]

===========================

Edit `/etc/bluetooth/main.conf` and set `AutoEnable=false`



```

Reboot, wait for the UI to load then reboot one more time for the app to place Pipewire stuff where it needs to be.

Importantly, enjoy!

## License

This project is licensed under the Non-Commercial Testing License. See [LICENSE](LICENSE) for more details.
