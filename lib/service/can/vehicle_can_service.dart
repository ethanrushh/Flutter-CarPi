import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:carpi/util/can/can_interpreter.dart';
import 'package:carpi/util/platform/platform_helpers.dart';
import 'package:linux_can/linux_can.dart';

class VehicleCanService {
  static late final CanSocket _socket;

  static Future<void> initialize() async {
    if (await isRaspberryPi5()) {
      final linuxcan = LinuxCan.instance;

      final device = linuxcan.devices.singleWhere((device) => device.networkInterface.name == 'can0');

      print("Starting CAN service");

      unawaited(readCan(device));
    }
    else {
      print("Non-Pi 5 detected. Skipping CAN service");
    }
  }

  static Future<void> readCan(CanDevice device) async {
    try {
      // Actually open the device, so we can send/receive frames.
      _socket = device.open();

      // Listen on a Stream of CAN frames
      await for (final frame in _socket.receive(filter: CanFilter.or([
        CanFilter.idEquals(0x5C1),
        CanFilter.idEquals(0x635),
      ]))) {
        switch (frame) {
          case CanDataFrame dataFrame:
            Pq35Interpreter.ingest(dataFrame);
            break;
          
          default: break;
        }
      }
    }
    catch (e) {
      print('An error occured trying to read CAN $e');
    }
  }

  static Future<void> dispose() async {
    await _socket.close();
  }
}
