class Song {
  final String id;
  final String externalId;
  final String title;
  final String artist;
  final String artistId;
  final String image;
  final double duration;
  final String url;
  final DateTime savedAt;

  Song({
    required this.id,
    required this.externalId,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.image,
    required this.duration,
    required this.url,
    required this.savedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      externalId: json['externalId'],
      title: json['title'],
      artist: json['artist'],
      artistId: json['artistId'],
      image: json['image'],
      duration: (json['duration'] as num).toDouble(),
      url: json['url'],
      savedAt: json['savedAt'] is DateTime
          ? json['savedAt']
          : DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'image': image,
      'duration': duration,
      'url': url,
      'savedAt': savedAt,
    };
  }
}

class Artist {
  final String id;
  final String externalId;
  final String name;
  final String image;
  final DateTime savedAt;

  Artist({
    required this.id,
    required this.externalId,
    required this.name,
    required this.image,
    required this.savedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      externalId: json['externalId'],
      name: json['name'],
      image: json['image'],
      savedAt: json['savedAt'] is DateTime
          ? json['savedAt']
          : DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'name': name,
      'image': image,
      'savedAt': savedAt,
    };
  }
}

class Playlist {
  final String id;
  final String userId;
  final String title;
  final String image;
  final List<String> songIds; // store IDs, not full Song objects
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.userId,
    required this.title,
    required this.songIds,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title'],
      image: json['image'] ?? '',
      songIds:
          (json['songs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt']
          : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'image': image,
      'songs': songIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class User {
  final String id;
  final String name;
  final String image;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      name: json['name'],
      image: json['image'],
      email: json['email'],
      password: json['password'],
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt']
          : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class UserSong {
  final String id;
  final String userId;
  final String songId;
  final bool isFavorite;
  final int playCount;
  final bool isDownloaded;
  final DateTime savedAt;

  UserSong({
    required this.id,
    required this.userId,
    required this.songId,
    required this.isFavorite,
    required this.playCount,
    required this.isDownloaded,
    required this.savedAt,
  });

  factory UserSong.fromJson(Map<String, dynamic> json) {
    return UserSong(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      songId: json['songId']?.toString() ?? '',
      isFavorite: json['isFavorite'] ?? false,
      playCount: json['playCount'] ?? 0,
      isDownloaded: json['isDownloaded'] ?? false,
      savedAt: json['savedAt'] is DateTime
          ? json['savedAt']
          : DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'songId': songId,
      'isFavorite': isFavorite,
      'playCount': playCount,
      'isDownloaded': isDownloaded,
      'savedAt': savedAt,
    };
  }
}

class UserArtist {
  final String id;
  final String userId;
  final String artistId;
  final bool isFavorite;
  final DateTime savedAt;

  UserArtist({
    required this.id,
    required this.userId,
    required this.artistId,
    required this.isFavorite,
    required this.savedAt,
  });

  factory UserArtist.fromJson(Map<String, dynamic> json) {
    return UserArtist(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      artistId: json['artistId']?.toString() ?? '',
      isFavorite: json['isFavorite'] ?? false,
      savedAt: json['savedAt'] is DateTime
          ? json['savedAt']
          : DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'artistId': artistId,
      'isFavorite': isFavorite,
      'savedAt': savedAt,
    };
  }
}

// === EXTERNAL SERVICES ===
class SongResult {
  final String id;
  final String title;
  final String url;
  final String artist;
  final String artistId;
  final String thumbnail;
  final double? duration;

  SongResult({
    required this.id,
    required this.title,
    required this.url,
    required this.artist,
    required this.artistId,
    required this.thumbnail,
    this.duration,
  });

  factory SongResult.fromJson(Map<String, dynamic> json) {
    // yt-dlp returns 'thumbnails' as a list or 'thumbnail' as a string
    String thumb = '';
    if (json['thumbnails'] != null && (json['thumbnails'] as List).isNotEmpty) {
      thumb = json['thumbnails'].last['url'] ?? '';
    } else {
      thumb = json['thumbnail'] ?? '';
    }

    return SongResult(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['webpage_url'] ?? '',
      artist: json['uploader'] ?? json['channel'] ?? '',
      artistId: json['uploader_id'] ?? json['channel_id'] ?? '',
      thumbnail: thumb,
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'SongResult(title: $title, artist: $artist, url: $url, duration: $duration, thumbnail: $thumbnail)\n\n';
  }
}
