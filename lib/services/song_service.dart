import 'dart:io';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

import '../models/info_models.dart';

class SongService {
  final String executable;

  SongService({this.executable = 'yt-dlp'});

  /// Search songs
  Future<List<SongResult>> searchSong(String query, {int limit = 10}) async {
    final result = await Process.run(executable, [
      'ytsearch$limit:$query',
      '--dump-json',
    ]);

    if (result.exitCode != 0) {
      throw Exception('Search failed: ${result.stderr}');
    }

    final lines = LineSplitter.split(result.stdout);

    return lines.map((line) {
      final json = jsonDecode(line);
      return SongResult.fromJson(json);
    }).toList();
  }

  /// Get direct audio stream URL
  Future<String> getAudioUrl(String videoUrl) async {
    final result = await Process.run(executable, [
      '-f',
      'bestaudio',
      '--no-playlist', // -> prevents a queue of audio streams
      '-g',
      videoUrl,
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to get audio URL: ${result.stderr}');
    }

    return (result.stdout as String).trim();
  }

  /// Play the audio stream
  Future<void> playAudio(String audioUrl) async {
    final player = AudioPlayer();
    await player.setUrl(audioUrl);
    await player.play();
  }

  /// Download audio as mp3
  Future<void> downloadAudio(String videoUrl, {String? outputPath}) async {
    final args = [
      '-x',
      '--audio-format',
      'mp3',
      '--no-playlist',
      if (outputPath != null) '-o',
      if (outputPath != null) outputPath,
      videoUrl,
    ];

    final process = await Process.start(executable, args);

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception('Download failed');
    }
  }
}
