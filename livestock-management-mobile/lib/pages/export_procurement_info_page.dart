import 'package:flutter/material.dart';
import '../models/procurement_general_info_model.dart';
import '../services/procurement_general_info_service.dart';
import '../models/export_customer_model.dart';
import '../services/export_customer_service.dart';
import 'list_export_detail_page.dart';
import 'livestock_qr_scan_page.dart';

class ExportProcurementInfoPage extends StatefulWidget {
  final String procurementId;
  const ExportProcurementInfoPage({Key? key, required this.procurementId})
      : super(key: key);

  @override
  State<ExportProcurementInfoPage> createState() =>
      _ExportProcurementInfoPageState();
}

class _ExportProcurementInfoPageState extends State<ExportProcurementInfoPage> {
  ProcurementGeneralInfoModel? info;
  bool isLoading = true;
  String? error;
  List<ExportCustomerModel> customers = [];
  bool isLoadingCustomers = true;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _fetchCustomers();
  }

  Future<void> _fetchInfo() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final res = await ProcurementGeneralInfoService()
        .fetchGeneralInfo(widget.procurementId);
    if (res != null) {
      setState(() {
        info = res;
        isLoading = false;
      });
    } else {
      setState(() {
        error = 'Không lấy được thông tin gói thầu';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      isLoadingCustomers = true;
    });
    final res = await ExportCustomerService().fetchCustomers(
      procurementId: widget.procurementId,
      status: 'CHỜ_BÀN_GIAO',
      skip: 0,
      take: 20,
    );
    setState(() {
      customers = res;
      isLoadingCustomers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Thông tin gói thầu'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (info != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LivestockQrScanPage(
                                    mode: LivestockActionMode.handover,
                                    customerName: info!.owner,
                                    total: info!.totalRequired,
                                    received: null,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Xác nhận bàn giao',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Danh sách khách hàng',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),
                      ..._buildCustomerCards(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    if (info == null) return const SizedBox();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên gói thầu: ${info!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Bên gói thầu: ${info!.owner}'),
            Text('Mã gói thầu: ${info!.code}'),
            Text('Thời gian thực hiện: ${info!.expiredDuration} ngày'),
            if (info!.description.isNotEmpty)
              Text('Mô tả: ${info!.description}'),
            if (info!.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...info!.details.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value as Map<String, dynamic>;
                final weightRange = (e['requiredWeightMin'] != null &&
                        e['requiredWeightMax'] != null)
                    ? '${e['requiredWeightMin']} - ${e['requiredWeightMax']}'
                    : '';
                final ageRange =
                    (e['requiredAgeMin'] != null && e['requiredAgeMax'] != null)
                        ? '${e['requiredAgeMin']} - ${e['requiredAgeMax']}'
                        : '';
                final desc = (e['description'] ?? '').toString().isNotEmpty
                    ? e['description']
                    : 'không';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yêu cầu #${i + 1}:',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          'Loài: ${e['speciesName'] ?? ''}, Biểu cân: $weightRange, Số lượng: ${e['requiredQuantity'] ?? ''} con,'),
                      Text('Tuổi: $ageRange, Yêu cầu khác: $desc'),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomerCards() {
    if (isLoadingCustomers) {
      return [const Center(child: CircularProgressIndicator())];
    }
    if (customers.isEmpty) {
      return [
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: const Text('Không có khách hàng nào'),
          ),
        )
      ];
    }
    return customers
        .map((c) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Thông tin khách hàng
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text('SĐT: ${c.customerPhone}',
                              style: const TextStyle(fontSize: 14)),
                          Text('Địa chỉ: ${c.customerAddress}',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            'Tổng: ${c.total} | Còn lại: ${c.remaining}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                    // Nút danh sách vật nuôi
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ListExportDetailPage(customerId: c.id),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Danh sách vật nuôi'),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}
