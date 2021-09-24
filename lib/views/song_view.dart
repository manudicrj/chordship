import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:chordship/models/song_model.dart';
import 'package:chordship/services/canvas_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:chordship/services/web_service.dart';
import 'package:chordship/widgets/key_input_widget.dart';
import 'package:chordship/widgets/sheet_canvas_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongView extends StatefulWidget {
  const SongView({Key? key, this.song = 0}) : super(key: key);
  final int song;
  @override
  _SongViewState createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  final WebService api = WebService();
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  Offset _tapPosition = Offset.zero;
  List<String> notes = ["C", "C#|Db", "D", "D#|Eb", "E", "F", "F#|Gb", "G", "G#|Ab", "A", "A#|Bb", "B"];
  late Future<Song> song;
  late Song currentSong = Song();

  Future<Song> fetchSong() async {
    final response = await api.getSong(widget.song);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return currentSong = Song.fromJson(data);
    } else {
      throw Exception("Failed to load song");
    }
  }

  String pickOne(String s) {
    return s.split("|")[0];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initCanvasSettings() async {
    final prefs = await SharedPreferences.getInstance();

    columns = prefs.getInt("columns") ?? columns;
    lettersNotation = prefs.getBool("lettersNotation") ?? lettersNotation;
    showChords = prefs.getBool("showChords") ?? showChords;
  }

  @override
  void initState() {
    initCanvasSettings();
    super.initState();
    song = fetchSong();
    transpose = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Text("${currentPage + 1}/${maxPages + 1}"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scaleFactor = _baseScaleFactor * details.scale;
              if (_scaleFactor < 0.5) _scaleFactor = 0.5;
              if (_scaleFactor > 3.0) _scaleFactor = 3.0;
              canvasService.update();
            });
          },
          child: Column(
            children: <Widget>[
              const ViewBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: FutureBuilder(
                      future: fetchSong(),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  currentSong.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GestureDetector(
                                  onVerticalDragUpdate: (details) {
                                    const int sensitivity = 15;
                                    if (details.delta.dy > sensitivity) {
                                      // Down Swipe
                                    } else if (details.delta.dy < -sensitivity) {
                                      openSettings(context);
                                    }
                                  },
                                  onTap: () {
                                    setState(() {
                                      currentPage += _tapPosition.dx > 150 ? 1 : -1;
                                      if (currentPage > maxPages) currentPage = maxPages;
                                      if (currentPage < 0) currentPage = 0;
                                      canvasService.update();
                                    });
                                  },
                                  onTapDown: (details) {
                                    _tapPosition = details.localPosition;
                                  },
                                  child: StreamBuilder<int>(
                                    stream: canvasService.stream$,
                                    builder: (context, snapshot) {
                                      return CustomPaint(
                                        size: const Size(double.maxFinite, 600),
                                        painter: SheetCanvasWidget(
                                          text: currentSong.lyrics,
                                          fontSize: _scaleFactor,
                                          chords: currentSong.chords!,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          //return const CupertinoActivityIndicator();
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openSettings(BuildContext context) {
  showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setModalState) {
        return Column(
          children: [
            Container(
              width: 150,
              height: 8,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 8),
              child: Text(
                "Colonne",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.none,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        columns = 1;
                        canvasService.update();
                        setModalState(() {});

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt("columns", columns);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 7),
                        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: columns == 1 ? Palette.primary : Colors.transparent,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Image.asset(
                          "assets/icons/justify.png",
                          color: columns == 1 ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        columns = 2;
                        canvasService.update();
                        setModalState(() {});

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt("columns", columns);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 7),
                        margin: const EdgeInsets.all(3),
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: columns == 2 ? Palette.primary : Colors.transparent,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Image.asset(
                          "assets/icons/two.png",
                          color: columns == 2 ? Colors.white : Colors.black54,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 8),
              child: Text(
                "Tonalità", // Chiave o Scala
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const KeyInput(),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 8),
              child: Text(
                "Notazione", // Chiave o Scala
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.none,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        lettersNotation = false;
                        canvasService.update();
                        setModalState(() {});

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("lettersNotation", lettersNotation);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 7),
                        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        width: 120,
                        decoration: BoxDecoration(
                          color: !lettersNotation ? Palette.primary : Colors.transparent,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Center(
                          child: Text(
                            "Do Re Mi",
                            style: TextStyle(
                              color: !lettersNotation ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        lettersNotation = true;
                        canvasService.update();
                        setModalState(() {});

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("lettersNotation", lettersNotation);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 7),
                        margin: const EdgeInsets.all(3),
                        width: 120,
                        decoration: BoxDecoration(
                          color: lettersNotation ? Palette.primary : Colors.transparent,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Center(
                          child: Text(
                            "C D E",
                            style: TextStyle(
                              color: lettersNotation ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      "Mostra accordi",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    activeColor: Palette.primary,
                    value: showChords,
                    onChanged: (bool value) async {
                      showChords = value;
                      canvasService.update();
                      setModalState(() {});
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool("showChords", showChords);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      });
    },
  );
}

class ViewBar extends StatelessWidget {
  const ViewBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.01),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Palette.primary),
          ),
          TextButton(
            onPressed: () {
              openSettings(context);
            },
            child: const Text("Impostazioni"),
          )
        ],
      ),
    );
  }
}
