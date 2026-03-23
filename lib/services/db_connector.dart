import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/info_models.dart';

class DBConnector {
  // Connect to the database
  static Future<Db> connect() async {
    var db = Db(dotenv.env['MONGO_URL']!);
    await db.open();
    return db;
  }

  // Close the database
  static Future<void> close(Db db) async {
    await db.close();
  }

  /// ==== GET METHODS IN DB ====

  // Get user info
  static Future<User?> getUser(Db db, String email) async {
    var user = await db.collection('users').findOne({'email': email});
    if (user == null) return null;
    return User.fromJson(user);
  }

  // Get Song info by externalId (bridge with web crawler)
  static Future<Song?> getSong(Db db, String externalId) async {
    var song = await db.collection('songs').findOne({'externalId': externalId});
    if (song == null) return null;
    return Song.fromJson(song);
  }

  // Get artist info by externalId
  static Future<Artist?> getArtist(Db db, String externalId) async {
    var artist = await db.collection('artists').findOne({
      'externalId': externalId,
    });
    if (artist == null) return null;
    return Artist.fromJson(artist);
  }

  // Get playlist and its songs
  static Future<List<Song>> getPlaylistSongs(Db db, String playlistId) async {
    var playlist = await db
        .collection('playlists')
        .findOne(where.id(ObjectId.fromHexString(playlistId)));

    if (playlist == null || playlist['songs'] == null) return [];

    List<ObjectId> songObjectIds = List<ObjectId>.from(playlist['songs']);

    if (songObjectIds.isEmpty) return [];

    var songsCursor = db
        .collection('songs')
        .find(where.oneFrom('_id', songObjectIds));
    var songsList = await songsCursor.toList();

    return songsList.map((song) => Song.fromJson(song)).toList();
  }

  // Get a single playlist's metadata
  static Future<Playlist?> getPlaylist(Db db, String playlistId) async {
    var playlist = await db
        .collection('playlists')
        .findOne(where.id(ObjectId.fromHexString(playlistId)));
    if (playlist == null) return null;
    return Playlist.fromJson(playlist);
  }

  // Get the top 30 songs played (they will appear in the most played playlist)
  Future<List<Song>> getTop30Songs(Db db, String userId) async {
    var userSongIds = await db
        .collection('user_songs')
        .find(
          where
              .eq('userId', ObjectId.fromHexString(userId))
              .sortBy('playCount', descending: true)
              .limit(30)
              .fields(['songId']),
        )
        .map((doc) => doc['songId'] as ObjectId)
        .toList();

    if (userSongIds.isEmpty) return [];

    var songsCursor = db
        .collection('songs')
        .find(where.oneFrom('_id', userSongIds));
    var songsList = await songsCursor.toList();
    return songsList.map((song) => Song.fromJson(song)).toList();
  }

  // Get the top 50 songs played of the year (something like Spotify Wrapped)
  Future<List<Song>> getTop50Songs(
    Db db,
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    var userSongIds = await db
        .collection('user_songs')
        .find(
          where
              .eq('userId', ObjectId.fromHexString(userId))
              .gte('savedAt', startDate)
              .lt('savedAt', endDate)
              .sortBy('playCount', descending: true)
              .limit(50)
              .fields(['songId']),
        )
        .map((doc) => doc['songId'] as ObjectId)
        .toList();

    if (userSongIds.isEmpty) return [];

    var songsCursor = db
        .collection('songs')
        .find(where.oneFrom('_id', userSongIds));
    var songsList = await songsCursor.toList();
    return songsList.map((song) => Song.fromJson(song)).toList();
  }

  /// ==== INSERT METHODS IN DB ====

  // Insert new user
  static Future<void> insertUser(Db db, User user) async {
    await db.collection('users').insertOne(user.toJson()..remove('id'));
  }

  // Fave a song
  static Future<void> faveSong(Db db, String userId, Song song) async {
    var existingSong = await db.collection('songs').findOne({
      'externalId': song.externalId,
    });

    ObjectId songId;
    if (existingSong != null) {
      songId = existingSong['_id'] as ObjectId;
    } else {
      var songData = song.toJson()..remove('id');
      songData['savedAt'] = DateTime.now();
      var result = await db.collection('songs').insertOne(songData);
      songId = result.document!['_id'] as ObjectId;
    }

    await db.collection('user_songs').insertOne({
      'userId': ObjectId.fromHexString(userId),
      'songId': songId,
      'isFavorite': true,
      'playCount': 0,
      'isDownloaded': false,
      'savedAt': DateTime.now(),
    });
  }

