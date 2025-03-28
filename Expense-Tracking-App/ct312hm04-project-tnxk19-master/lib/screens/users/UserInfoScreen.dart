import 'package:ct312h_project/models/User.dart';
import 'package:ct312h_project/screens/users/LoginScreen.dart';
import 'package:ct312h_project/screens/users/register_screen.dart';
import 'package:ct312h_project/screens/users/update_user_screen.dart';
import 'package:ct312h_project/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UserInfoScreen extends StatelessWidget {
  final User user; // Nhận thông tin người dùng

  const UserInfoScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    void _logout() async {
      try {
        // Gọi phương thức đăng xuất từ AuthService
        await _authService.logout();

        // Điều hướng về LoginScreen và xóa toàn bộ stack điều hướng
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // Xóa tất cả các màn hình trước đó
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'logout error: ${error.toString().replaceFirst('Exception: ', '')}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Infomation'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            const Text(
              'User Infomation',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị thông tin người dùng
            _buildInfoField('Full name', user.name, CupertinoIcons.person),
            const SizedBox(height: 15),
            _buildInfoField('Email', user.email, CupertinoIcons.mail),
            const SizedBox(height: 15),
            _buildInfoField('Phone number', user.phone, CupertinoIcons.phone),
            const SizedBox(height: 15),
            _buildInfoField('Address', user.address, CupertinoIcons.house),
            const SizedBox(height: 15),
            _buildInfoField('Country', user.country, CupertinoIcons.globe),
            const SizedBox(height: 30),

            // Nút Cập nhật thông tin
            ElevatedButton(
              onPressed: () async {
                // Điều hướng đến UpdateScreen và chờ kết quả trả về
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateScreen(user: user),
                  ),
                );

                // Nếu có dữ liệu trả về, cập nhật thông tin người dùng
                if (updatedUser != null) {
                  // Điều hướng lại UserInfoScreen với thông tin mới
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfoScreen(user: updatedUser),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update Infomation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Nút Đăng xuất
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị một trường thông tin
  Widget _buildInfoField(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
