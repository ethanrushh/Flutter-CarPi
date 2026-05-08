import 'dart:async';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/audio_player_service.dart';
import 'package:carpi/util/number_formatting.dart';

class AudioProgressBar extends StatefulWidget {
  const AudioProgressBar({super.key});

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {  
  late final StreamSubscription<Duration> positionSubscription;
  //late final StreamSubscription<Duration> durationSubscription;
  Duration currentPos = Duration.zero;
  double relativeProgress = 0;

  late final StreamSubscription metadataStreamSubscription;
  TrackMetadata currentMetadata = TrackMetadata.empty();

  void updateProgressSafely() {
    if (mounted) {
      setState(() {
        if (currentMetadata.duration.inMilliseconds <= 0) { // To prevent a div by zero error
          relativeProgress = 0;
        }
        else {
          relativeProgress = currentPos.inMilliseconds / currentMetadata.duration.inMilliseconds;
        }
      });
    }
  }

  @override void initState() {
    positionSubscription = AudioPlayerService.instance.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
            currentPos = pos;
        });
      }
      else { currentPos = pos; }
      updateProgressSafely();
    });

    // durationSubscription = AudioPlayerService.instance.onDurationChanged.listen((duration) {
    //   if (mounted) {
    //     setState(() {
    //         currentDuration = duration;
    //     });
    //   }
    //   else { currentDuration = duration; }
    //   updateProgressSafely();
    // });

    metadataStreamSubscription = AudioPlayerService.instance.onMetadataChanged.listen((meta) {
      if (mounted) {
        setState(() {
          if (meta.artist != null) {
            meta.artist = meta.artist!.split(" • Video Available")[0].split(" • Lossless")[0]; // Hack to get around Spotify being annoying
          }
          currentMetadata = meta;
        }); 
      }
      else { currentMetadata = meta; }
    });
    currentMetadata = AudioPlayerService.instance.currentMetadata;

    super.initState();
  }

  @override void dispose() {
    positionSubscription.cancel();
    //durationSubscription.cancel();
    metadataStreamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 12,
          child: Text(formatDurationMmSs(currentPos), textAlign: TextAlign.left, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8),)
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(value: relativeProgress, minHeight: 4, color: Theme.of(context).hintColor)
            ),
          ),
        ),
        SizedBox(
          width: 30,
          height: 12,
          child: Text(formatDurationMmSs(currentMetadata.duration), textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8),)
        ),
      ]
    );
  }
}
