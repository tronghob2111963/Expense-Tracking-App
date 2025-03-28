import 'package:ct312h_project/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'package:ct312h_project/screens/users/LoginScreen.dart';

import 'package:ct312h_project/screens/users/LoginScreen.dart'; // Import LoginScreen
import '../providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'providers/income_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => IncomeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Bắt đầu từ LoginScreen
      debugShowCheckedModeBanner: false, // Tắt debug banner
    );
  }
}
