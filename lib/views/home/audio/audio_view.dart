import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/audio_player_service.dart';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:carpi/views/home/audio/audio_progress_bar.dart';
import 'package:carpi/views/home/audio/toggle_pause_button.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  late final StreamSubscription metadataStreamSubscription;
  TrackMetadata currentMetadata = TrackMetadata.empty();

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    metadataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //FlowingGradientBackground(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox.expand(
            child: Column(
              children: [
                Spacer(flex: 4),

                // Album artwork and playing info
                Row(
                  spacing: 32,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: currentMetadata.albumArt != null ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ] : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: currentMetadata.albumArt == null 
                        ? currentMetadata.bluetooth ? const Icon(Icons.bluetooth_audio_rounded, size: 160) : const Icon(Icons.music_note, size: 160) 
                        : Image.memory(currentMetadata.albumArt!, height: 160, width: 160, gaplessPlayback: true),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentMetadata.title ?? '-',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.black.withValues(alpha: 0.35),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis
                          ),
                          Text(
                            currentMetadata.artist ?? '-',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).hintColor,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.black.withValues(alpha: 0.35),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis
                          )
                        ]
                      ),
                    )
                  ],
                ),

                Spacer(flex: 6),
                
                // Progress
                AudioProgressBar(),

                Spacer(),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await AudioPlayerService.instance.previous();
                      },
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 42,
                    ),
                    TogglePauseButton(),
                    IconButton(
                      onPressed: () async {
                        await AudioPlayerService.instance.next();
                      },
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 42,
                    ),
                  ],
                )
              ]
            ),
          ),
        )
      ]
    );
  }
}
