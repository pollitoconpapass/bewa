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
    var playlist = await db.collection('playlists').findOne(
      where.id(ObjectId.fromHexString(playlistId)),
    );
    
    if (playlist == null || playlist['songs'] == null) return [];
    
    List<ObjectId> songObjectIds = List<ObjectId>.from(playlist['songs']);
    
    if (songObjectIds.isEmpty) return [];

    var songsCursor = db.collection('songs').find(where.oneFrom('_id', songObjectIds));
    var songsList = await songsCursor.toList();
    
    return songsList.map((song) => Song.fromJson(song)).toList();
  }

  // Get a single playlist's metadata
  static Future<Playlist?> getPlaylist(Db db, String playlistId) async {
    var playlist = await db.collection('playlists').findOne(
      where.id(ObjectId.fromHexString(playlistId)),
    );
    if (playlist == null) return null;
    return Playlist.fromJson(playlist);
  }

  /// ==== INSERT METHODS IN DB ====
  
  // Insert new user
  static Future<void> insertUser(Db db, User user) async {
    await db.collection('users').insertOne(user.toJson()..remove('id'));
  }

  // Fave a song (creates entry in user_songs junction)
  static Future<void> favoriteSong(Db db, String userId, String songId) async {
    await db.collection('user_songs').insertOne({
      'userId': ObjectId.fromHexString(userId),
      'songId': ObjectId.fromHexString(songId),
      'isFavorite': true,
      'playCount': 0,
      'isDownloaded': false,
      'savedAt': DateTime.now(),
    });
  }

  // Fave an artist (creates entry in user_artists junction)
  static Future<void> favoriteArtist(
    Db db,
    String userId,
    String artistId,
  ) async {
    await db.collection('user_artists').insertOne({
      'userId': ObjectId.fromHexString(userId),
      'artistId': ObjectId.fromHexString(artistId),
      'isFavorite': true,
      'savedAt': DateTime.now(),
    });
  }

  // Create a playlist
  static Future<void> createPlaylist(Db db, Playlist playlist) async {
    var data = playlist.toJson()..remove('id');
    // Ensure IDs are ObjectIds
    data['userId'] = ObjectId.fromHexString(playlist.userId);
    data['songs'] = playlist.songIds.map((id) => ObjectId.fromHexString(id)).toList();
    
    await db.collection('playlists').insertOne(data);
  }

  // Add a song to a playlist
  static Future<void> addSongToPlaylist(
    Db db,
    String playlistId,
    String songId,
  ) async {
    await db.collection('playlists').updateOne(
      where.id(ObjectId.fromHexString(playlistId)),
      modify.push('songs', ObjectId.fromHexString(songId)),
    );
  }

  /// ==== DELETE METHODS IN DB ====
  
  // Delete a user
  static Future<void> deleteUser(Db db, String userId) async {
    await db.collection('users').deleteOne(where.id(ObjectId.fromHexString(userId)));
  }

  // Delete a playlist
  static Future<void> deletePlaylist(Db db, String playlistId) async {
    await db.collection('playlists').deleteOne(where.id(ObjectId.fromHexString(playlistId)));
  }

  // Delete a song
  static Future<void> deleteSong(Db db, String songId) async {
    await db.collection('songs').deleteOne(where.id(ObjectId.fromHexString(songId)));
  }

  // Delete an artist
  static Future<void> deleteArtist(Db db, String artistId) async {
    await db.collection('artists').deleteOne(where.id(ObjectId.fromHexString(artistId)));
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
