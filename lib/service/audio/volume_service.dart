import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:carpi/util/can/can_interpreter.dart';
import 'package:carpi/util/platform/platform_helpers.dart';
import 'package:carpi/util/script/run_py_script.dart';

class VolumeService {
  static late final StreamController<int> _volumeChangedController;
  static late final StreamController<bool> _muteChangedController;

  static Stream<int> get onVolumeChange => _volumeChangedController.stream;
  static Stream<bool> get onMuteChange => _muteChangedController.stream;

  static int _lastVolume = 0;
  static bool _lastMuted = false;

  static Future<void> initialize() async {
    _volumeChangedController = StreamController<int>.broadcast(onListen: () {
      _volumeChangedController.add(_lastVolume);
    });
    _muteChangedController = StreamController<bool>.broadcast(onListen: () {
      _muteChangedController.add(_lastMuted);
    });

    if (await isRaspberryPi5()) {
      await RpiRotaryEncoderInterop.initialize();

      RpiRotaryEncoderInterop.onVolumeChanged.listen((vol) {
        _lastVolume = vol;
        _volumeChangedController.add(vol);
      });
      RpiRotaryEncoderInterop.onMuteChanged.listen((muted) {
        _lastMuted = muted;
        _muteChangedController.add(muted);
      });
    }
    else {
      print("Not running on a Pi 5: not using volume script");
    }
  }

  static Future<void> dispose() async {
    await RpiRotaryEncoderInterop.dispose();
  }
}

class RpiRotaryEncoderInterop {
  static final StreamController<int> _volumeChangedController = StreamController<int>.broadcast();
  static final StreamController<bool> _muteChangedController = StreamController<bool>.broadcast();

  static Stream<int> get onVolumeChanged => _volumeChangedController.stream;
  static Stream<bool> get onMuteChanged => _muteChangedController.stream;

  static late final PiScriptRunner _runner;

  static Future<void> initialize() async {
    _runner = PiScriptRunner('assets/scripts/volume_control.py');
    unawaited(_runPythonScript());

    MultiFunctionWheelControlsInterpreter.mfwButtonChanged.listen((key) {
      if (key == MfwButton.leftPadUp) {
        processMfwInput(true);
      }
      else if (key == MfwButton.leftPadDown) {
        processMfwInput(false);
      }
    });
  }

  static Future<void> dispose() async {
    await _runner.dispose();
  }

  static Future<void> processMfwInput(bool up) async {
    if (!await isRaspberryPi5()) {
      print("Not running on a Pi. Ignoring.");
      return;
    }
    
    await _runner.writeLine("mfw_inst ${up ? "True" : "False"}");
  }

  static Future<void> _runPythonScript() async {
    _runner.onStdOutput.listen((line) {
      try {
        if (line.isEmpty) return;

        if (line == "M") {
          _muteChangedController.add(true);
        }
        else if (line == "U") {
          _muteChangedController.add(false);
        }
        else {
          final volume = int.tryParse(line);

          if (volume != null) {
            _volumeChangedController.add(volume);
          }
        }
      }
      catch (e) {
        print("Something went wrong trying to process a python event");
      }
    });

    _runner.onStdError.listen((line) {
        if (line.isNotEmpty) print('[python][err] $line');
    });

    await _runner.execute();
  }
}
