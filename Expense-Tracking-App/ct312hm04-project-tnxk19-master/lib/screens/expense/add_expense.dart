import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/models/expense.dart';
import 'package:ct312h_project/screens/home/transaction/transaction_detail.dart';
import 'package:ct312h_project/screens/home/views/home_screen.dart';
import 'package:ct312h_project/service/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  final User user;
  const AddExpense({super.key, required this.user});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedCategory;

  final List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Others'
  ];

  final ExpenseService _expenseService = ExpenseService();

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDate);
    super.initState();
  }

  void _showConfirmationDialog(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to save this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final expense = Expense(
                    id: '', // PocketBase sẽ tự tạo id
                    category: selectedCategory ?? '',
                    description: descriptionController.text,
                    date: selectedDate,
                    expense: int.tryParse(expenseController.text
                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0,
                  );

                  // Truyền widget.user.id vào addExpense
                  await _expenseService.addExpense(expense, widget.user.id);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense added successfully')),
                  );

                  // Đóng dialog và chuyển về HomeScreen
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TransactionDetail(user: widget.user),
                    ),
                  );
                } catch (e) {
                  // Hiển thị thông báo lỗi
                  Navigator.of(context).pop(); // Đóng dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newDate == null) return;

    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (newTime == null) return;

    setState(() {
      selectedDate = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        newTime.hour,
        newTime.minute,
      );
      dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            'Add Expense',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: expenseController,
                  keyboardType: TextInputType.number,
                  decoration:
                      _inputDecoration('Amount', FontAwesome.sack_dollar_solid),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter an amount'
                      : null,
                  onChanged: (value) {
                    String cleanedValue =
                        value.replaceAll(RegExp(r'[^0-9]'), '');

                    if (cleanedValue.isNotEmpty) {
                      double parsed = double.parse(cleanedValue);
                      String formatted = NumberFormat.currency(
                              locale: 'vi_VN', symbol: '', decimalDigits: 0)
                          .format(parsed);

                      // Vị trí con trỏ trước khi format
                      int baseOffset = expenseController.selection.baseOffset;

                      // Cập nhật text với đơn vị tiền tệ ₫
                      formatted = '$formatted vn₫';

                      // Tính lại vị trí con trỏ
                      int newOffset =
                          formatted.length - 2; // Giữ con trỏ ngay trước " ₫"

                      if (baseOffset < formatted.length) {
                        newOffset = baseOffset;
                      }

                      expenseController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: newOffset),
                      );
                    } else {
                      // Nếu xóa hết thì reset
                      expenseController.value =
                          const TextEditingValue(text: '');
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  decoration: _inputDecoration(
                      'Category', FontAwesome.list_check_solid),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a category'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                      _inputDecoration('Description', FontAwesome.comment_dots),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  onTap: _pickDateTime,
                  decoration: _inputDecoration('Date', FontAwesome.clock),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a date and time'
                      : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: kToolbarHeight,
                  child: TextButton(
                    onPressed: () => _showConfirmationDialog(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, size: 16, color: Colors.grey),
      hintText: hintText,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
    );
  }
}
