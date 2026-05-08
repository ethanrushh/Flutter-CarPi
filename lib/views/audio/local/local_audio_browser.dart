import 'package:flutter/material.dart';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:carpi/util/platform_utils.dart';
import 'package:carpi/views/audio/local/audio_node.dart';
import 'package:path/path.dart';

class LocalAudioBrowserView extends StatelessWidget {
  const LocalAudioBrowserView({super.key, this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path == null ? 'Local Browser' : basename(path!)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icon(Icons.close)
            ),
          )
        ]
      ),
      body: LocalAudioBrowser(path: path),
    );
  }
}

class LocalAudioBrowser extends StatelessWidget {
  const LocalAudioBrowser({super.key, this.path});

  final String? path;

  Future<List<FileNode>> _getAudioNodes() async {
    var searchPath = path;

    if (path == null) {
      print("LocalAudioBrowser: No path, using Music dir");

      // If no path is set, try use the base path
      final homeDir = PlatformUtils.getCurrentPlatformHomeDir();

      if (homeDir == null) {
        print('Unable to find a valid search path (got null for both incoming path and home directory)');
        return [];
      }

      searchPath = '$homeDir/Music/';
    }

    if (searchPath == null) {
      print("LocalAudioBrowser: No searchPath. Returning null.");

      return []; // If we can't find a valid home directory
    }
    else {
      print("LocalAudioBrowser: Getting audio nodes");
      final nodes = await AudioBrowserService.instance.getNodesInDirectory(searchPath);
      print("LocalAudioBrowser: Got ${nodes.length} nodes");
      return nodes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAudioNodes(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length + 1,
                itemBuilder:(context, index) {
                  if (index < snapshot.data!.length) {
                    final node = snapshot.data![index];
                    return LocalAudioNode(node: node);
                  }

                  return Opacity(
                    opacity: 0.6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: Divider(thickness: 1),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '${snapshot.data!.length} items', 
                              style: Theme.of(context).textTheme.labelLarge
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: Divider(thickness: 1),
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                },
              );
            }

            default: print("${snapshot.connectionState} - ${snapshot.hasData}"); break; // Why does dart make me do this? I don't fucking care if its got fall-through conditions...
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
