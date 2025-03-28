class Expense {
  final String id;
  final String category;
  final String description;
  final int expense;
  final DateTime date;
  final String? note; // Thêm note

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.expense,
    required this.date,
    this.note,
  });

  // Tạo một bản sao của Expense với các giá trị có thể thay đổi
  Expense copyWith({
    String? id,
    String? category,
    String? description,
    int? expense,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      expense: expense ?? this.expense,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  // Chuyển đổi từ JSON sang đối tượng Expense
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'],
      description: json['description'] ?? '',
      expense: json['expense'] as int,
      date: DateTime.parse(json['date']),
      note: json['note'], // Ánh xạ note từ JSON
    );
  }

  // Chuyển đổi từ đối tượng Expense sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'expense': expense,
      'date': date.toIso8601String(),
      'note': note, // Thêm note vào JSON
    };
  }

  // Getter cho amount
  int get amount => expense;
}
