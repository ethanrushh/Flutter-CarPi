import 'dart:io';
import 'dart:developer' as devtools;
import 'package:flutter/services.dart';
import 'package:carpi/service/settings/global_settings_service.dart';
import 'package:carpi/util/can/can_interpreter.dart';
import 'package:path/path.dart' as p;

import 'package:carpi/util/platform/platform_helpers.dart';

class DisplayHandler {
  static Future<void> initialize() async {
    _isAutoBrightness = GlobalSettingsService.container.displaySettings.brightnessMode == BrightnessMode.auto;
    _pq35SwitchIlluminationStatus = DimmingInterpreter.lastIlluminationValue;

    GlobalSettingsService.onContainerChanged.listen((container) {
      _isAutoBrightness = container.displaySettings.brightnessMode == BrightnessMode.auto;
      _notifyAutoBrightnessEvent();
    });
    DimmingInterpreter.switchIlluminationChanged.listen((isLit) {
      _pq35SwitchIlluminationStatus = isLit;
      _notifyAutoBrightnessEvent();
    });

    _notifyAutoBrightnessEvent();
  }

  static late bool _isAutoBrightness;
  static bool _pq35SwitchIlluminationStatus = false;
  static void _notifyAutoBrightnessEvent() {
    if (!_isAutoBrightness) return;

    setBrightness(_pq35SwitchIlluminationStatus ? BrightnessMode.dim : BrightnessMode.bright);
  }

  static Future<void> setBrightness(BrightnessMode brightness) async {
    if (!await isRaspberryPi5()) {
      print("Not running on a Pi 5: ignoring setBrightness request to set $brightness");
      return;
    }

    late String scriptPath;

    switch (brightness) {
      case BrightnessMode.auto: return; // Expect a callback from _notifyAutoBrightnessEvent
      case BrightnessMode.bright:
        scriptPath = 'assets/scripts/max_brightness.sh';
        break;
      case BrightnessMode.dim:
        scriptPath = 'assets/scripts/min_brightness.sh';
        break;
    }

    try {
      final scriptFile = await prepareScript(scriptPath);

      if (!await scriptFile.exists()) {
        print('Brightness script not found: $scriptPath');
        return;
      }

      final result = await Process.run('/bin/bash', [scriptFile.path]);

      if (result.exitCode != 0) {
        print(
          'Brightness script failed (${result.exitCode})\n'
          'stdout: ${result.stdout}\n'
          'stderr: ${result.stderr}',
        );
      }
    } catch (e) {
      print('Exception while setting brightness: $e');
    }
  }

  static Future<File> prepareScript(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final file = File('/tmp/${p.basename(assetPath)}');

    if (!await file.exists()) {
      await file.writeAsBytes(bytes, flush: true);
      await Process.run('chmod', ['+x', file.path]);
    }

    return file;
  }
}
