class Genre {
  final String name;
  final int id;

  Genre(this.name, this.id);

  Genre.fromJSON(Map json)
      : name = json['name'],
        id = json['id'];

  @override
  String toString() {
    // print(name);
    return super.toString();
  }
}
