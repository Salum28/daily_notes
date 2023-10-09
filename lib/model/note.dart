class Note {
  // Atributes
  int? id;
  String? title;
  String? description;
  String? date;

  // Constructor
  Note(this.title, this.description, this.date);

  // Named Constructor
  Note.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    date = map['date'];
  }

  // Methods
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'description': description,
      'date': date
    };
    if(id != null) {
      map['id'] = id;
    }
    return map;
  }
}