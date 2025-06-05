import 'package:flutter/material.dart';
import '../services/export_choose_service.dart';
import '../models/export_choose_model.dart';
import 'export_choose_scan_page.dart';
import 'export_procurement_info_page.dart';

class ExportChoosePage extends StatefulWidget {
  const ExportChoosePage({Key? key}) : super(key: key);

  @override
  State<ExportChoosePage> createState() => _ExportChoosePageState();
}

class _ExportChoosePageState extends State<ExportChoosePage> {
  final ExportChooseService _service = ExportChooseService();
  late Future<List<ExportOrderModel>> _ordersFuture;
  late Future<List<ExportProcurementModel>> _procurementsFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _service.fetchOrders();
    _procurementsFuture = _service.fetchProcurements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Các đơn cần chọn'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGroupSection(
              'Đơn lẻ',
              FutureBuilder<List<ExportOrderModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 160,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Lỗi: \\${snapshot.error}',
                            style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  }
                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Không có đơn lẻ nào',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 8, right: 16),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(order: order);
                      },
                    ),
                  );
                },
              ),
            ),
            _buildGroupSection(
              'Gói thầu',
              FutureBuilder<List<ExportProcurementModel>>(
                future: _procurementsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 160,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Lỗi: \\${snapshot.error}',
                            style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  }
                  final procurements = snapshot.data ?? [];
                  if (procurements.isEmpty) {
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Không có gói thầu nào',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 8, right: 16),
                      itemCount: procurements.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final p = procurements[index];
                        return _ProcurementCard(procurement: p);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ExportOrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng: ${order.total} con',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(order.customerName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportChooseScanPage(
                      orderId: order.id,
                      customerName: order.customerName,
                      total: order.total,
                      received: order.received,
                      code: order.code,
                    ),
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcurementCard extends StatelessWidget {
  final ExportProcurementModel procurement;
  const _ProcurementCard({required this.procurement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng: ${procurement.handoverInformation?.totalCount ?? 0} con',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(procurement.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportProcurementInfoPage(
                        procurementId: procurement.id),
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}
