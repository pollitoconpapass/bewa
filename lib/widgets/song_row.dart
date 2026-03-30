import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import '../models/info_models.dart';
import '../services/song_service.dart';
import '../services/audio_service.dart';
import '../services/db_connector.dart';
import '../services/authorizer.dart';
import '../themes/palette.dart';

class SongRow extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongRow({super.key, required this.song, this.onTap});

  @override
  State<SongRow> createState() => _SongRowState();
}

class _SongRowState extends State<SongRow> {
  final SongService _songService = SongService();
  final AudioService _audioService = AudioService();
  bool _isDownloading = false;
  bool _isFavorite = false; // This should ideally be passed or fetched
  bool _isPlaying = false;

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final remainingSeconds = (duration.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );
    return '$minutes:$remainingSeconds';
  }

  Future<void> _playSong() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    try {
      // Get the direct audio stream info and play
      final streamInfo = await _songService.getAudioStream(widget.song.url);
      await _audioService.playAudio(streamInfo);

      // Update play count in DB
      final user = await Authorizer.getCurrentUser();
      if (user != null) {
        var db = await DBConnector.connect();

        // Check if song exists, if not insert it
        var existingSong = await DBConnector.getSong(
          db,
          widget.song.externalId,
        );
        String songId;
        if (existingSong == null) {
          // Insert song to get an ID
          var songData = widget.song.toJson()..remove('id');
          songData['savedAt'] = DateTime.now();
          var result = await db.collection('songs').insertOne(songData);

          // result.id can be ObjectId or other type depending on mongo_dart version/result
          if (result.id is ObjectId) {
            songId = (result.id as ObjectId).oid;
          } else {
            songId = result.id.toString();
          }
        } else {
          songId = existingSong.id;
        }

        await DBConnector.playSongIncrementPlayCount(db, user.id, songId);
        await DBConnector.close(db);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing song: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _downloadSong() async {
    setState(() => _isDownloading = true);
    try {
      await _songService.downloadAudio(widget.song.url);

      final user = await Authorizer.getCurrentUser();
      if (user != null) {
        var db = await DBConnector.connect();
        var existingSong = await DBConnector.getSong(
          db,
          widget.song.externalId,
        );
        String songId;
        if (existingSong == null) {
          var songData = widget.song.toJson()..remove('id');
          songData['savedAt'] = DateTime.now();
          var result = await db.collection('songs').insertOne(songData);

          if (result.id is ObjectId) {
            songId = (result.id as ObjectId).oid;
          } else {
            songId = result.id.toString();
          }
        } else {
          songId = existingSong.id;
        }
        await DBConnector.downloadSong(db, user.id, songId);
        await DBConnector.close(db);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download completed!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final user = await Authorizer.getCurrentUser();
      if (user != null) {
        var db = await DBConnector.connect();
        if (_isFavorite) {
          // Find song first to get ID
          var existingSong = await DBConnector.getSong(
            db,
            widget.song.externalId,
          );
          if (existingSong != null) {
            await DBConnector.unfavoriteSong(db, user.id, existingSong.id);
          }
        } else {
          await DBConnector.faveSong(db, user.id, widget.song);
        }
        await DBConnector.close(db);
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
      }
    }
  }

  @override
  void dispose() {
    _songService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
        _playSong();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Song Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.song.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: cardColorSoft,
                  child: const Icon(Icons.music_note, color: iconsBlocksColor),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title and Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mainTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: labelsColor, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Duration, Favorite and Download
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDuration(widget.song.duration),
                  style: const TextStyle(color: labelsColor, fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isFavorite ? Colors.red : iconsBlocksColor,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    _isDownloading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.download_rounded, size: 20),
                            color: iconsBlocksColor,
                            onPressed: _downloadSong,
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
