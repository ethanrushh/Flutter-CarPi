import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carpi/service/audio/audio_player_service.dart';

class TogglePauseButton extends StatefulWidget {
  const TogglePauseButton({
    super.key,
  });

  @override
  State<TogglePauseButton> createState() => _TogglePauseButtonState();
}

class _TogglePauseButtonState extends State<TogglePauseButton> {
  late final StreamSubscription _isPlayingSubscription;
  bool playing = false;

  @override void initState() {
    _isPlayingSubscription = AudioPlayerService.instance.onIsPlayingChanged.listen((playing) {
      if (mounted) {
        setState(() {
          this.playing = playing;
        });
      }
      else { this.playing = playing; }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isPlayingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await AudioPlayerService.instance.togglePause();
      }, 
      icon: Icon(playing ? Icons.pause_circle_rounded : Icons.play_arrow_rounded),
      iconSize: 64,
    );
  }
}
