import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class EditExpense extends StatefulWidget {
  final Expense expense;
  final String userId;

  const EditExpense({super.key, required this.expense, required this.userId});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController expenseController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  bool _isLoading = false;

  final List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    expenseController =
        TextEditingController(text: _formatCurrency(widget.expense.expense));
    descriptionController =
        TextEditingController(text: widget.expense.description);
    dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy HH:mm').format(widget.expense.date));
    selectedDate = widget.expense.date;
    selectedCategory = widget.expense.category;
  }

  @override
  void dispose() {
    expenseController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
            .format(value) +
        ' ₫';
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedExpense = Expense(
        id: widget.expense.id,
        category: selectedCategory ?? '',
        description: descriptionController.text,
        date: selectedDate,
        expense: int.tryParse(
                expenseController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0,
      );

      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.editExpense(updatedExpense, widget.userId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      initialTime: TimeOfDay.fromDateTime(selectedDate),
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
            'Edit Expense',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: expenseController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                          'Amount', FontAwesome.sack_dollar_solid),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter an amount'
                          : null,
                      onChanged: (value) {
                        String cleanedValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');

                        if (cleanedValue.isNotEmpty) {
                          int parsed = int.parse(cleanedValue);
                          String formatted = _formatCurrency(parsed);

                          int baseOffset =
                              expenseController.selection.baseOffset;
                          int newOffset = formatted.length - 2;

                          if (baseOffset < formatted.length) {
                            newOffset = baseOffset;
                          }

                          expenseController.value = TextEditingValue(
                            text: formatted,
                            selection:
                                TextSelection.collapsed(offset: newOffset),
                          );
                        } else {
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
                      decoration: _inputDecoration(
                          'Description', FontAwesome.comment_dots),
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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text(
                                        'Are you sure you want to update this expense?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        child: const Text('Confirm',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _saveExpense();
                                }
                              },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
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
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
