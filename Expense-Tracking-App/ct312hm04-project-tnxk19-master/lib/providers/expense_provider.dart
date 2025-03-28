import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../service/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final ExpenseService _expenseService =
      ExpenseService(); // Thêm ExpenseService

  List<Expense> get expenses => _expenses;

  // Thêm chi tiêu
  Future<void> addExpense(Expense expense, String userId) async {
    try {
      final newExpense = await _expenseService.addExpense(expense, userId);
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      rethrow; // Ném lại lỗi để xử lý ở UI nếu cần
    }
  }

  // Sửa chi tiêu
  Future<void> editExpense(Expense updatedExpense, String userId) async {
    try {
      final expense =
          await _expenseService.updateExpense(updatedExpense, userId);
      int index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Xóa chi tiêu
  Future<void> removeExpense(String expenseId, String userId) async {
    try {
      await _expenseService.deleteExpense(expenseId, userId);
      _expenses.removeWhere((e) => e.id == expenseId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách chi tiêu
  Future<void> fetchExpenses(String userId) async {
    try {
      final expenses = await _expenseService.getExpensesByUser(userId);
      _expenses.clear();
      _expenses.addAll(expenses);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
