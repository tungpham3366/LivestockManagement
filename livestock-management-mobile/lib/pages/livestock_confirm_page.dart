import 'package:flutter/material.dart';
import 'livestock_qr_scan_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/livestock_summary_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/export_detail_service.dart';
import 'list_export_detail_page.dart';
import 'export_procurement_info_page.dart';

class LivestockConfirmPage extends StatelessWidget {
  final LivestockActionMode mode;
  final LivestockSummaryModel livestock;
  final String? customerName;
  final int? total;
  final int? received;
  final String? batchExportId;
  final String? batchExportDetailId;

  const LivestockConfirmPage({
    Key? key,
    required this.mode,
    required this.livestock,
    this.customerName,
    this.total,
    this.received,
    this.batchExportId,
    this.batchExportDetailId,
  }) : super(key: key);

  String get _confirmText {
    switch (mode) {
      case LivestockActionMode.add:
        return 'Thêm mới';
      case LivestockActionMode.replace:
        return 'Xác nhận đổi';
      case LivestockActionMode.handover:
        return 'Bàn giao';
    }
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final userMap = jsonDecode(userData);
      return userMap['id'] as String?;
    }
    return null;
  }

  void _handleConfirm(BuildContext context) async {
    final userId = await _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Không tìm thấy userId')));
      Navigator.pop(context);
      return;
    }
    final service = ExportDetailService();
    try {
      if (mode == LivestockActionMode.add) {
        final res = await service.addLivestockToBatchExportDetail(
          batchExportId: batchExportId!,
          livestockId: livestock.id,
          expiredInsuranceDate: DateTime.now().toIso8601String(),
          createdBy: userId,
        );
        if (res['success'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thêm mới thành công!')));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      ListExportDetailPage(customerId: batchExportId!)),
              (route) => route.isFirst,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Lỗi thêm mới!')));
            Navigator.of(context).pop();
          }
        }
      } else if (mode == LivestockActionMode.replace) {
        final res = await service.changeLivestockToBatchExportDetail(
          batchExportDetailId: batchExportDetailId!,
          batchExportId: batchExportId!,
          livestockId: livestock.id,
          updatedBy: userId,
        );
        if (res['success'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi vật nuôi thành công!')));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      ListExportDetailPage(customerId: batchExportId!)),
              (route) => route.isFirst,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Lỗi đổi vật nuôi!')));
            Navigator.of(context).pop();
          }
        }
      } else if (mode == LivestockActionMode.handover) {
        final res = await service.confirmHandoverBatchExportDetail(
          batchExportDetailId: batchExportDetailId!,
          userId: userId,
        );
        if (res['success'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bàn giao thành công!')));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      ExportProcurementInfoPage(procurementId: batchExportId!)),
              (route) => route.isFirst,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Lỗi bàn giao!')));
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Thông tin loài vật',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: StadiumBorder(),
                side: BorderSide(color: Color(0xFFD1B3FF)),
                foregroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Quét lại'),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFD1B3FF), width: 1.2),
              ),
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.08),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      livestock.id,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: 'https://www.lms.com/${livestock.id}',
                      version: QrVersions.auto,
                      size: 150,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loài Vật: ${livestock.species}',
                              style: _infoStyle),
                          Text('Trạng thái: ${livestock.status}',
                              style: _infoStyle),
                          Text('Cân nặng: ${livestock.weight} (Kg)',
                              style: _infoStyle),
                          Text('Giới tính: ${livestock.gender}',
                              style: _infoStyle),
                          Text('Màu lông: ${livestock.color}',
                              style: _infoStyle),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (total != null && received != null)
                      Text(
                        'Số lượng vật nuôi đã chọn: $received / $total',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: Color(0xFFD1B3FF)),
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEDE7F6),
                              foregroundColor: Colors.deepPurple,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 0,
                            ),
                            onPressed: () => _handleConfirm(context),
                            child: Text(_confirmText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle _infoStyle = TextStyle(
    fontSize: 15,
    color: Colors.black87,
    height: 1.5,
  );
}
