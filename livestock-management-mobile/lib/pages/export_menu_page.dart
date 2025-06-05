import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'export_choose_page.dart';
import 'confirm_export_page.dart';
// TODO: Tạo các trang ExportScanPage và ExportConfirmPage tương ứng
// import 'export_scan_page.dart';
// import 'export_confirm_page.dart';

class ExportMenuPage extends StatelessWidget {
  const ExportMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportChoosePage()),
                );
              },
              child: Container(
                color: Colors.grey.shade400,
                child: const Center(
                  child: Text(
                    'Quét chọn loài vật theo đơn lẻ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfirmExportPage(),
                  ),
                );
              },
              child: Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text(
                    'Xác nhận loài vật xuất trại',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: _selectedIndex),
    );
  }
}
