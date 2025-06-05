import 'package:flutter/material.dart';
import '../models/confirm_export_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/export_confirm_service.dart';
import 'confirm_export_page.dart';
import 'dart:convert';

class ConfirmExportDetail extends StatelessWidget {
  final ConfirmExportDetailModel detail;
  const ConfirmExportDetail({Key? key, required this.detail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Đơn lẻ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Mã Đơn: ',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(detail.code,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Khách hàng: ',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(detail.customerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Tổng số lượng loài vật trong đơn:  ',
                            style: TextStyle()),
                        Text('${detail.total} con',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Tổng số lượng loài vật đã xuất bán:  ',
                            style: TextStyle()),
                        Text('${detail.received} con',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                        child: Text('Số lượng xuất trong đơn',
                            style: TextStyle(fontSize: 18))),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${detail.exportCount} con',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      side: const BorderSide(color: Colors.black54),
                    ),
                    child:
                        const Text('Quay lại', style: TextStyle(fontSize: 16)),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xuất bán'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã Đơn: ${detail.code}'),
                              Text('Khách hàng: ${detail.customerName}'),
                              Text(
                                  'Tổng số lượng trong đơn: ${detail.total} con'),
                              Text('Đã xuất bán: ${detail.received} con'),
                              Text(
                                  'Số lượng xuất lần này: ${detail.exportCount} con'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Huỷ'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final userData = prefs.getString('user_data');
                                String? userId;
                                if (userData != null) {
                                  final userMap = jsonDecode(userData);
                                  userId = userMap['id'] as String?;
                                }
                                if (userId == null) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Lỗi'),
                                      content:
                                          const Text('Không tìm thấy userId!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                final orderId = detail.id;
                                try {
                                  final result = await ExportConfirmService()
                                      .confirmExported(orderId, userId);
                                  if (result) {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Thành công'),
                                          content: const Text(
                                              'Xác nhận xuất trại thành công!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const ConfirmExportPage()),
                                                  (route) => false,
                                                );
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Lỗi'),
                                        content: Text('Lỗi: ${e.toString()}'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Đóng'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      side: const BorderSide(color: Colors.blue),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Xác nhận',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
