import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools show log;

class PiScriptRunner {
  final StreamController<String> _stdOutputController = StreamController<String>.broadcast();
  final StreamController<String> _stdErrorController = StreamController<String>.broadcast();

  Stream<String> get onStdOutput => _stdOutputController.stream;
  Stream<String> get onStdError => _stdErrorController.stream;

  Process? _pythonProcess;
  String? _pythonScriptPath;

  final String bundlePath;

  PiScriptRunner(this.bundlePath) { }

  Future<void> execute() async {
    print("Attempting to execute script $bundlePath");

    if (_pythonProcess != null || _pythonScriptPath != null) {
      throw Exception("Already executing");
    }

    await _runPythonScript(bundlePath);
  }

  Future<void> dispose() async {
    if (_pythonProcess != null) {
      _pythonProcess!.kill(ProcessSignal.sigterm);
      _pythonProcess = null;
    }

    if (_pythonScriptPath != null) {
      final pythonFile = File(_pythonScriptPath!);
      if (await pythonFile.exists()) {
        await pythonFile.delete();
        _pythonScriptPath = null;
      }
    }
  }

  Future<String> _getOrCreatePythonScript(String bundlePath) async {
    final scriptData = await rootBundle.loadString(bundlePath);

    final rand = Random.secure();
    final randomString = List.generate(8, (_) => rand.nextInt(36).toRadixString(36)).join();

    final scriptDir = '${Directory.systemTemp.path}/$randomString-volume_control.py';

    print("Created py script at $scriptDir for $bundlePath");

    final tempFile = File(scriptDir);
    await tempFile.writeAsString(scriptData, flush: true);

    return scriptDir;
  }

  Future<void> writeLine(String input) async {
    if (_pythonProcess == null) return;

    _pythonProcess!.stdin.writeln(input);
    await _pythonProcess!.stdin.flush();
  }

  Future<void> _runPythonScript(String bundlePath) async {
    final pythonScriptPath = await _getOrCreatePythonScript(bundlePath);
    _pythonScriptPath = pythonScriptPath;

    print("Using py script path $pythonScriptPath");

    final pythonProcess = await Process.start(
      'python3',
      ["-u", pythonScriptPath],
      mode: ProcessStartMode.normal
    );
    _pythonProcess = pythonProcess;

    // Forward stdout
    pythonProcess.stdout.transform(SystemEncoding().decoder).listen((line) {
      for (var l in line.split('\n')) {
        _stdOutputController.add(l);
      }
    });

    // Forward stderr
    pythonProcess.stderr.transform(SystemEncoding().decoder).listen((line) {
      for (var l in line.split('\n')) {
        _stdErrorController.add(l);
      }
    });

    print("Executing $pythonScriptPath");

    // Optional: wait for the process to exit
    final exitCode = await pythonProcess.exitCode;
    print('Python script exited with code $exitCode');
  }
}
