import 'package:flutter/material.dart';
import '../models/income.dart';
import '../service/income_service.dart';

class IncomeProvider extends ChangeNotifier {
  final List<Income> _incomes = [];
  final IncomeService _incomeService = IncomeService();
  double _amount = 0.0;
  String _source = 'Salary';
  DateTime _date = DateTime.now();
  String _note = '';

  List<Income> get incomes => _incomes;
  double get amount => _amount;
  String get source => _source;
  DateTime get date => _date;
  String get note => _note;

  void setAmount(double value) {
    if (value != _amount) {
      _amount = value;
      notifyListeners();
    }
  }

  void setSource(String value) {
    if (value != _source) {
      _source = value;
      notifyListeners();
    }
  }

  void setDate(DateTime value) {
    if (value != _date) {
      _date = value;
      notifyListeners();
    }
  }

  void setNote(String value) {
    if (value != _note) {
      _note = value;
      notifyListeners();
    }
  }

  Future<void> saveIncome(String userId) async {
    if (_amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    try {
      final newIncome = Income(
        id: '', // PocketBase sẽ tự động tạo ID
        amount: _amount.toInt(), // Chuyển đổi thành int
        source: _source,
        date: _date,
        note: _note,
        userId: userId,
      );

      final savedIncome = await _incomeService.addIncome(newIncome, userId);
      _incomes.add(savedIncome);
      _resetFields();
      notifyListeners();
    } catch (e) {
      print('Error in IncomeProvider.saveIncome: $e');
      rethrow;
    }
  }

  Future<void> updateIncome(String id, double newAmount, String newSource,
      DateTime newDate, String newNote, String userId) async {
    try {
      final index = _incomes.indexWhere((income) => income.id == id);
      if (index == -1) return;

      final oldIncome = _incomes[index];
      if (oldIncome.amount == newAmount.toInt() &&
          oldIncome.source == newSource &&
          oldIncome.date == newDate &&
          oldIncome.note == newNote) {
        return;
      }

      final updatedIncome = Income(
        id: id,
        amount: newAmount.toInt(),
        source: newSource,
        date: newDate,
        note: newNote,
        userId: userId,
      );

      final result = await _incomeService.updateIncome(updatedIncome, userId);
      _incomes[index] = result;
      notifyListeners();
    } catch (e) {
      print('Error in IncomeProvider.updateIncome: $e');
      rethrow;
    }
  }

  Future<void> removeIncome(String id, String userId) async {
    try {
      await _incomeService.deleteIncome(id, userId);
      _incomes.removeWhere((income) => income.id == id);
      notifyListeners();
    } catch (e) {
      print('Error in IncomeProvider.removeIncome: $e');
      rethrow;
    }
  }

  Future<void> fetchIncomes(String userId) async {
    try {
      final incomes = await _incomeService.getIncomesByUser(userId);
      _incomes.clear();
      _incomes.addAll(incomes);
      notifyListeners();
    } catch (e) {
      print('Error in IncomeProvider.fetchIncomes: $e');
      rethrow;
    }
  }

  void _resetFields() {
    _amount = 0.0;
    _source = 'Salary';
    _date = DateTime.now();
    _note = '';
  }
}
