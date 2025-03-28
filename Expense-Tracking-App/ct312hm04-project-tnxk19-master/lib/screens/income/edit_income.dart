import 'package:ct312h_project/models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';
import '../../models/income.dart';

class EditIncome extends StatefulWidget {
  final User user;
  final Income income;
  const EditIncome({super.key, required this.income, required this.user, required String userId});

  @override
  _EditIncomeState createState() => _EditIncomeState();
}

class _EditIncomeState extends State<EditIncome> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedSource;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: _formatCurrency(widget.income.amount.toDouble()));
    _noteController = TextEditingController(text: widget.income.note);
    _selectedSource = widget.income.source;
    _selectedDate = widget.income.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return '${_currencyFormat.format(value)} vn₫';
  }

  void _onAmountChanged(String value) {
    int oldCursorPosition = _amountController.selection.baseOffset;

    String numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) {
      _amountController.text = '';
      return;
    }

    double parsed = double.parse(numericString);
    int rounded = parsed.toInt();
    String formatted = _formatCurrency(rounded.toDouble());

    int newCursorPosition = formatted.length - 3;

    if (oldCursorPosition < formatted.length) {
      newCursorPosition = oldCursorPosition;
    }

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
          offset: newCursorPosition.clamp(0, formatted.length - 1)),
    );
  }

  Future<void> _updateIncome(IncomeProvider incomeProvider) async {
    if (!_formKey.currentState!.validate()) return;

    double newAmount = double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0.0;
    if (newAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Amount must be greater than 0'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await incomeProvider.updateIncome(
        widget.income.id,
        newAmount,
        _selectedSource,
        _selectedDate,
        _noteController.text,
        widget.user.id,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Income updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update income: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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

  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Income')),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Số tiền
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final cleanedValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanedValue.isEmpty ||
                            double.tryParse(cleanedValue) == null ||
                            double.parse(cleanedValue) <= 0) {
                          return 'Please enter a valid amount greater than 0';
                        }
                        return null;
                      },
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 16),

                    // Nguồn thu nhập
                    DropdownButtonFormField<String>(
                      value: _selectedSource,
                      items: ['Salary', 'Bonus', 'Investment', 'Gift', 'Other']
                          .map((source) {
                        return DropdownMenuItem(
                            value: source, child: Text(source));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSource = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Income Source',
                        prefixIcon: Icon(Icons.source),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null
                          ? 'Please select an income source'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Ngày nhận thu nhập
                    TextFormField(
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd/MM/yyyy HH:mm')
                            .format(_selectedDate),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a date'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Ghi chú
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Nút cập nhật
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text(
                                          'Are you sure you want to update this income?'),
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
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _updateIncome(incomeProvider);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Update Income',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
// import 'package:ct312h_project/models/User.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../providers/income_provider.dart';
// import '../../models/income.dart';

// class EditIncome extends StatefulWidget {
//   final User user;
//   final Income income;
//   const EditIncome({super.key, required this.income, required String userId, required this.user});

//   @override
//   _EditIncomeState createState() => _EditIncomeState();
// }

// class _EditIncomeState extends State<EditIncome> {
//   late TextEditingController _amountController;
//   late TextEditingController _noteController;
//   late String _selectedSource;
//   late DateTime _selectedDate;
//   final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

//   @override
//   void initState() {
//     super.initState();
//     _amountController = TextEditingController(text: _formatCurrency(widget.income.amount.toDouble()));
//     _noteController = TextEditingController(text: widget.income.note);
//     _selectedSource = widget.income.source;
//     _selectedDate = widget.income.date;
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   String _formatCurrency(double value) {
//     return _currencyFormat.format(value);
//   }

// void _onAmountChanged(String value) {
//   // Lấy vị trí con trỏ hiện tại
//   int oldCursorPosition = _amountController.selection.baseOffset;

//   // Lọc chỉ lấy số
//   String numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
//   if (numericString.isEmpty) {
//     _amountController.text = '';
//     return;
//   }

//   // Chuyển đổi sang số và định dạng lại
//   double parsed = double.parse(numericString);
//   String formatted = _formatCurrency(parsed);

//   // Xác định độ dài của chuỗi số ban đầu (trước khi định dạng)
//   int rawLength = numericString.length;
//   int newCursorPosition = oldCursorPosition + (formatted.length - rawLength);

//   // Đảm bảo con trỏ không vượt quá ký hiệu tiền tệ
//   newCursorPosition = newCursorPosition.clamp(0, formatted.length - 1);

//   _amountController.value = TextEditingValue(
//     text: formatted,
//     selection: TextSelection.collapsed(offset: newCursorPosition),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Income')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Số tiền
//             TextFormField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Amount',
//                 prefixIcon: Icon(Icons.attach_money),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: _onAmountChanged,
//             ),
//             const SizedBox(height: 16),

//             // Nguồn thu nhập
//             DropdownButtonFormField(
//               value: _selectedSource,
//               items: ['Salary', 'Bonus', 'Investment', 'Gift', 'Other'].map((source) {
//                 return DropdownMenuItem(value: source, child: Text(source));
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedSource = value!;
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Income Source',
//                 prefixIcon: Icon(Icons.source),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Ngày nhận thu nhập
//             TextFormField(
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _selectedDate = pickedDate;
//                   });
//                 }
//               },
//               decoration: InputDecoration(
//                 labelText: 'Date',
//                 prefixIcon: const Icon(Icons.calendar_today),
//                 border: const OutlineInputBorder(),
//                 suffixIcon: const Icon(Icons.arrow_drop_down),
//               ),
//               controller: TextEditingController(text: DateFormat.yMMMd().format(_selectedDate)),
//             ),
//             const SizedBox(height: 16),

//             // Ghi chú
//             TextFormField(
//               controller: _noteController,
//               decoration: const InputDecoration(
//                 labelText: 'Note (Optional)',
//                 prefixIcon: Icon(Icons.note),
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 24),

//             // Nút cập nhật
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   bool confirm = await showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Confirm'),
//                       content: const Text('Are you sure you want to update this income?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Cancel'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                           child: const Text('Confirm', style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   );

//                   if (confirm == true) {
//                     double newAmount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
//                     if (newAmount <= 0) return;

//                     incomeProvider.updateIncome(
//                       widget.income.id,
//                       newAmount,
//                       _selectedSource,
//                       _selectedDate,
//                       _noteController.text,
//                       widget.user.id,
//                     );

//                     Navigator.pop(context, true);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text(
//                   'Update Income',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }