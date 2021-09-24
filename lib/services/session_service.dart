import 'dart:async';
import 'dart:convert';

import 'package:chordship/main.dart';
import 'package:chordship/services/web_service.dart';
import 'package:chordship/views/song_view.dart';
import 'package:flutter/material.dart';

class SessionService {
  Timer? timer;
  WebService api = WebService();
  int currId = -1;
  bool paused = false;
  void pause() {
    paused = true;
  }

  void resume() {
    paused = false;
  }

  SessionService() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      if (!paused) {
        final response = await api.getSessionSong("0001");
        if (response.statusCode == 200) {
          final res = jsonDecode(response.body);
          if (currId != res['song'] as int) {
            currId = res['song'] as int;

            Future.delayed(Duration.zero).then((_) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (builder) => SongView(song: res['song'] as int),
                ),
              );
            });
          }
        }
      }
    });
  }
}
