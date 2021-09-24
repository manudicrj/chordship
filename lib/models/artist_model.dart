class Artist {
  int id;
  String name;
  Artist({
    this.id = 0,
    this.name = "",
  });
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
