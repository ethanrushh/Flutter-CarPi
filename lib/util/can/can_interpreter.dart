import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:linux_can/linux_can.dart';
import 'package:logging/logging.dart';

class Pq35Interpreter {  
  static void ingest(CanDataFrame frame) {
    switch (frame.id) {
      case 0x5C1:
        MultiFunctionWheelControlsInterpreter.ingest(frame);
        break;
      case 0x635:
        DimmingInterpreter.ingest(frame);
        break;
    }
  }
}

class DimmingInterpreter {
  static bool? _lastSwitchesIlluminated;
  static final StreamController<bool> _illuminationController = StreamController<bool>.broadcast();
  static Stream<bool> get switchIlluminationChanged => _illuminationController.stream;
  static bool get lastIlluminationValue => _lastSwitchesIlluminated ?? false;

  static void ingest(CanDataFrame frame) {
    //print('Dimming frame: ${frame.data}');

    if (frame.data.length < 2) {
      print(
        'Got a 0x635 CAN frame with too little data.'
      );
      return;
    }

    final newValue = frame.data.skip(1).first > 0;

    if (newValue != _lastSwitchesIlluminated) {
      _lastSwitchesIlluminated = newValue;
      _illuminationController.add(newValue);
    }

    //devtools.log("Set illumination to $_lastSwitchesIlluminated");
  }
}

class MultiFunctionWheelControlsInterpreter {
  static MfwButton _currentButton = MfwButton.none;

  static final StreamController<MfwButton> _mfwButtonController = StreamController<MfwButton>.broadcast();
  static Stream<MfwButton> get mfwButtonChanged => _mfwButtonController.stream;

  static void ingest(CanDataFrame frame) {
    if (frame.data.isEmpty) {
      print('Got an MFW CAN frame with no data. Something has gone very wrong.');
      return;
    }

    final button = MfwButton.fromByte(frame.data.first);

    if (_currentButton != button) {
      _currentButton = button;

      _mfwButtonController.add(button);
    }
  }
}

enum MfwButton implements Comparable<MfwButton> {
  none(0x00),
  leftPadLeft(0x03),
  leftPadRight(0x02),
  leftPadUp(0x06),
  leftPadDown(0x07),
  leftPadCall(0x1A),
  mic(0x2B);

  const MfwButton(this.value);
  final int value;

  static MfwButton fromByte(int byte) 
    => MfwButton.values.firstWhere((e) => e.value == byte, orElse: () => MfwButton.none);
  
  @override
  int compareTo(MfwButton other) {
    return value.compareTo(other.value);
  }
}
