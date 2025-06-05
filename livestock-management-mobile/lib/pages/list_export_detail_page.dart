import 'package:flutter/material.dart';
import '../models/export_detail_model.dart';
import '../services/export_detail_service.dart';
import 'livestock_qr_scan_page.dart';

class ListExportDetailPage extends StatefulWidget {
  final String customerId;
  const ListExportDetailPage({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<ListExportDetailPage> createState() => _ListExportDetailPageState();
}

class _ListExportDetailPageState extends State<ListExportDetailPage> {
  ExportDetailListModel? detail;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final res =
        await ExportDetailService().fetchExportDetails(widget.customerId);
    if (res != null) {
      setState(() {
        detail = res;
        isLoading = false;
      });
    } else {
      setState(() {
        error = 'Không lấy được dữ liệu vật nuôi';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vật nuôi đã chọn'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detail != null) ...[
                        Text('Tên khách hàng: ${detail!.customerName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Số lượng: ${detail!.totalLivestocks}'),
                        Text('Đã nhận: ${detail!.received}'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LivestockQrScanPage(
                                    mode: LivestockActionMode.add,
                                    customerName: detail!.customerName,
                                    total: detail!.totalLivestocks,
                                    received: detail!.received,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Thêm mới'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (detail!.items.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Không có vật nuôi nào.'),
                            ),
                          )
                        else
                          ...detail!.items
                              .map((e) => _buildLivestockCard(e))
                              .toList(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildLivestockCard(ExportDetailModel e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã thẻ tai: ${e.inspectionCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Trọng lượng xuất: ${e.weightExport?.toString() ?? '-'}'),
                  Text('Ngày chọn: ${_formatDate(e.exportDate)}'),
                  Text('Ngày bàn giao: ${_formatDate(e.handoverDate)}'),
                  Text(
                      'Ngày hết bảo hành: ${_formatDate(e.expiredInsuranceDate)}'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LivestockQrScanPage(
                      mode: LivestockActionMode.replace,
                      customerName: detail!.customerName,
                      total: detail!.totalLivestocks,
                      received: detail!.received,
                    ),
                  ),
                );
              },
              child: const Text('Đổi'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
