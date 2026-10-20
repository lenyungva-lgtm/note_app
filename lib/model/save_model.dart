class SaveModel {
  int? id;
  String note;
  String date;
  String type;
  double money;

  SaveModel({
    this.id,
    required this.note,
    required this.date,
    required this.type,
    required this.money,
  });

  // convert from Object Dart to Map
  Map<String, dynamic> toMap() {
    return {"id": id, "note": note, "date": date, "type": type, "money": money};
  }

  // convert from Map to Object Dart
  factory SaveModel.fromMap(Map<String, dynamic> map) {
    return SaveModel(
      id: map['id'],
      note: map['note'],
      date: map['date'],
      type: map['type'],
      money: map['money'],
    );
  }
}
