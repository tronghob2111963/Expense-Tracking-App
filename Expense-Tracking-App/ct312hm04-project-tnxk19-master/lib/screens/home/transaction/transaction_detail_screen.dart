import 'package:ct312h_project/models/expense.dart';
import 'package:ct312h_project/screens/expense/edit_expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final dynamic transaction;
  final bool isExpense;
  final String userId;

  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
    required this.isExpense,
    required this.userId,
  });

  // Hàm format tiền VND
  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
            .format(value) +
        ' VND';
  }

  // Phương thức tạo hiệu ứng chuyển trang
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Trượt từ phải sang trái
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expense = isExpense ? transaction as Expense : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Detail Expense',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: expense?.category ?? 'N/A',
                        color: Colors.blue,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.account_balance_wallet,
                        label: 'Amount',
                        value: expense != null
                            ? _formatCurrency(expense.expense)
                            : 'N/A',
                        color: Colors.green,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: expense != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(expense.date)
                            : 'N/A',
                        color: Colors.orange,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.description,
                        label: 'Description',
                        value: expense?.description ?? 'No description',
                        color: Colors.purple,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.note,
                        label: 'Note',
                        value: expense?.note ?? 'No note',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: kToolbarHeight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Sử dụng _createRoute thay vì MaterialPageRoute
                      Navigator.push(
                        context,
                        _createRoute(
                          EditExpense(
                            expense: expense!,
                            userId: userId,
                          ),
                        ),
                      ).then((success) {
                        if (success == true) {
                          Navigator.pop(context, true);
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context, transaction, bool isExpense) {}
}
