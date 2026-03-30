import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _sessionInitialized = false;
  AudioPlayer get player => _player;

  Future<void> _ensureSessionInitialized() async {
    if (_sessionInitialized) return;

    final session = await AudioSession.instance;
    // Use the optimized music configuration for iOS
    await session.configure(const AudioSessionConfiguration.music());

    _sessionInitialized = true;
  }

  /// Play the audio stream
  Future<void> playAudio(AudioOnlyStreamInfo streamInfo) async {
    try {
      print("Attempting to play: ${streamInfo.url}");
      await _ensureSessionInitialized();

      final session = await AudioSession.instance;
      await session.setActive(true);

      // Reset the player state
      await _player.stop();

      // Load the stream.
      // preload: false prevents the proxy from failing during the initial handshake on some iOS versions.
      await _player.setAudioSource(
        AudioSource.uri(
          streamInfo.url,
          headers: {'User-Agent': 'com.google.android.youtube'},
        ),
        preload: false,
      );

      await _player.play();
    } on PlayerException catch (e) {
      print("AudioPlayer Error: ${e.code} - ${e.message}");
      rethrow;
    } on PlayerInterruptedException catch (e) {
      print("AudioPlayer Connection aborted: ${e.message}");
      rethrow;
    } catch (e, stack) {
      print("Unexpected error in AudioService.playAudio: $e");
      print(stack);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
