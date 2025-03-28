import 'package:ct312h_project/models/expense.dart';
import 'package:ct312h_project/service/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';
class ExpenseService {
  // Thêm chi tiêu
  Future<Expense> addExpense(Expense expense, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (userId.isEmpty) {
        throw Exception('User ID is empty. Please provide a valid user ID.');
      }

      final expenseModel = await pb.collection('expenses').create(
        body: {
          ...expense.toJson(),
          'userId': userId,
        },
      );

      print('Created expense: ${expenseModel.toJson()}');
      return Expense.fromJson(expenseModel.toJson());
    } catch (error) {
      print('Error adding expense: $error');
      throw Exception('Failed to add expense: $error');
    }
  }

  // Xem danh sách chi tiêu của user đã đăng nhập
  Future<List<Expense>> getExpensesByUser(String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (userId.isEmpty) {
        throw Exception('User ID is empty. Please provide a valid user ID.');
      }

      final response = await pb.collection('expenses').getList(
            filter: 'userId = "$userId"',
            sort: '-date',
            perPage: 50,
          );

      final expenses = response.items
          .map((record) => Expense.fromJson(record.toJson()))
          .toList();

      print('Fetched expenses for user $userId: ${expenses.length} items');
      return expenses;
    } catch (error) {
      print('Error fetching expenses: $error');
      throw Exception('Failed to fetch expenses: $error');
    }
  }

  // Xem chi tiết một chi tiêu
  Future<Expense> getExpenseById(String expenseId, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (expenseId.isEmpty || userId.isEmpty) {
        throw Exception('Expense ID or User ID is empty.');
      }

      final record = await pb.collection('expenses').getOne(expenseId);

      final recordUserId = record.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception('You do not have permission to view this expense.');
      }

      final expense = Expense.fromJson(record.toJson());
      print('Fetched expense: ${expense.toString()}');
      return expense;
    } catch (error) {
      print('Error fetching expense: $error');
      throw Exception('Failed to fetch expense: $error');
    }
  }

  // Sửa chi tiêu
  Future<Expense> updateExpense(Expense expense, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (expense.id.isEmpty || userId.isEmpty) {
        throw Exception('Expense ID or User ID is empty.');
      }

      final existingRecord = await pb.collection('expenses').getOne(expense.id);

      final recordUserId = existingRecord.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception(
            'Expense not found or you do not have permission to update it.');
      }

      final updatedRecord = await pb.collection('expenses').update(
        expense.id,
        body: {
          ...expense.toJson(),
          'userId': userId,
        },
      );

      final updatedExpense = Expense.fromJson(updatedRecord.toJson());
      print('Updated expense: ${updatedExpense.toString()}');
      return updatedExpense;
    } catch (error) {
      print('Error updating expense: $error');
      throw Exception('Failed to update expense: $error');
    }
  }

  // Xóa chi tiêu
  Future<void> deleteExpense(String expenseId, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (expenseId.isEmpty || userId.isEmpty) {
        throw Exception('Expense ID or User ID is empty.');
      }

      final existingRecord = await pb.collection('expenses').getOne(expenseId);

      final recordUserId = existingRecord.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception(
            'Expense not found or you do not have permission to delete it.');
      }

      await pb.collection('expenses').delete(expenseId);
      print('Deleted expense with ID: $expenseId');
    } catch (error) {
      print('Error deleting expense: $error');
      throw Exception('Failed to delete expense: $error');
    }
  }
}
