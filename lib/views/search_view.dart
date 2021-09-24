import 'dart:async';
import 'dart:convert';

import 'package:chordship/models/song_model.dart';
import 'package:chordship/services/db_service.dart';
import 'package:chordship/services/mode_selector_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:chordship/services/session_service.dart';
import 'package:chordship/services/web_service.dart';
import 'package:chordship/views/editor_view.dart';
import 'package:chordship/views/song_view.dart';
import 'package:chordship/widgets/navbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);
  @override
  _SearchViewState createState() => _SearchViewState();
}

// ignore: constant_identifier_names
enum SongOption { Preferiti, Scarica, Modifica }

class _SearchViewState extends State<SearchView> {
  final WebService api = WebService();
  late Future<List<SongPreview>> futureSongs;
  final searchController = TextEditingController();
  int currentPage = 1;

  Future<List<SongPreview>> fetchSongs(String text) async {
    final response = await api.getSongsList(text);
    print(response.body);
    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body) as List;
      //print(jsonResponse);
      return jsonResponse.map((song) => SongPreview.fromJson(song as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Failed to load album");
    }
  }

  @override
  void initState() {
    super.initState();
    futureSongs = fetchSongs('');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: "Cerca cantico..",
                prefixInsets: const EdgeInsets.all(10),
                suffixInsets: const EdgeInsets.all(10),
                style: const TextStyle(
                  letterSpacing: 0.1,
                ),
                onChanged: (String text) {
                  setState(() {
                    futureSongs = fetchSongs(text);
                  });
                },
                controller: searchController,
              ),
            ),
            /*Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Color(0x66000000),
                      ),
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                futureSongs = fetchSongs('');
                              });
                            },
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Color(0x66000000),
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    fillColor: const Color(0x10000000),
                    focusColor: const Color(0x11000000),
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Cerca cantico..',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                  ),
                  onChanged: (String text) {
                    setState(() {
                      futureSongs = fetchSongs(text);
                    });
                  },
                ),
              ),*/
            FutureBuilder<List<SongPreview>>(
                future: futureSongs,
                builder: (BuildContext context, AsyncSnapshot<List<SongPreview>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        for (SongPreview song in snapshot.data!) SongPreviewWidget(song: song),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                            borderRadius: BorderRadius.circular(30.0),
                            child: const Text(
                              "Nuovo cantico",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              modeSelectorService.mode = "Testo";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditorView(song: 0),
                                ),
                              );
                            },
                          ),
                        ),
                        /*Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Palette.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              onPressed: () {
                                modeSelectorService.mode = "Testo";
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditorView(song: 0),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Text(
                                  "Nuovo cantico",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),*/
                      ],
                    );
                  } else if (snapshot.hasError) {
                    //setState(() {
                    futureSongs = getLocalSongs();

                    //return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }

  Future<List<SongPreview>> getLocalSongs() async {
    final Database db = await openMyDB();
    final SongProvider sp = SongProvider(db);
    final List<SongPreview> songs = await sp.getAll();
    await db.close();
    setState(() {});
    return songs;
  }
}

class SongPreviewWidget extends StatelessWidget {
  const SongPreviewWidget({Key? key, required this.song}) : super(key: key);
  final SongPreview song;

  Future<void> downloadSong(int id) async {
    final WebService _webService = WebService();
    final Database db = await openMyDB();
    final response = await _webService.getSong(id);
    final Song song = Song.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    final SongProvider sp = SongProvider(db);
    if (await sp.exists(song)) {
      sp.update(song);
    } else {
      sp.insert(song);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3),
      child: TextButton(
        onPressed: () {
          modeSelectorService.mode = "Testo";
          final SessionService session = GetIt.I<SessionService>();
          session.pause();
          session.currId = song.id;
          final WebService _webService = WebService();
          _webService.postSessionSong("0001", song.id).then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongView(song: song.id),
              ),
            );
            session.resume();
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: const Color(0x55000000),
          primary: const Color(0xff050505),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 30, right: 10, top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    song.getArtistString(),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.zero,
                child: PopupMenuButton<SongOption>(
                  iconSize: 24,
                  elevation: 3,
                  onSelected: (value) {
                    switch (value) {
                      case SongOption.Modifica:
                        modeSelectorService.mode = "Testo";
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (builder) => EditorView(song: song.id),
                          ),
                        );
                        break;
                      case SongOption.Scarica:
                        downloadSong(song.id);
                        break;
                      default:
                        break;
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<SongOption>>[
                    const PopupMenuItem(
                      value: SongOption.Preferiti,
                      child: Text("Preferiti"),
                    ),
                    const PopupMenuItem(
                      value: SongOption.Scarica,
                      child: Text("Scarica"),
                    ),
                    const PopupMenuItem(
                      value: SongOption.Modifica,
                      child: Text("Modifica"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
