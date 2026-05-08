import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:carpi/util/platform/platform_helpers.dart';
import 'package:carpi/util/script/run_py_script.dart';
import 'package:carpi/util/system/shutdown_handler.dart';
import 'dart:developer' as devtools show log;

class GpioPowerService {
  static late final PiScriptRunner _runner;
  static final ShutdownCoordinator _coordinator = ShutdownCoordinator();

  static bool _shutdownRequested = false;
  static bool _ignLow = false;

  static late final StreamController<bool> _ignLowController;
  static Stream<bool> get isIgnLow => _ignLowController.stream;

  static bool get ignitionOverride => _ignitionOverride;
  static bool _ignitionOverride = false;


  static Future<void> initialize() async {
    _ignLowController = StreamController<bool>.broadcast(onListen: () {
      _ignLowController.add(_ignLow);
    });

    _runner = PiScriptRunner("assets/scripts/safe_shutdown.py");
    
    if (!await isRaspberryPi5() || kDebugMode) {
      print('Detected not running on Pi 5 - shutdown script will not be run');
      return;
    }

    _runner.onStdOutput.listen((line) {
      print("[python][safe_shutdown.py] $line");

      if (_ignitionOverride) {
        _ignLow = false;
        _ignLowController.add(_ignLow);
        return;
      }

      if (_shutdownRequested) return; // If we're waiting to shut down, we shouldn't process any more info

      if (line == "IGN LOW") {
        _ignLow = true;
        _ignLowController.add(_ignLow);
      }
      else if (line == "IGN OFF") {
        // Shut down the system
        triggerShutdown();
      }
      else if (line == "IGN HIGH") {
        _ignLow = false;
        _ignLowController.add(_ignLow);
      }
    });

    unawaited(_runner.execute());
  }

  static Future<void> triggerShutdown() async {
    if (!await isRaspberryPi5()) {
      print('Not running on a Pi 5. Triggered shutdown will be ignored');
      return;
    }

    _shutdownRequested = true;
    unawaited(_coordinator.run());
  }

  static void registerShutdownProcedure(ShutdownHandler procedure) {
    _coordinator.register(procedure);
  }

  static void setIgnitionOverride(bool override) {
    _ignitionOverride = override;

    if (override) {
      _ignLow = false;
      _ignLowController.add(_ignLow);
    }
  }

  static Future<void> dispose() async {
    await _runner.dispose();
  }
}
