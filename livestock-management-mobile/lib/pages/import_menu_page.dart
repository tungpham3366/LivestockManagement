import 'package:flutter/material.dart';
import 'import_page.dart';
import '../models/livestock_vaccination_model.dart';
import 'import_confirm_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

class ImportMenuPage extends StatelessWidget {
  const ImportMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập'),
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
                  MaterialPageRoute(builder: (_) => const ImportPage()),
                );
              },
              child: Container(
                color: Colors.grey.shade400,
                child: const Center(
                  child: Text(
                    'Lô nhập',
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
                    builder: (_) => const ImportConfirmPage(),
                  ),
                );
              },
              child: Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text(
                    'Xác nhận nhập',
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
