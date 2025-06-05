import 'package:flutter/material.dart';
import '../services/order_detail_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Map<String, dynamic>?> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = OrderDetailService().fetchOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Yêu cầu khách hàng'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Không lấy được dữ liệu!'));
          }
          final data = snapshot.data!;
          final details = data['details'] as List<dynamic>? ?? [];
          final customerName = data['customerName'] ?? '';
          final phoneNumber = data['phoneNumber'] ?? '';
          final address = data['address'] ?? '';
          final total = data['total']?.toString() ?? '';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Yêu cầu khách hàng',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 18),
                // Thông tin khách hàng
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text('Khách hàng: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Flexible(
                                child: Text(customerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text('SĐT: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(phoneNumber),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text('Địa chỉ: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Flexible(child: Text(address)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.list_alt,
                                size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text('Tổng số lượng: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(total),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, i) {
                      final req = details[i];
                      final String specieName =
                          req['specieName'] ?? req['species'] ?? 'N/A';
                      final String quantity = req['total']?.toString() ?? 'N/A';
                      String weightStr = 'N/A';
                      if (req['weightFrom'] != null &&
                          req['weightTo'] != null) {
                        weightStr =
                            '${req['weightFrom']} - ${req['weightTo']}(Kg)';
                      } else if (req['weightFrom'] != null) {
                        weightStr = '${req['weightFrom']}(Kg)';
                      } else if (req['weight'] != null) {
                        weightStr = '${req['weight']}(Kg)';
                      }
                      final String desc =
                          (req['description'] ?? req['otherRequirement'] ?? '')
                                  .toString()
                                  .isNotEmpty
                              ? (req['description'] ?? req['otherRequirement'])
                              : 'N/A';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yêu cầu ${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Loài Vật:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                Text(specieName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400)),
                                Text('Số lượng:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                Text('$quantity (con)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Cân nặng:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                Text(weightStr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Yêu cầu khác:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                Flexible(
                                    child: Text(desc,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
