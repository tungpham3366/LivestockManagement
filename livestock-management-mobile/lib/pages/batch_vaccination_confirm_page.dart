import 'package:flutter/material.dart';
import '../models/livestock_info_model.dart';
import '../services/livestock_service.dart';

class BatchVaccinationConfirmPage extends StatefulWidget {
  final LivestockInfo livestockInfo;
  final String procurementId;
  final bool isQrScan;

  const BatchVaccinationConfirmPage({
    Key? key,
    required this.livestockInfo,
    required this.procurementId,
    required this.isQrScan,
  }) : super(key: key);

  @override
  State<BatchVaccinationConfirmPage> createState() =>
      _BatchVaccinationConfirmPageState();
}

class _BatchVaccinationConfirmPageState
    extends State<BatchVaccinationConfirmPage> {
  bool _isProcessing = false;
  final LivestockService _livestockService = LivestockService();

  Future<void> _confirmVaccination() async {
    setState(() => _isProcessing = true);

    try {
      final Map<String, dynamic> result =
          await _livestockService.confirmVaccination(
        widget.livestockInfo.livestockId,
        widget.procurementId,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xác nhận tiêm thành công!')),
          );
          Navigator.of(context).pop(); // Về lại trang trước
        } else {
          String errorMessage = result['data'] as String? ??
              'Xác nhận tiêm không thành công. Vui lòng thử lại.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận tiêm vật nuôi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin vật nuôi
            _buildInfoRow('Mã thẻ tai:', widget.livestockInfo.inspectionCode),
            _buildInfoRow('Giống:', widget.livestockInfo.specieName),
            _buildInfoRow('Màu lông:', widget.livestockInfo.color),

            const SizedBox(height: 16),

            // Tiêu đề lịch sử tiêm chủng
            const Text('Lịch sử tiêm chủng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Lịch sử tiêm chủng
            widget.livestockInfo.vaccinationInfos.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.livestockInfo.vaccinationInfos.length,
                    itemBuilder: (context, index) {
                      final info = widget.livestockInfo.vaccinationInfos[index];
                      return _buildVaccinationHistoryCard(info.diseaseName,
                          'Thuốc ${info.numberOfVaccination}');
                    },
                  )
                : Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text(
                            'Hiện không có lịch sử nào được ghi nhận',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 24),

            // Nút hủy và xác nhận
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 45,
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmVaccination,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
                text: label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' '),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationHistoryCard(String disease, String medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bệnh:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(disease),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thuốc:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(medicine),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
