import 'package:ct312h_project/providers/expense_provider.dart';
import 'package:ct312h_project/providers/income_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct312h_project/screens/users/LoginScreen.dart';
import 'package:ct312h_project/providers/user_provider.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider(),
        ),

        // Thêm các provider khác nếu cần
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.grey.shade100,
            onPrimary: Colors.black,
            secondary: const Color(0xFF00B2E7),
            onSecondary: const Color(0xFFE064F7),
            tertiary: const Color(0xFFFF8D6C),
            outline: Colors.grey,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
