import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/volume_service.dart';

class VolumeHud extends StatefulWidget {
  const VolumeHud({super.key});

  @override
  State<VolumeHud> createState() => _VolumeHudState();
}

class _VolumeHudState extends State<VolumeHud> {
  late final StreamSubscription<int> volumeChangedSubscription;
  late final StreamSubscription<bool> muteChangedSubscription;

  bool muted = false;
  int volume = 0;

  double rightOffset = -30;
  Timer? hideTimer;

  bool _initialized = false;

  void showHud() {
    hideTimer?.cancel();
    setState(() => rightOffset = 20);

    hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => rightOffset = -30);
    });
  }

  @override
  void initState() {
    super.initState();

    volumeChangedSubscription = VolumeService.onVolumeChange.listen((v) {
        volume = v;
        if (!_initialized) {
            setState(() {});
            return;
        }
        setState(() {});
        showHud();
    });

    muteChangedSubscription = VolumeService.onMuteChange.listen((m) {
        muted = m;
        if (!_initialized) {
            setState(() {});
            return;
        }
        setState(() {});
        showHud();
    });

    // Mark initialized after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialized = true;
    });
  }

  @override
  void dispose() {
    volumeChangedSubscription.cancel();
    muteChangedSubscription.cancel();
    hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
      top: 0,
      bottom: 0,
      right: rightOffset,
      child: IgnorePointer(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.circular(100), 
              color: const Color(0xFF001100),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 90,
                      width: 4,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: LinearProgressIndicator(
                          value: volume / 100.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  muted 
                    ? const Icon(Icons.volume_off, size: 18, color: Colors.grey) 
                    : const Icon(Icons.volume_up, size: 18)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
