import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiêm chủng'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: _buildTiemChungOption(
              'Tiêm đảm bảo yêu cầu gói thầu',
              Colors.grey.shade400,
              () {
                Navigator.pushNamed(context, AppRoutes.procurementList);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildTiemChungOption(
              'Tiêm đơn lẻ',
              Colors.grey.shade200,
              () {
                Navigator.pushNamed(context, AppRoutes.singleVaccination);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildTiemChungOption(
              'Tiêm theo lô',
              Colors.white,
              () {
                Navigator.pushNamed(context, AppRoutes.vaccinationsList);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: _selectedIndex),
    );
  }

  Widget _buildTiemChungOption(
      String title, Color backgroundColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: title == 'Tiêm đảm bảo yêu cầu gói thầu'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
}
