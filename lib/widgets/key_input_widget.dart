import 'package:chordship/models/chord_model.dart';
import 'package:chordship/services/canvas_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:chordship/widgets/sheet_canvas_widget.dart';
import 'package:flutter/material.dart';

const allNotes = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"];

class Scale {
  Scale({
    this.name = "",
    this.intervals = const [],
  });
  String name;
  List<int> intervals;
}

List<Scale> scales = [
  Scale(name: "major", intervals: [2, 4, 5, 7, 9, 11]),
  Scale(name: "minor", intervals: [2, 3, 5, 7, 8, 11]),
];

class ChordDef {
  ChordDef({
    this.intervals = const [],
    this.regexp,
  });
  List<int> intervals = [];
  RegExp? regexp;
  RegExp get reg {
    return regexp!;
  }
}

Map<String, ChordDef> chordsDef = {
  "major": ChordDef(
    intervals: [4, 7],
    regexp: RegExp(r"^[A-G]$|[A-G](?=[#b])"),
  ),
  "minor": ChordDef(
    intervals: [3, 7],
    regexp: RegExp("^[A-G][#b]?[m]"),
  ),
  "dom7": ChordDef(
    intervals: [4, 7, 10],
    regexp: RegExp("^[A-G][#b]?[7]"),
  ),
};
List<String> notesArray = [];
int convertIndex(int index) {
  return index % 12;
}

void getNotesFromChords(String chordString) {
  int noteIndex;
  ChordDef? chordType;

  for (final ChordDef chord in chordsDef.values) {
    if (chord.reg.hasMatch(chordString)) {
      chordType = chord;
      break;
    }
  }
  final Iterable<RegExpMatch> matches = RegExp("^[A-G][#b]?").allMatches(chordString);
  noteIndex = allNotes.indexOf(matches.elementAt(0).group(0)!);
  addNotesFromChord(notesArray, noteIndex, chordType!);
}

void addNotesFromChord(List<String> arr, int noteIndex, ChordDef chordType) {
  if (!notesArray.contains(allNotes[convertIndex(noteIndex)])) {
    notesArray.add(allNotes[convertIndex(noteIndex)]);
  }
  for (final int interval in chordType.intervals) {
    if (!notesArray.contains(allNotes[convertIndex(noteIndex + interval)])) {
      notesArray.add(allNotes[convertIndex(noteIndex + interval)]);
    }
  }
}

class Guess {
  Guess({
    this.score = -1,
    this.key = "",
    this.type = "",
  });
  int score;
  String key;
  String type;
}

List<Guess> compareScalesAndNotes(List<String> notesArray) {
  List<Guess> bestGuess = [
    Guess(score: 0),
  ];
  allNotes.asMap().forEach((i, note) {
    for (final scale in scales) {
      int score = 0;
      score += notesArray.contains(note) ? 1 : 0;
      for (final noteInt in scale.intervals) {
        score += notesArray.contains(allNotes[convertIndex(noteInt + i)]) ? 1 : 0;
      }
      if (bestGuess[0].score < score) {
        bestGuess = [
          Guess(score: score, key: note, type: scale.name),
        ];
      } else if (bestGuess[0].score == score) {
        bestGuess.add(Guess(score: score, key: note, type: scale.name));
      }
    }
  });
  return bestGuess;
}

class KeyInput extends StatelessWidget {
  const KeyInput({
    Key? key,
    this.chords = const [],
  }) : super(key: key);

  final List<Chord?> chords;

  String getChordString() {
    final buffer = StringBuffer();
    if (chords.isNotEmpty) {
      for (final c in chords) {
        buffer.write("${notes[(c!.note + transpose) % 12]}${c.text.isNotEmpty ? c.text[0] : ''}, ");
      }
    }
    return buffer.isNotEmpty ? buffer.toString().substring(0, buffer.length - 2) : "";
  }

  String pickOne(String s) {
    return s.split("|")[0];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: keyInputService.stream$,
        builder: (context, snapshot) {
          /*
          final String str = getChordString();
          notesArray = [];
          final List<String> chords = str.replaceAll(" ", '').split(",");
          for (final String chord in chords) {
            getNotesFromChords(chord);
          }
          final List<Guess> guesses = compareScalesAndNotes(notesArray);
          */
          /*
      for (final guess in guesses) {
        print(guess.key);
      }*/
          //final String text = pickOne(notes[transpose % 12]);
          final String text = transpose.toString();
          //final String text = guesses[0].key + (guesses[0].type == "minor" ? "m" : "");
          return FittedBox(
            fit: BoxFit.none,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        transpose--;
                        canvasService.update();
                        keyInputService.update();
                      },
                      icon: Icon(Icons.remove_rounded, color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Palette.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        transpose++;
                        canvasService.update();
                        keyInputService.update();
                      },
                      icon: Icon(Icons.add_rounded, color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
    /*else {
      return Text("${currentPage + 1}/${maxPages + 1}");
    }*/
  }
}
