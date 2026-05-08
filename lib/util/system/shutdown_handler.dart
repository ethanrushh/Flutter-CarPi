import 'dart:io';

import 'package:carpi/service/shutdown/shutdown_service.dart';

typedef ShutdownHandler = Future<void> Function();

class ShutdownCoordinator {
  final _handlers = <ShutdownHandler>[];
  bool _running = false;

  void register(ShutdownHandler handler) {
    _handlers.add(handler);
  }

  Future<void> run() async {
    if (_running) return;
    _running = true;

    for (final handler in _handlers) {
      try {
        await handler();
      } catch (_) {}
    }
    
    await ShutdownService.shutdown(false);

    await Process.run(
      'sudo',
      ['shutdown', '-h', 'now'],
    );
  }
}
