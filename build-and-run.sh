#!/usr/bin/bash

./build.sh

sudo /home/pi/Flutter-CarPi/Flutter-CarPi/build/elinux/arm64/release/bundle/carpi -r 90 --force-scale-factor=2 -b /home/pi/Flutter-CarPi/Flutter-CarPi/build/elinux/arm64/release/bundle
