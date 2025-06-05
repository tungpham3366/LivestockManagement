import 'package:flutter/material.dart';
import '../models/export_confirm_model.dart';
import '../services/export_confirm_service.dart';
import '../models/confirm_export_detail.dart';
import 'confirm_export_detail.dart';

class ConfirmExportPage extends StatefulWidget {
  const ConfirmExportPage({Key? key}) : super(key: key);

  @override
  State<ConfirmExportPage> createState() => _ConfirmExportPageState();
}

class _ConfirmExportPageState extends State<ConfirmExportPage> {
  late Future<List<ExportConfirmModel>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = ExportConfirmService().fetchExportOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận xuất bán'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đơn lẻ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<ExportConfirmModel>>(
                future: _futureOrders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Không có đơn xuất trại nào.'));
                  }
                  final orders = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mã đơn: ${order.code}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Tên KH: ${order.customerName}'),
                                  const SizedBox(height: 2),
                                  Text('Tổng số con: ${order.total}'),
                                  const SizedBox(height: 2),
                                  Text('Số lượng sẽ xuất: ${order.received}'),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12.0, top: 8.0),
                              child: SizedBox(
                                width: 120,
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ConfirmExportDetail(
                                          detail: ConfirmExportDetailModel(
                                            id: order.id,
                                            code: order.code,
                                            customerName: order.customerName,
                                            total: order.total,
                                            received: order.received,
                                            exportCount: order
                                                .total, // hoặc giá trị phù hợp
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Xác nhận',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
