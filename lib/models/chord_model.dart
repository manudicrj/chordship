class Chord {
  int char;
  int song;
  int note;
  String text;
  Chord({
    this.char = 0,
    this.song = 0,
    this.note = 0,
    this.text = "",
  });

  factory Chord.fromJson(Map<String, dynamic> json) {
    return Chord(
      char: json['char'] as int,
      song: json['song'] as int,
      note: json['note'] as int,
      text: json['text'] != null ? json['text'] as String : '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'char': char,
      'song': song,
      'note': note,
      'text': text,
    };
  }
}
