# Flutter CarPi

A Flutter-based automotive interface designed for cherry-picked Raspberry Pi 5 Hardware.

Designed for a Pi 5 with CarPiHAT Pro 5 and Waveshare 10-inch MIPI-DSI Touchscreen. 
Will run under Wayland on x86 for testing and development.


## Features

- **Bluetooth Support**: Integrated with BlueZ for audio and connectivity.
- **CAN Bus Integration**: Support for vehicle CAN bus communication.
- **Audio Management**: Advanced audio controls including EQ and volume management.
- **Customizable UI**: Support for various wallpapers and shaders.
- **System Integration**: GPIO control and system shutdown capabilities.

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

git clone https://github.com/ethanrushh/elinux-carpi
cd elinux-carpi
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
WorkingDirectory=/home/pi/elinux-carpi/build/elinux/arm64/release/bundle
ExecStart=/home/pi/elinux-carpi/launch.sh
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

And reboot.

## License

This project is licensed under the Non-Commercial Testing License. See [LICENSE](LICENSE) for more details.
