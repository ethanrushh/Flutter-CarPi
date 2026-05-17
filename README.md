# Flutter CarPi

A Flutter-based automotive interface designed for cherry-picked Raspberry Pi 5 Hardware.

Designed for a Pi 5 with CarPiHAT Pro 5 and Waveshare 10-inch MIPI-DSI Touchscreen. 
Will run under Wayland on x86 for testing and development.

Images are generated using [Flutter-CarPi-pi-gen](https://github.com/ethanrushh/Flutter-CarPi-pi-gen)

## Features

- **Bluetooth Support**: Integrated with BlueZ for audio and connectivity.
- **CAN Bus Integration**: Support for vehicle CAN bus communication.
- **Audio Management**: Advanced audio controls including EQ and volume management.
- **Customizable UI**: Support for various wallpapers and shaders.
- **System Integration**: GPIO control and graceful system shutdown capabilities.
- **Great Performance**: 60fps, zero drops. Animations are butter.
- **Cool backgrounds**: Change your background on the fly or better yet, use a cool shader as your background.
- **Actually Usable**: Designed to be used. Buttons are big and well spaced. Good for a moving vehicle.

## An important note

This is largley bodges built upon bodges. Somehow, its actually really stable even with a bit of torture testing in my own vehicle for a long time. That being said, a lot of this is just "oh I want this" over and over with some loose housekeeping to keep things from completely going to shit. This is also my first Flutter project. Ever. If you and others have an interest in such a project, I could build this "properly" with the community so we all have an open, *free* ~~(you know who you are)~~, well built, extensible carputer OS. I'm too dumb for Yocto.

## Gallery

<img width="640" height="400" alt="image" src="https://github.com/user-attachments/assets/d7085582-bc7a-4842-a34e-dc894e2de09c" />
<img width="640" height="400" alt="image" src="https://github.com/user-attachments/assets/a12d6aa2-5545-4564-a148-f3b9094cd8eb" />
<img width="640" height="400" alt="image" src="https://github.com/user-attachments/assets/c36c8ce6-0e5b-4f47-b02f-699264e9e478" />
<img width="640" height="400" alt="image" src="https://github.com/user-attachments/assets/20386d0a-ebee-4f6c-a65c-03a2dafbbbdb" />



## State of this project

With the exact expected hardware, with the exact expected wiring and the exact expected setup (below should work from a fresh Pi OS Lite installation), with an expected vehicle (anything PQ35 should work incl. my 2010 Golf 6 GTi), this project is fully functional end to end. Local music, bluetooth audio, CAN communication and more all work perfectly. Even the EQ works an absolute treat. All settings are persistent as they should be. I use this in my own vehicle and have found it to be 100% stable and sound and work perfectly.  It easily boots fast enough off of an SD card not to be annoying or inconvenient. An NVMe HAT could take this even lower... The MZD Connect in my 2016 MX-5 was far inferior in almost every way to what this already is. Bluetooth has some hangups presently and some of the packages need to be changed to ones that Toyota have been working on publicly for thier own use. flutter-elinux is also abandoned and using the community fork is probably not ideal, though perfectly servicable for now (thanks guys, your patches have made this possible for me). If anyone cares to use this for thier own carputer, I could happily rewrite chunks of the source to better accomodate other devices. CAN instructions should already be easy to modify, and there is already code set up for a rotary encoder for a physical volume knob that was present on previous models. 

For anyone wanting to replicate this in their own vehicle (for some reason), I would be happy to provide CAD models for a 3D print of a mount for the display in the factory head unit position which honestly works incredibly well and requires zero modification to the car. Beware the CarPiHAT Pro 5 (remember there is no built in amp too) will require some auto-electrical work to get up and running. This part really isn't too bad though. Conveniently, the amplifiers are designed to be turned on from the CarPi itself, meaning they can stay on without the ignition until the CarPi is shut down either automatically or manually if told to stay on. This is absolutely awesome for a quiet listening environment. 

Video is not implemented, by design currently. Its a distraction, and until I can dig further into CAN messages and *reliably* detect when the vehicle is stationary (zero speed, handbrake up, neutral), I don't want it. I'm pretty sure this thing would already fail ADR but still. Maps also don't exist, not by design. I initially planned for them but Flutter doesn't have good mapping support on Linux at the moment and generating maps using PMTiles is easy enough but ill supported, and the other options just suck to work with. Bottom line, I can't be fucked to deal with it. If anyone cares enough, I could probably change that. My solution? Work on CarPlay/AA support (yes, I have figured out a way to actually do this) and just use that becaue Waze is superior anyway. 

## Installation

Download the latest release image (.img) and flash onto an SD card. Boot, and enjoy. On first boot, the filesystem will resize itself to the size of the SD card for you. On Linux, this can be done with:

`dd bs=4M conv=fsync oflag=direct status=progress if=/home/ethan/Downloads/pi-gen/deploy/2026-05-17-carpi-os-configured.img of=/dev/sdx`

Replace `sdx` with the path of your SD card. Back up your SD card first if you have important files! The whole thing will be erased.

## License

This project is licensed under the Non-Commercial Testing License. See [LICENSE](LICENSE) for more details.
