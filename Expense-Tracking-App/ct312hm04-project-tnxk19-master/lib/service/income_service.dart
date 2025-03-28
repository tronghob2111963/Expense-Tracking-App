import 'package:ct312h_project/models/income.dart';
import 'package:ct312h_project/service/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

class IncomeService {
  // Thêm thu nhập
  Future<Income> addIncome(Income income, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (userId.isEmpty) {
        throw Exception('User ID is empty. Please provide a valid user ID.');
      }

      final incomeModel = await pb.collection('income').create(
        body: {
          ...income.toJson(),
          'userId': userId,
        },
      );

      print('Created income: ${incomeModel.toJson()}');
      return Income.fromJson(incomeModel.toJson());
    } catch (error) {
      print('Error adding income: $error');
      throw Exception('Failed to add income: $error');
    }
  }

  // Xem danh sách thu nhập của user đã đăng nhập
  Future<List<Income>> getIncomesByUser(String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (userId.isEmpty) {
        throw Exception('User ID is empty. Please provide a valid user ID.');
      }

      final response = await pb.collection('income').getList(
            // Thay 'incomes' thành 'income'
            filter: 'userId = "$userId"',
            sort: '-date',
            perPage: 50,
          );

      final incomes = response.items
          .map((record) => Income.fromJson(record.toJson()))
          .toList();

      print('Fetched incomes for user $userId: ${incomes.length} items');
      return incomes;
    } catch (error) {
      print('Error fetching incomes: $error');
      throw Exception('Failed to fetch incomes: $error');
    }
  }

  // Xem chi tiết một thu nhập
  Future<Income> getIncomeById(String incomeId, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (incomeId.isEmpty || userId.isEmpty) {
        throw Exception('Income ID or User ID is empty.');
      }

      final record = await pb
          .collection('income')
          .getOne(incomeId); // Thay 'incomes' thành 'income'

      final recordUserId = record.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception('You do not have permission to view this income.');
      }

      final income = Income.fromJson(record.toJson());
      print('Fetched income: ${income.toString()}');
      return income;
    } catch (error) {
      print('Error fetching income: $error');
      throw Exception('Failed to fetch income: $error');
    }
  }

  // Sửa thu nhập
  Future<Income> updateIncome(Income income, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (income.id.isEmpty || userId.isEmpty) {
        throw Exception('Income ID or User ID is empty.');
      }

      final existingRecord = await pb
          .collection('income')
          .getOne(income.id); // Thay 'incomes' thành 'income'

      final recordUserId = existingRecord.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception(
            'Income not found or you do not have permission to update it.');
      }

      final updatedRecord = await pb.collection('income').update(
        // Thay 'incomes' thành 'income'
        income.id,
        body: {
          ...income.toJson(),
          'userId': userId,
        },
      );

      final updatedIncome = Income.fromJson(updatedRecord.toJson());
      print('Updated income: ${updatedIncome.toString()}');
      return updatedIncome;
    } catch (error) {
      print('Error updating income: $error');
      throw Exception('Failed to update income: $error');
    }
  }

  // Xóa thu nhập
  Future<void> deleteIncome(String incomeId, String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      if (incomeId.isEmpty || userId.isEmpty) {
        throw Exception('Income ID or User ID is empty.');
      }
      final existingRecord = await pb
          .collection('income')
          .getOne(incomeId); // Thay 'incomes' thành 'income'

      final recordUserId = existingRecord.data['userId'] as String?;
      if (recordUserId != userId) {
        throw Exception(
            'Income not found or you do not have permission to delete it.');
      }

      await pb
          .collection('income')
          .delete(incomeId); // Thay 'incomes' thành 'income'
      print('Deleted income with ID: $incomeId');
    } catch (error) {
      print('Error deleting income: $error');
      throw Exception('Failed to delete income: $error');
    }
  }
}
