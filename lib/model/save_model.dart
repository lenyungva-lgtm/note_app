class SaveModel {
  final int? id;
  final String note;
  final String date;
  final String type;
  final double money;

  SaveModel({
    this.id,
    required this.note,
    required this.date,
    required this.type,
    required this.money,
  });

  // convert from Object Dart to Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'note': note,
      'date': date,
      'type': type,
      'money': money,
    };
  }

  // convert from Map to Object Dart
  factory SaveModel.fromMap(Map<String, dynamic> map) {
    return SaveModel(
      id: (map['id'] as num?)?.toInt(),
      note: map['note'] as String,
      date: map['date'] as String,
      type: map['type'] as String,
      money: (map['money'] as num).toDouble(),
    );
  }
}
