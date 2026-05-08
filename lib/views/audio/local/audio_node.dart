import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/audio_player_service.dart';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:carpi/views/audio/local/local_audio_browser.dart';
import 'package:path/path.dart';

class LocalAudioNode extends StatelessWidget {
  const LocalAudioNode({super.key, required this.node});

  final FileNode node;

  Future<TrackMetadata> futureMetadata() async {
    if (node.isDirectory) return TrackMetadata.empty();
    return await AudioBrowserService.instance.getTrackMetadataOrEmpty(node.fullPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureMetadata(),
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            if (asyncSnapshot.hasData) {
              final trackMeta = asyncSnapshot.data!;

              var title = node.isDirectory ? basename(node.fullPath) : (
                (trackMeta.title != null && trackMeta.artist != null) ? '${trackMeta.title} - ${trackMeta.artist}' : basename(node.fullPath)
              );

              return ListTile(
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                leading: node.isDirectory ? const Icon(Icons.folder, size: 32) : (
                  trackMeta.albumArt == null ? const Icon(Icons.music_note, size: 32) : Image.memory(trackMeta.albumArt!)
                ),
                trailing: node.isDirectory ? const Icon(Icons.arrow_right) : null,
                onTap: () {
                  // If directory, enter it
                  if (node.isDirectory) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => LocalAudioBrowserView(path: node.fullPath),
                        transitionsBuilder: (_, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                  // Otherwise, play the song (for now)
                  else {
                    AudioPlayerService.instance.selectTrack(node.fullPath);

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              );
            }

          default: break;
        }

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: Text(
            basename(node.fullPath),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 12
            ),
          ),
          leading: node.isDirectory ? const Icon(Icons.folder, size: 32) : CircularProgressIndicator(),
          trailing: node.isDirectory ? const Icon(Icons.arrow_right) : null,
        );
      }
    );
  }
}
