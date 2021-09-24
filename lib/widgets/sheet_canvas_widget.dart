import 'dart:convert';

import 'package:chordship/models/chord_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<String> naturalNotation = ["Do", "Do#|Reb", "Re", "Re#|Mib", "Mi", "Fa", "Fa#|Solb", "Sol", "Sol#|Lab", "La", "La#|Sib", "Si"];
List<String> englishNotation = ["C", "C#|Db", "D", "D#|Eb", "E", "F", "F#|Gb", "G", "G#|Ab", "A", "A#|Bb", "B"];

List<Rect> lettersRect = [];
int maxPages = 1;
int currentPage = 0;
int transpose = 0;
int columns = 1;
bool lettersNotation = false;
bool showChords = true;
List<String> notes = ["C", "C#|Db", "D", "D#|Eb", "E", "F", "F#|Gb", "G", "G#|Ab", "A", "A#|Bb", "B"];

class SheetCanvasWidget extends CustomPainter {
  SheetCanvasWidget({
    this.text = "",
    this.fontSize = 1,
    this.editor = false,
    this.chords = const [],
  });
  double fontSize;
  final String text;
  final bool editor;
  final List<Chord> chords;

  bool containsOnlySpaces(String str) {
    for (var i = 0; i < str.length; i++) {
      if (str[i] != " ") return false;
    }
    return str.isNotEmpty;
  }

  bool canAddLine(String originalString, String generatedString) {
    if (!showChords && containsOnlySpaces(generatedString)) {
      return false;
    } else {
      if (generatedString.isEmpty && originalString.isNotEmpty) return false;
      return true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (editor) columns = 1;
    notes = lettersNotation ? englishNotation : naturalNotation;
    const int rowDistance = 1;
    if (currentPage > maxPages) currentPage = maxPages;
    final double fontHeight = editor ? (20.0 * fontSize).floor().toDouble() : (20.0) * fontSize;
    final textStyle = GoogleFonts.inter(
      color: Colors.black,
      fontSize: fontHeight - rowDistance,
      height: fontHeight * 2.0 / fontHeight,
    );
    final chordStyle = GoogleFonts.inter(
      color: Colors.black,
      fontSize: fontHeight - rowDistance,
      height: fontHeight * 2.0 / fontHeight,
      fontWeight: FontWeight.bold,
    );

    final Map<String, Size> sizes = {};
    final List<String> lines = [];
    final List<Rect> rects = [];
    double offsetY = 0.0;
    double columnOffset = 0;
    double offsetX = 0.0;

    StringBuffer currLine = StringBuffer();
    int columnCounter = 0;
    int rectIndexOffset = 0;
    for (final String line in const LineSplitter().convert(text)) {
      for (int i = 0; i < line.length; i++) {
        currLine.write(line[i]);
        if (sizes[line[i]] == null) {
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: line[i],
              style: textStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: size.width);
          sizes[line[i]] = Size(tp.size.width - 0.5, tp.size.height);
        }
        /*
        if (offsetY + sizes[line[i]]!.height >= size.height) {
          if (!editor) {
            offsetY = 0;
            columnOffset += size.width / columns;
          }
        }*/
        if (offsetX + sizes[line[i]]!.width >= size.width / columns - 20 + columnOffset && line.contains(" ") && currLine.toString().contains(" ")) {
          while (line[i] != " " && i > 0) {
            i--;
            if (rects.isNotEmpty) rects.removeLast();
            if (currLine.isNotEmpty) {
              final String str = currLine.toString();
              currLine = StringBuffer(str.substring(0, str.length - 1));
            }
          }
          if (line[i] == " ") {
            offsetX = rects.last.right;
            rects.add(Offset(offsetX, offsetY) & sizes[line[i]]!);
          }

          if (canAddLine(line, currLine.toString())) {
            lines.add(currLine.toString());
          } else {}

          currLine.clear();
          offsetX = columnOffset;
          offsetY += fontHeight * (showChords || editor ? 2 : 1.5);
          if (offsetY >= size.height) {
            offsetY = 0;
            columnOffset += size.width / columns + 20;
            offsetX = columnOffset;
            columnCounter++;
            if (columnCounter == currentPage * columns) {
              rectIndexOffset = rects.length;
              rects.clear();
              lines.clear();
              columnOffset = 0;
              offsetX = 0;
            }
          }
        } else {
          rects.add(Offset(offsetX, offsetY) & sizes[line[i]]!);
          offsetX += sizes[line[i]]!.width;
        }
      }
      offsetX = columnOffset;

      if (canAddLine(line, currLine.toString())) {
        offsetY += fontHeight * (showChords || editor ? 2 : 1.5);
        lines.add(currLine.toString());
      } else {}

      if (offsetY >= size.height) {
        offsetY = 0;
        columnOffset += size.width / columns + 20;
        offsetX = columnOffset;
        columnCounter++;
        if (columnCounter == currentPage * columns) {
          rectIndexOffset = rects.length;
          rects.clear();
          lines.clear();
          columnOffset = 0;
          offsetX = 0;
        }
      }
      currLine.clear();
    }
    if (showChords || editor) {
      for (int i = 0; i < rects.length; i++) {
        final Rect rect = rects[i];

        final List<Chord> chord = chords.where((Chord el) => el.char == i + rectIndexOffset).toList();
        if (chord.isNotEmpty) {
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: pickOne(notes[(chord[0].note + transpose) % 12]) + chord[0].text,
              style: chordStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: size.width);
          tp.paint(canvas, Offset(rect.left, rect.top - fontHeight + rowDistance));
        }

        if (editor) {
          final Paint paint = Paint()
            ..color = const Color(0x3333ccff)
            ..style = PaintingStyle.fill
            ..strokeWidth = 1;
          canvas.drawRect(rect, paint);
        }
      }
    }
    lettersRect = rects;

    offsetY = 0;
    offsetX = 0;
    for (final String line in lines) {
      final textSpan = TextSpan(
        text: line,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offsetX, offsetY));
      offsetY += fontHeight * (showChords || editor ? 2 : 1.5);
      if (offsetY >= size.height) {
        offsetY = 0;
        offsetX += size.width / columns + 20;
        if (columns == 1) break;
      }
    }
    if (columns == 2) {
      final p1 = Offset(size.width / 2, 0);
      final p2 = Offset(size.width / 2, size.height + fontHeight * 2);
      final paint = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1;
      canvas.drawLine(p1, p2, paint);
    }
    maxPages = (columnCounter / columns).floor();
    if (currentPage > maxPages) currentPage = maxPages;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  String pickOne(String s) {
    return s.split("|")[0];
  }
}
