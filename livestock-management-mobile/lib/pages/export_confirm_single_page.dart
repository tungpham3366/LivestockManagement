import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/livestock_summary_model.dart';
import 'order_detail_page.dart';
import '../services/order_livestock_service.dart';

class ExportConfirmSinglePage extends StatelessWidget {
  final LivestockSummaryModel summary;
  final String? customerName;
  final String? code;
  final int? total;
  final int? received;
  final String? orderId;
  const ExportConfirmSinglePage({
    Key? key,
    required this.summary,
    this.customerName,
    this.code,
    this.total,
    this.received,
    this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: const Text('Chọn loài vật cho đơn bán lẻ'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (customerName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('Khách hàng: $customerName',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    Spacer(),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: (orderId != null && orderId!.isNotEmpty)
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OrderDetailPage(orderId: orderId!),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Không tìm thấy mã đơn hàng!')),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF7B61FF), width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 0),
                        ),
                        child: const Text('Yêu Cầu',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF7B61FF),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                if (code != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text('Mã đơn: $code',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                            fontSize: 16)),
                  ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.13),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Thông tin loài vật',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 10),
                      Text(summary.inspectionCode,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 10),
                      Center(
                        child: QrImageView(
                          data: summary.inspectionCode,
                          version: QrVersions.auto,
                          size: 140,
                          gapless: false,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _infoRow('Loài vật:', summary.species),
                      _infoRow('Trạng thái:', summary.status),
                      _infoRow('Cân nặng:', '${summary.weight} (Kg)'),
                      _infoRow('Giới tính:', summary.gender),
                      _infoRow('Màu lông:', summary.color),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (total != null && received != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Số lượng vật nuôi đã chọn: $received / $total',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.deepOrange,
                            fontSize: 17)),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF7B61FF), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Quét lại',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7B61FF),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (orderId == null || orderId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Không tìm thấy mã đơn hàng!')),
                              );
                              return;
                            }
                            final service = OrderLivestockService();
                            final result = await service.addLivestockToOrder(
                              orderId: orderId!,
                              livestockId: summary.id,
                            );
                            if (!context.mounted) return;
                            if (result['success'] == true) {
                              Navigator.pop(
                                  context); // pop ExportConfirmSinglePage
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(result['message'] ??
                                        'Thêm vật nuôi thất bại!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Chọn'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15))),
        ],
      ),
    );
  }
}