  // Fave an artist
  static Future<void> faveArtist(Db db, String userId, Artist artist) async {
    var existingArtist = await db.collection('artists').findOne({
      'externalId': artist.externalId,
    });

    ObjectId artistId;
    if (existingArtist != null) {
      artistId = existingArtist['_id'] as ObjectId;
    } else {
      var artistData = artist.toJson()..remove('id');
      artistData['savedAt'] = DateTime.now();
      var result = await db.collection('artists').insertOne(artistData);
      artistId = result.document!['_id'] as ObjectId;
    }

    await db.collection('user_artists').insertOne({
      'userId': ObjectId.fromHexString(userId),
      'artistId': artistId,
      'isFavorite': true,
      'savedAt': DateTime.now(),
    });
  }

  // Create a playlist
  static Future<void> createPlaylist(Db db, Playlist playlist) async {
    var data = playlist.toJson()..remove('id');
    // Ensure IDs are ObjectIds
    data['userId'] = ObjectId.fromHexString(playlist.userId);
    data['songs'] = playlist.songIds
        .map((id) => ObjectId.fromHexString(id))
        .toList();

    await db.collection('playlists').insertOne(data);
  }

  // Add a song to a playlist
  static Future<void> addSongToPlaylist(
    Db db,
    String playlistId,
    String songId,
  ) async {
    await db
        .collection('playlists')
        .updateOne(
          where.id(ObjectId.fromHexString(playlistId)),
          modify.push('songs', ObjectId.fromHexString(songId)),
        );
  }

  /// ==== UPDATE METHODS IN DB ====
  // Update user info
  static Future<void> updateUser(Db db, User user) async {
    await db
        .collection('users')
        .updateOne(where.id(ObjectId.fromHexString(user.id)), user.toJson());
  }

  // Update a playlist (name)
  static Future<void> updatePlaylist(Db db, Playlist playlist) async {
    await db
        .collection('playlists')
        .updateOne(
          where.id(ObjectId.fromHexString(playlist.id)),
          playlist.toJson(),
        );
  }

  // Play a song
  Future<void> playSongIncrementPlayCount(
    Db db,
    String userId,
    String songId,
  ) async {
    await db
        .collection('user_songs')
        .updateOne(
          {
            'userId': ObjectId.fromHexString(userId),
            'songId': ObjectId.fromHexString(songId),
          },
          modify
              .inc('playCount', 1)
              .setOnInsert('isFavorite', false)
              .setOnInsert('isDownloaded', false)
              .setOnInsert('playCount', 0)
              .setOnInsert('savedAt', DateTime.now()),
          upsert: true,
        );
  }

  // Download a song
  Future<void> downloadSong(Db db, String userId, String songId) async {
    await db
        .collection('user_songs')
        .updateOne(
          {
            'userId': ObjectId.fromHexString(userId),
            'songId': ObjectId.fromHexString(songId),
          },
          modify
              .setOnInsert('isDownloaded', true)
              .setOnInsert('isFavorite', false)
              .setOnInsert('playCount', 0)
              .setOnInsert('savedAt', DateTime.now()),
          upsert: true,
        );
  }

  /// ==== DELETE METHODS IN DB ====

  // Delete a user
  static Future<void> deleteUser(Db db, String userId) async {
    await db
        .collection('users')
        .deleteOne(where.id(ObjectId.fromHexString(userId)));
  }

  // Delete a playlist
  static Future<void> deletePlaylist(Db db, String playlistId) async {
    await db
        .collection('playlists')
        .deleteOne(where.id(ObjectId.fromHexString(playlistId)));
  }

  // Delete a song
  static Future<void> deleteSong(Db db, String songId) async {
    await db
        .collection('songs')
        .deleteOne(where.id(ObjectId.fromHexString(songId)));
  }

  // Delete an artist
  static Future<void> deleteArtist(Db db, String artistId) async {
    await db
        .collection('artists')
        .deleteOne(where.id(ObjectId.fromHexString(artistId)));
  }

  // Delete a song from faves
  static Future<void> unfavoriteSong(
    Db db,
    String userId,
    String songId,
  ) async {
    await db.collection('user_songs').deleteOne({
      'userId': ObjectId.fromHexString(userId),
      'songId': ObjectId.fromHexString(songId),
    });
  }

  // Delete a song from a playlist
  static Future<void> removeSongFromPlaylist(
    Db db,
    String playlistId,
    String songId,
  ) async {
    await db
        .collection('playlists')
        .updateOne(
          where.id(ObjectId.fromHexString(playlistId)),
          modify.pull('songs', ObjectId.fromHexString(songId)),
        );
  }

  // Delete an artist from faves
  static Future<void> unfavoriteArtist(
    Db db,
    String userId,
    String artistId,
  ) async {
    await db.collection('user_artists').deleteOne({
      'userId': ObjectId.fromHexString(userId),
      'artistId': ObjectId.fromHexString(artistId),
    });
  }
}
