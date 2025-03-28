import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/screens/users/UserInfoScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../transaction/transaction_detail.dart';
import '../../../models/expense.dart';
import '../../../models/income.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/income_provider.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
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
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    final incomes = Provider.of<IncomeProvider>(context).incomes;

    // Kết hợp danh sách giao dịch và sắp xếp theo ngày giảm dần
    final transactions = [...expenses, ...incomes]
      ..sort((a, b) => (a as dynamic).date.compareTo((b as dynamic).date));

    final totalIncome = incomes.fold(0, (sum, item) => sum + item.amount);
    final totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);
    final totalBalance = totalIncome - totalExpense;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.amber,
                        child: Icon(CupertinoIcons.person_fill,
                            color: Colors.yellow[900]),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome back!",
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(widget.user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      // Điều hướng đến UserInfoScreen
                      Navigator.push(
                        context,
                        _createRoute(UserInfoScreen(user: widget.user)),
                      );
                    },
                    icon: const Icon(CupertinoIcons.settings),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tổng số dư
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.green, Colors.blue],
                    transform: const GradientRotation(pi / 4),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 2,
                        color: Colors.grey.shade500,
                        offset: const Offset(5, 5))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Total Balance",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                            .format(totalBalance),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildIncomeExpenseItem("Income", totalIncome,
                              Colors.greenAccent, CupertinoIcons.arrow_up),
                          buildIncomeExpenseItem("Expense", totalExpense,
                              Colors.redAccent, CupertinoIcons.arrow_down),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Tiêu đề danh sách giao dịch
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 20),

              // Danh sách giao dịch (tối đa 4 giao dịch)
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("No transactions yet!"))
                    : ListView.builder(
                        itemCount:
                            transactions.length > 4 ? 4 : transactions.length,
                        itemBuilder: (context, i) {
                          final transaction = transactions[i];
                          final isIncome = transaction is Income;
                          return buildTransactionItem(
                              transaction, context, isIncome);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thu nhập & chi tiêu
  Widget buildIncomeExpenseItem(
      String label, int amount, Color color, IconData icon) {
    return Row(children: [
      Container(
        width: 25,
        height: 25,
        decoration:
            const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
        child: Center(child: Icon(icon, size: 12, color: color)),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w400)),
          Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(amount),
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      )
    ]);
  }

  // Widget hiển thị một giao dịch
  Widget buildTransactionItem(
      dynamic transaction, BuildContext context, bool isIncome) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 3,
                offset: const Offset(2, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                      isIncome
                          ? CupertinoIcons.arrow_up
                          : CupertinoIcons.arrow_down,
                      color: isIncome ? Colors.green : Colors.red),
                  const SizedBox(width: 12),
                  Text(isIncome ? transaction.source : transaction.category,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(transaction.amount),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(DateFormat('dd/MM/yyyy').format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
