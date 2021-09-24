import 'dart:convert';

import 'package:chordship/models/song_model.dart';
import 'package:http/http.dart' as http;

class WebService {
  String url = "http://manudicri.altervista.org/chordship/api.php";

  Future<http.Response> getSong(int id) {
    return get("/songs?id=$id");
  }

  Future<http.Response> getSongsList(String query) {
    return get("/songs/search?query=$query");
  }

  Future<http.Response> editSong(Song song) {
    return post("/songs/edit", body: jsonEncode(song));
  }

  Future<http.Response> postSong(Song song) {
    return post("/songs/upload", body: jsonEncode(song));
  }

  Future<http.Response> getSessionSong(String session) {
    return get("/session/song/get?session_id=$session");
  }

  Future<http.Response> postSessionSong(String session, int song) {
    return get("/session/song/post?session_id=$session&song_id=$song");
  }

  Future<http.Response> logIn(String email, String password) {
    return post("/login", body: jsonEncode({"email": email, "password": password}));
  }

  Future<http.Response> post(String url, {Object? body}) {
    return http.post(
      Uri.parse(this.url + url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) {
    return http.get(Uri.parse(this.url + url), headers: headers);
  }
}
