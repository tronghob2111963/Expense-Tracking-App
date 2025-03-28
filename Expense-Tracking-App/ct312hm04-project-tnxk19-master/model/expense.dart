class Expense {
  final String name;
  final String icon;
  final String color;
  final String date;
  final String expense;

  Expense({required this.name, required this.icon, required this.color, required this.date, required this.expense});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      date: json['date'],
      expense: json['expense'],
    );
  }
}
