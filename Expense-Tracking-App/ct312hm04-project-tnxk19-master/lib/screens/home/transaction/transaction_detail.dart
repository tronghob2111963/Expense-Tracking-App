import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/models/income.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/expense.dart';
import '../../../../providers/expense_provider.dart';
import '../../../../providers/income_provider.dart';
import '../../../../service/expense_service.dart';
import '../../expense/edit_expense.dart';
import '../../income/edit_income.dart';
import 'Income_detail.dart';
import 'transaction_detail_screen.dart'; // Import TransactionDetailBottomSheet

class TransactionDetail extends StatefulWidget {
  final User user;
  const TransactionDetail({super.key, required this.user});

  @override
  _TransactionDetailState createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoadingExpenses = true;
  bool _isLoadingIncomes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fetchExpenses();
    _fetchIncomes();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoadingExpenses = true;
      _errorMessage = null;
    });

    try {
      final userId = widget.user.id;
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.fetchExpenses(userId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch expenses: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch expenses: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingExpenses = false;
      });
    }
  }

  Future<void> _fetchIncomes() async {
    setState(() {
      _isLoadingIncomes = true;
      _errorMessage = null;
    });

    try {
      final userId = widget.user.id;
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      await incomeProvider.fetchIncomes(userId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch incomes: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch incomes: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingIncomes = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Transaction Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseList(),
          _buildIncomeList(),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    if (_isLoadingExpenses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchExpenses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = List.from(expenseProvider.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return _buildTransactionList(expenses, isExpense: true);
  }

  Widget _buildIncomeList() {
    if (_isLoadingIncomes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchIncomes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final incomeProvider = Provider.of<IncomeProvider>(context);
    final incomes = List.from(incomeProvider.incomes)
      ..sort((a, b) => b.date.compareTo(a.date));

    return _buildTransactionList(incomes, isExpense: false);
  }

  Widget _buildTransactionList(List transactions, {required bool isExpense}) {
    if (transactions.isEmpty) {
      return const Center(child: Text("No transactions yet!"));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final amount = isExpense ? transaction.expense : transaction.amount;
        final category = isExpense ? transaction.category : transaction.source;

        return GestureDetector(
          onTap: () {
            if (isExpense) {
              // Hiển thị chi tiết cho Expense
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailBottomSheet(
                    transaction: transaction,
                    isExpense: isExpense,
                    userId: widget.user.id,
                  ),
                ),
              ).then((success) {
                if (success == true) {
                  _fetchExpenses();
                }
              });
            } else {
              // Hiển thị chi tiết cho Income
              IncomeDetail.show(
                context,
                transaction as Income,
                widget.user,
              ).then((success) {
                if (success == true) {
                  _fetchIncomes();
                }
              });
            }
          },
          child: Dismissible(
            key: Key(transaction.id.toString()),
            background: Container(
              alignment: Alignment.centerLeft,
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                if (isExpense) {
                  final updatedExpense = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExpense(
                        expense: transaction,
                        userId: widget.user.id,
                      ),
                    ),
                  );

                  if (updatedExpense == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Expense updated successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                    await _fetchExpenses();
                  }
                } else {
                  final updatedIncome = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditIncome(
                        income: transaction,
                        user: widget.user,
                        userId: widget.user.id,
                      ),
                    ),
                  );

                  if (updatedIncome == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Income updated successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                    await _fetchIncomes();
                  }
                }
                return false;
              } else if (direction == DismissDirection.endToStart) {
                return await _confirmDelete(transaction, isExpense);
              }
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpense ? Colors.red : Colors.green,
                    child: Icon(
                      isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(category),
                  subtitle:
                      Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
                  trailing: Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(dynamic transaction, bool isExpense) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              if (isExpense) {
                try {
                  final userId = widget.user.id;
                  if (userId.isEmpty) {
                    throw Exception('User ID is empty');
                  }

                  await Provider.of<ExpenseProvider>(context, listen: false)
                      .removeExpense(transaction.id, userId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Expense deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                  await _fetchExpenses();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete expense: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              } else {
                try {
                  final userId = widget.user.id;
                  if (userId.isEmpty) {
                    throw Exception('User ID is empty');
                  }

                  await Provider.of<IncomeProvider>(context, listen: false)
                      .removeIncome(transaction.id, userId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Income deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                  await _fetchIncomes();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete income: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
