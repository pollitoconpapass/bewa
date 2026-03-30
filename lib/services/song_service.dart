import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/info_models.dart';

class SongService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Search songs
  Future<List<SongResult>> searchSong(String query, {int limit = 20}) async {
    try {
      var searchList = await _yt.search.search(query);

      return searchList.take(limit).map((video) {
        return SongResult(
          id: video.id.value,
          title: video.title,
          url: video.url,
          artist: video.author,
          artistId: video.channelId.value,
          thumbnail: video.thumbnails.highResUrl,
          duration: video.duration?.inSeconds.toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Get direct audio stream info
  Future<AudioOnlyStreamInfo> getAudioStream(String videoUrl) async {
    try {
      var videoId = VideoId(videoUrl);
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Filter for mp4 (m4a) container - best for iOS compatibility
      var m4aStreams = manifest.audioOnly.where(
        (s) => s.container == StreamContainer.mp4,
      );

      if (m4aStreams.isNotEmpty) {
        // Get highest bitrate m4a
        var audioStream = m4aStreams.withHighestBitrate();
        print("Selected M4A Stream: ${audioStream.bitrate}, URL: ${audioStream.url}");
        return audioStream;
      }

      // Fallback to highest bitrate of any container (could be webm)
      final fallback = manifest.audioOnly.withHighestBitrate();
      print("Selected Fallback Stream (Container: ${fallback.container}): ${fallback.url}");
      return fallback;
    } catch (e) {
      throw Exception('Failed to get audio stream: $e');
    }
  }

  /// Download audio
  Future<void> downloadAudio(String videoUrl, {String? outputPath}) async {
    try {
      var videoId = VideoId(videoUrl);
      var video = await _yt.videos.get(videoId);
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Filter for mp4 (m4a) container
      var audioStreams = manifest.audioOnly.where(
        (s) => s.container == StreamContainer.mp4,
      );
      AudioOnlyStreamInfo audioStreamInfo;

      if (audioStreams.isEmpty) {
        audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      } else {
        audioStreamInfo = audioStreams.reduce(
          (curr, next) =>
              curr.bitrate.bitsPerSecond > next.bitrate.bitsPerSecond
              ? curr
              : next,
        );
      }

      String fullPath;
      if (outputPath != null) {
        fullPath = outputPath;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        // Sanitize filename
        final fileName = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        fullPath = p.join(
          directory.path,
          '$fileName.${audioStreamInfo.container.name}',
        );
      }

      var file = File(fullPath);
      if (file.existsSync()) {
        await file.delete();
      }

      var output = file.openWrite();
      var stream = _yt.videos.streamsClient.get(audioStreamInfo);

      await stream.pipe(output);
      await output.flush();
      await output.close();
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
