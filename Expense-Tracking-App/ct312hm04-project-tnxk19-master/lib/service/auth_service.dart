import 'package:ct312h_project/models/User.dart';
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_client.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketBaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        });
      });
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketBaseInstance();
    try {
      // Sử dụng bộ sưu tập 'users'
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record!.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('Sign in failed');
    }
  }

  Future<User> register(String email, String password, String name,
      String phone, String address, String country) async {
    final pb = await getPocketBaseInstance();
    try {
      // Sử dụng bộ sưu tập 'users'
      final record = await pb.collection('users').create(body: {
        "email": email,
        "password": password,
        "passwordConfirm": password, // PocketBase yêu cầu passwordConfirm
        "name": name,
        "phone": phone,
        "address": address,
        "country": country,
      });

      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record!.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('Sign up failed');
    }
  }

  Future<User> updateUser(String userId, String name, String phone,
      String address, String country) async {
    final pb = await getPocketBaseInstance();
    try {
      final record = await pb.collection('users').update(userId, body: {
        "name": name,
        "phone": phone,
        "address": address,
        "country": country,
      });
      return User.fromJson(record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('Update user failed');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketBaseInstance();
    try {
      // Xóa token xác thực
      pb.authStore.clear();
    } catch (error) {
      throw Exception('Logout failed');
    }
  }
}
