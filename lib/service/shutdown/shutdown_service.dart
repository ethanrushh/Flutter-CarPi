import 'dart:developer' as devtools show log;
import 'dart:io';


class ShutdownService {
  static List<Future<Null> Function()> shutdownSteps = [];

  static Future<void> shutdown(bool shouldExit) async {
    print("Gracefully shutting down with ${shutdownSteps.length} steps");

    for (final step in shutdownSteps) {
      try {
        await step();
      }
      catch (_) { }
    }

    if (shouldExit) {
      exit(0);
    }
  }
}
