import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, AppRoutes.importMenu);
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, AppRoutes.exportMenu);
        } else if (index == 3) {
          showLogoutDialog(context);
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Tiêm chủng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.input),
          label: 'Nhập',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.output),
          label: 'Xuất',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
