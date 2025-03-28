class Income {
  final String id;
  final int amount;
  final String source;
  final DateTime date;
  final String note;
  final String userId;

  Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.note,
    required this.userId,
  });
  Income copyWith({
    String? id,
    int? amount,
    String? source,
    DateTime? date,
    String? note,
    String? userId,
  }){
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      note: note ?? this.note,
      userId: userId ?? this.userId,
    );
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: json['amount'],
      source: json['source'],
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
      userId: json['userid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'source': source,
      'date': date.toIso8601String(),
      'note': note,
      'userid': userId,
    };
  }
 @override
  String toString() {
    return 'Income(id: $id, amount: $amount, source: $source, date: $date, note: $note, userId: $userId)';
  }
}
