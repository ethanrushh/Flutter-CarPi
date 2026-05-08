import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'dart:developer' as devtools show log;


const Iterable<String> supportedExtensions = [".mp3", ".flac", ".aac", ".wav", ".m4a"];

class FileNode {
  final bool isDirectory;
  final String fullPath;

  FileNode(this.isDirectory, this.fullPath);
}

class TrackMetadata {
  String? title;
  String? album;
  String? artist;
  Uint8List? albumArt;
  bool bluetooth;
  Duration duration;

  TrackMetadata(this.title, this.album, this.artist, this.albumArt, this.bluetooth, this.duration);

  factory TrackMetadata.empty() => TrackMetadata(null, null, null, null, false, Duration.zero);
}

class AudioBrowserService {
  static final instance = AudioBrowserService();

  Future<List<FileNode>> getNodesInDirectory(String path) async {
    print("AudioBrowserService: Executing getNodesInDirectory");

    final dir = Directory(path);
    final List<FileNode> result = [];

    print("AudioBrowserService: Got dir at $path eval as ${dir.absolute.path}");

    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      print("AudioBrowserService: Scanned ${entity.path}");

      if (
        // If it is a file *and* a supported type, or if its a directory (supported by default)
        (entity is File && supportedExtensions.contains(extension(entity.absolute.path).toLowerCase())) 
        || 
        entity is Directory
      ) {
        result.add(FileNode(
          entity is Directory,
          entity.absolute.path
        ));
      }
    }

    print("AudioBrowserService: Success with getNodesInDirectory");

    return result;
  }

  Future<TrackMetadata> getTrackMetadataOrEmpty(String path) async {
    try {
      final metadata = readMetadata(File(path), getImage: true);
      
      return TrackMetadata(metadata.title, metadata.album, metadata.artist, metadata.pictures.firstOrNull?.bytes, false, metadata.duration ?? Duration.zero);
    }
    catch (e) {
      print('Failed to get track metadata for $path because $e');

      return TrackMetadata.empty();
    }
  }
}
