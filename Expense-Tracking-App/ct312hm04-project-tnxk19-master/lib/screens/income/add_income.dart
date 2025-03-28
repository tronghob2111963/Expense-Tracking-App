import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/service/income_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';

class AddIncome extends StatefulWidget {
  final User user;
  const AddIncome({super.key, required this.user});

  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final IncomeService _incomeService = IncomeService();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome(IncomeProvider incomeProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (incomeProvider.amount <= 0) {
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
      final userId = widget.user.id;
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      print('User ID in AddIncome: $userId');
      print('Amount before saving: ${incomeProvider.amount}');
      await incomeProvider.saveIncome(userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Income added successfully'),
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
            content: Text('Failed to add income: $e'),
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
    final incomeProvider = Provider.of<IncomeProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Income')),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                      onChanged: (value) {
                        String cleanedValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanedValue.isNotEmpty) {
                          double parsed = double.parse(cleanedValue);
                          int rounded = parsed.toInt();
                          String formatted = NumberFormat.currency(
                                  locale: 'vi_VN', symbol: '', decimalDigits: 0)
                              .format(rounded);

                          formatted = '$formatted vn₫';

                          int baseOffset =
                              _amountController.selection.baseOffset;
                          int newOffset = formatted.length - 3;

                          if (baseOffset < formatted.length) {
                            newOffset = baseOffset;
                          }

                          _amountController.value = TextEditingValue(
                            text: formatted,
                            selection:
                                TextSelection.collapsed(offset: newOffset),
                          );

                          incomeProvider.setAmount(rounded.toDouble());
                        } else {
                          _amountController.value =
                              const TextEditingValue(text: '');
                          incomeProvider.setAmount(0.0);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: incomeProvider.source.isEmpty
                          ? null
                          : incomeProvider.source,
                      items: ['Salary', 'Bonus', 'Investment', 'Gift', 'Other']
                          .map((source) {
                        return DropdownMenuItem(
                            value: source, child: Text(source));
                      }).toList(),
                      onChanged: (value) {
                        incomeProvider.setSource(value!);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Income Source',
                        prefixIcon: Icon(Icons.source),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Income Source'),
                      validator: (value) => value == null
                          ? 'Please select an income source'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: incomeProvider.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(incomeProvider.date),
                          );
                          if (pickedTime != null) {
                            incomeProvider.setDate(DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            ));
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
                              .format(incomeProvider.date)),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a date'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => incomeProvider.setNote(value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm'),
                                        content: const Text(
                                            'Are you sure you want to save this income?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            child: const Text('Save',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    await _saveIncome(incomeProvider);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Save',
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
