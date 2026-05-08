#!/usr/bin/bash

flutter-elinux clean
flutter-elinux pub get
flutter-elinux build elinux --target-backend-type=gbm --release