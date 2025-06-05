import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class ScanHistoryPage extends StatefulWidget {
  final String userId;
  const ScanHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late Future<List<dynamic>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = _fetchHistory();
  }

  Future<List<dynamic>> _fetchHistory() async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/import-management/get-list-search-history/${widget.userId}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']?['items'] ?? [];
    } else {
      throw Exception('Lỗi lấy lịch sử quét');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      // Lấy phần ngày giờ trước dấu /
      final mainPart = dateStr.split('/').first;
      final date = DateTime.parse(mainPart);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} [${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}]';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử quét xác nhận')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Không có dữ liệu lịch sử'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.qr_code,
                              size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(_formatDate(item['createAt']),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Mã kiểm dịch: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['inspectionCode'] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Loài vật: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['specieName'] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Tiêm: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          item['medicineId'] != null
                              ? const Icon(Icons.check, color: Colors.green)
                              : const SizedBox(width: 16),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Giới tính: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['gender'] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Màu lông: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['color'] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Cân nặng: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['weight']?.toString() ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Ngày sinh: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['dob'] ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
