import 'dart:io';

Future<bool> isRaspberryPi5() async {
  final file = File('/proc/device-tree/model');

  if (!await file.exists()) return false;

  final model = await file.readAsString();
  return model.contains('Raspberry Pi 5');
}
