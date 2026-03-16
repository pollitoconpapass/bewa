# 1. Create database
use musicAppDB

# 2. users collection
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "password"],
      properties: {
        name:      { bsonType: "string" },
        email:     { bsonType: "string" },
        password:  { bsonType: "string" },
        image:     { bsonType: "string" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
})
db.users.createIndex({ email: 1 }, { unique: true })

# 3. songs collection (only songs that have been saved by any user)
db.createCollection("songs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["externalId", "title", "artist", "url"],
      properties: {
        externalId: { bsonType: "string" },  # -> ID from the web crawler
        title:      { bsonType: "string" },
        artist:     { bsonType: "string" },
        artistId:   { bsonType: "string" },  # -> externalId of the artist
        image:      { bsonType: "string" },
        duration:   { bsonType: "number" },
        url:        { bsonType: "string" },
        savedAt:    { bsonType: "date" }
      }
    }
  }
})
db.songs.createIndex({ externalId: 1 }, { unique: true })
db.songs.createIndex({ artist: 1 })
db.songs.createIndex({ title: 1 })

# 4. artists collection (only artists that have been saved by any user)
db.createCollection("artists", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["externalId", "name"],
      properties: {
        externalId: { bsonType: "string" },
        name:       { bsonType: "string" },
        image:      { bsonType: "string" },
        savedAt:    { bsonType: "date" }
      }
    }
  }
})
db.artists.createIndex({ externalId: 1 }, { unique: true })
db.artists.createIndex({ name: 1 })

# 5. playlists collection
db.createCollection("playlists", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "title"],
      properties: {
        userId:    { bsonType: "objectId" },
        title:     { bsonType: "string" },
        image:     { bsonType: "string" },
        songs:     { bsonType: "array", items: { bsonType: "objectId" } },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
})
db.playlists.createIndex({ userId: 1 })

# 6. user_songs — favorites, play history, downloads (junction)
db.createCollection("user_songs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "songId"],
      properties: {
        userId:       { bsonType: "objectId" },
        songId:       { bsonType: "objectId" },
        isFavorite:   { bsonType: "bool" },
        playCount:    { bsonType: "int" },
        isDownloaded: { bsonType: "bool" },
        savedAt:      { bsonType: "date" }
      }
    }
  }
})
# Compound unique index: one record per user+song pair
db.user_songs.createIndex({ userId: 1, songId: 1 }, { unique: true })
db.user_songs.createIndex({ userId: 1, isFavorite: 1 })
db.user_songs.createIndex({ userId: 1, playCount: -1 }) # -> for "most listened"

# 7. user_artists — favorite artists (junction)
db.createCollection("user_artists", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "artistId"],
      properties: {
        userId:     { bsonType: "objectId" },
        artistId:   { bsonType: "objectId" },
        isFavorite: { bsonType: "bool" },
        savedAt:    { bsonType: "date" }
      }
    }
  }
})
db.user_artists.createIndex({ userId: 1, artistId: 1 }, { unique: true })
db.user_artists.createIndex({ userId: 1, isFavorite: 1 })


# externalId is the bridge between the web crawler world and the DB. When a user favorites a song, we check songs.externalId first — if it already exists (another user saved it before), we reuse it. If not, we insert it fresh. This avoids duplication.
# user_songs.playCount is how we power the "Most listened" module — just query user_songs sorted by playCount: -1 for a given userId.
# The { userId: 1, playCount: -1 } index on user_songs makes that leaderboard query very fast without scanning the full collection.
# Offline downloads are tracked with isDownloaded: true on user_songs. Our Flutter app can then filter locally by that flag.
