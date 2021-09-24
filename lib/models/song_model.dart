import 'package:chordship/models/chord_model.dart';
import 'package:sqflite/sqflite.dart';

import 'artist_model.dart';

class Song {
  int id;
  String name;
  String lyrics;
  int? artist;
  int? album;
  int key;
  List<Chord>? chords = [];
  Song({
    this.id = 0,
    this.name = "",
    this.lyrics = "",
    this.artist = 0,
    this.album,
    this.chords = const [],
    this.key = 0,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      name: json['name'] as String,
      lyrics: json['lyrics'] as String,
      artist: json['artist'] as int?,
      album: json['album'] as int?,
      key: (json['key'] ?? 0) as int,
      chords: json['chords'].map<Chord>((c) => Chord.fromJson(c as Map<String, dynamic>)).toList() as List<Chord>,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lyrics': lyrics,
      'artist': artist,
      'album': album,
      'chords': chords,
      'key': key,
    };
  }
}

class SongPreview {
  int id;
  String name;
  List<Artist>? artist;
  SongPreview({
    this.id = 0,
    this.name = "",
    this.artist,
  });
  factory SongPreview.fromJson(Map<String, dynamic> json) {
    return SongPreview(
      id: json['id'] as int,
      name: json['name'] as String,
      artist: json['artist'] != null ? json['artist'].map<Artist>((a) => Artist.fromJson(a as Map<String, dynamic>)).toList() as List<Artist> : [],
    );
  }

  String getArtistString() {
    final buffer = StringBuffer();
    if (artist != null) {
      for (final a in artist!) {
        buffer.write("${a.name}, ");
      }
    }
    return buffer.isNotEmpty ? buffer.toString().substring(0, buffer.length - 2) : "";
  }
}

class SongProvider {
  Database db;
  SongProvider(this.db);
  Future<int> insert(Song song) async {
    return db.insert("song", {
      "id": song.id,
      "name": song.name,
      "lyrics": song.lyrics,
    });
  }

  Future<bool> exists(Song song) async {
    final List<Map<String, Object?>> queryResult = await db.query("song", where: "id = ?", whereArgs: [song.id]);
    return queryResult.isNotEmpty;
  }

  Future<List<SongPreview>> getAll() async {
    final List<Map<String, Object?>> res = await db.rawQuery("SELECT * FROM song");
    final List<SongPreview> songs = res.map((e) => SongPreview.fromJson(e)).toList();
    return songs;
  }

  Future<int> update(Song song) async {
    return db.update(
      "song",
      {
        "id": song.id,
        "name": song.name,
        "lyrics": song.lyrics,
      },
      where: "id = ?",
      whereArgs: [song.id],
    );
  }
}
