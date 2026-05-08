import 'dart:io';

class FirefoxController {
  static void launchFirefoxDetached() {
    // Fire and forget
    Process.start(
        'firefox',
        ['--kiosk', 'https://netflix.com'],
        mode: ProcessStartMode.detached,
    );
  }

  static void killFirefox() {
    Process.start(
      'killall',
      ['firefox'],
        mode: ProcessStartMode.detached,
    );
  }
}
