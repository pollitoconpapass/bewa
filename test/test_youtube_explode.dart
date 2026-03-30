import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  print('Searching for "Tu Carcel"...');
  
  try {
    var searchList = await yt.search.search('Tu Carcel');
    print('Found ${searchList.length} results:');
    
    for (var video in searchList.take(5)) {
      print('Title: ${video.title}');
      print('Author: ${video.author}');
      print('URL: ${video.url}');
      print('Duration: ${video.duration}');
      print('Thumbnail: ${video.thumbnails.highResUrl}');
      print('---');
      
      // Test stream URL extraction for the first result
      if (video == searchList.first) {
        print('Testing stream URL extraction for the first result...');
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioStream = manifest.audioOnly.withHighestBitrate();
        print('Audio Stream URL found: ${audioStream.url.toString().substring(0, 100)}...');
        print('---');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    yt.close();
  }
}
