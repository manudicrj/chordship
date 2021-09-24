import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:chordship/models/artist_model.dart';
import 'package:chordship/models/chord_model.dart';
import 'package:chordship/models/song_model.dart';
import 'package:chordship/services/action_selector_service.dart';
import 'package:chordship/services/mode_selector_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:chordship/services/web_service.dart';
import 'package:chordship/widgets/action_selector_widget.dart';
import 'package:chordship/widgets/mode_selector_widget.dart';
import 'package:chordship/widgets/sheet_canvas_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditorView extends StatefulWidget {
  const EditorView({Key? key, required this.song}) : super(key: key);
  final int song;
  @override
  _EditorViewState createState() => _EditorViewState();
}

class MyTextSelection {
  int start = 0;
  int end = 0;
  int textLength = 0;
}

class _EditorViewState extends State<EditorView> {
  final WebService api = WebService();
  final GlobalKey _paintKey = GlobalKey();
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  final textController = TextEditingController();
  MyTextSelection lastSelection = MyTextSelection();
  final titleController = TextEditingController();
  final searchArtistController = TextEditingController();
  late Future<Song> song;
  late Song currentSong = Song();
  bool editing = false;
  late Future<Artist> futureArtist;
  Offset _tapPosition = Offset.zero;

  Future<Song> fetchSong() async {
    final response = await api.getSong(widget.song);
    if (editing) {
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        textController.text = data['lyrics'] as String;
        titleController.text = data['name'] as String;
        return currentSong = Song.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception("Failed to load album");
      }
    } else {
      currentSong = Song();
      textController.text = "";
      titleController.text = "";
      return currentSong;
    }
  }

  Future<String> editSong() async {
    currentSong.name = titleController.text;
    currentSong.lyrics = textController.text;
    currentSong.album = 0;
    final response = await api.editSong(currentSong);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to edit song");
    }
  }

  Future<String> uploadSong() async {
    currentSong.name = titleController.text;
    currentSong.lyrics = textController.text;
    final response = await api.postSong(currentSong);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to create song");
    }
  }

  void addChordDialog(int listenerIndex) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (ctx, anim1, anim2) {
        int selectedNote = 0;
        final TextEditingController typeController = TextEditingController();
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(20),
          buttonPadding: EdgeInsets.zero,
          content: StatefulBuilder(builder: (context, setDialogState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100,
                      childAspectRatio: 6 / 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return Listener(
                        onPointerDown: (event) {
                          setDialogState(() {
                            selectedNote = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedNote == index ? Palette.primary : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              pickOne(notes[index]),
                              style: TextStyle(color: selectedNote == index ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10, right: 10),
                        fillColor: const Color(0x10000000),
                        focusColor: const Color(0x11000000),
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Tipo ed estensione',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Color(0x00000000)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Color(0x00000000)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          currentSong.chords ??= [];
                          currentSong.chords!.add(Chord(
                            char: listenerIndex,
                            note: selectedNote,
                            text: typeController.text,
                          ));
                        });
                        Navigator.of(context).pop();
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text("Aggiungi")),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1 * anim1.value, sigmaY: 1 * anim1.value),
        child: FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  String pickOne(String s) {
    return s.split("|")[0];
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.removeListener(() {});
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    editing = widget.song != 0;
    super.initState();
    song = fetchSong();
    textController.addListener(() {
      final ls = lastSelection;
      final s = textController.selection;
      final RegExp newLineRegex = RegExp(r"(\r\n|\r|\n)");
      final String filteredText = textController.text.replaceAll(newLineRegex, '');

      if (lastSelection.textLength != filteredText.length) {
        final List<Chord> chords = currentSong.chords!;
        if (ls.start == ls.end && s.start == s.end && s.start != -1) {
          final int count = newLineRegex.allMatches(textController.text.substring(0, s.start)).length;
          for (final c in chords.where((c) => c.char >= min(s.start, ls.start) - count)) {
            c.char += s.start - ls.start;
          }
        }
      }

      lastSelection.start = s.start;
      lastSelection.end = s.end;
      lastSelection.textLength = filteredText.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const ActionSelectorWidget(),
      body: SafeArea(
        child: GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scaleFactor = _baseScaleFactor * details.scale;
            });
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Palette.primary,
                      ),
                    ),
                    const ModeSelectorWidget(),
                    IconButton(
                      onPressed: () {
                        switch (modeSelectorService.mode) {
                          case "Testo":
                            modeSelectorService.mode = "Accordi";
                            break;
                          case "Accordi":
                            if (editing) {
                              editSong().then((value) {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    title: Text("Fatto!"),
                                    content: Text("Cantico modificato con successo"),
                                  ),
                                ).then((value) => Navigator.of(context).pop());
                              }).catchError((error) {
                                // ignore: avoid_print
                                print(error.toString());
                              });
                            } else {
                              uploadSong().then((value) {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    title: Text("Fatto!"),
                                    content: Text("Cantico caricato con successo"),
                                  ),
                                ).then((value) => Navigator.of(context).pop());
                              }).catchError((error) {
                                // ignore: avoid_print
                                print(error.toString());
                              });
                            }
                            break;
                        }
                      },
                      icon: const Icon(Icons.done),
                      color: Palette.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: StreamBuilder<String>(
                        stream: modeSelectorService.stream$,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) modeSelectorService.mode = "Testo";
                          final String selectedMode = snapshot.data ?? "Testo";
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: titleController,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.sentences,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 30,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Titolo",
                                  hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ),
                                enabled: modeSelectorService.mode == "Testo",
                              ),
                              if (selectedMode == "Testo")
                                TextFormField(
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: "Testo",
                                    hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: null,
                                  controller: textController,
                                  //cursorColor: Color(0xffd7123f),
                                  style: TextStyle(
                                    fontSize: _scaleFactor * 20,
                                    decoration: TextDecoration.none,
                                    decorationThickness: 0,
                                  ),
                                  onChanged: (text) {},
                                )
                              else
                                GestureDetector(
                                  onTap: () {
                                    for (int i = 0; i < lettersRect.length; i++) {
                                      if (lettersRect[i].contains(_tapPosition)) {
                                        if (actionSelectorService.action == "Aggiungi") {
                                          addChordDialog(i);
                                        } else {
                                          setState(() {
                                            currentSong.chords!.removeWhere((c) => c.char == i);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  onTapDown: (TapDownDetails details) {
                                    final RenderBox referenceBox = _paintKey.currentContext!.findRenderObject()! as RenderBox;
                                    final Offset offset = referenceBox.globalToLocal(details.globalPosition);
                                    _tapPosition = offset;
                                  },
                                  child: CustomPaint(
                                    key: _paintKey,
                                    size: const Size(double.maxFinite, double.maxFinite),
                                    painter: SheetCanvasWidget(
                                      text: textController.text,
                                      fontSize: _scaleFactor,
                                      chords: currentSong.chords!,
                                      editor: true,
                                    ),
                                  ),
                                ),

                              /*modeSelectorService.mode == "Testo"
                                  ? TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Seleziona artista"),
                                            content: Column(
                                              children: [
                                                TextField(
                                                  controller: searchArtistController,
                                                  textInputAction: TextInputAction.search,
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                    prefixIcon: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.search,
                                                        color: Color(0x66000000),
                                                      ),
                                                    ),
                                                    suffixIcon: searchArtistController.text.length > 0
                                                        ? IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                searchArtistController.text = "";
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.clear_rounded,
                                                              color: Color(0x66000000),
                                                            ),
                                                          )
                                                        : null,
                                                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                                                    fillColor: Color(0x10000000),
                                                    focusColor: Color(0x11000000),
                                                    filled: true,
                                                    border: InputBorder.none,
                                                    hintText: 'Cerca artista..',
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                      borderSide: BorderSide(color: Color(0x00000000)),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                      borderSide: BorderSide(color: Color(0x00000000)),
                                                    ),
                                                  ),
                                                  onChanged: (text) {
                                                    setState(() {});
                                                  },
                                                ),

                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.black12,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                        primary: Colors.black54,
                                        padding: const EdgeInsets.only(left: 20, right: 20),
                                      ),
                                      child: Text("Seleziona artista"),
                                    )
                                  : Container(),*/
                            ],
                          );
                        }),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
