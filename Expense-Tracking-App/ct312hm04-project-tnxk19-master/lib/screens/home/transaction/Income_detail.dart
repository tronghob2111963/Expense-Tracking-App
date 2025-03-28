import 'package:ct312h_project/models/income.dart';
import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/screens/income/edit_income.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeDetail extends StatelessWidget {
  final Income income;
  final User user;

  const IncomeDetail({
    super.key,
    required this.income,
    required this.user,
  });

  // Hàm format tiền VND
  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
            .format(value) +
        ' VND';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Giới hạn chiều cao của Column
      children: [
        // AppBar tùy chỉnh
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Detail Income',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Để cân đối với IconButton
            ],
          ),
        ),
        // Nội dung chính
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          // Nguồn
                          _buildDetailRow(
                            icon: Icons.category,
                            label: 'Source',
                            value: income.source ?? 'N/A',
                            color: Colors.blue,
                          ),
                          const Divider(height: 24),

                          // Số tiền
                          _buildDetailRow(
                            icon: Icons.account_balance_wallet,
                            label: 'Amount',
                            value: _formatCurrency(income.amount),
                            color: Colors.green,
                          ),
                          const Divider(height: 24),

                          // Ngày
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: DateFormat('dd/MM/yyyy HH:mm')
                                .format(income.date),
                            color: Colors.orange,
                          ),
                          const Divider(height: 24),

                          // Ghi chú
                          _buildDetailRow(
                            icon: Icons.note,
                            label: 'Note',
                            value: income.note.isEmpty ? 'N/A' : income.note,
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
                          if (user.id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('User ID is empty'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(
                              context, true); // Trả về true khi chỉnh sửa
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditIncome(
                                income: income,
                                user: user,
                                userId: user.id,
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
                  const SizedBox(height: 16), // Thêm khoảng cách dưới cùng
                ],
              ),
            ),
          ),
        ),
      ],
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

  static Future<dynamic> show(
      BuildContext context, Income income, User user) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: IncomeDetail(
            income: income,
            user: user,
          ),
        ),
      ),
    );
  }
}
