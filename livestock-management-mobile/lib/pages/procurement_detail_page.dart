import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/procurement_model.dart';
import '../services/procurement_service.dart';
import '../widgets/error_dialog.dart';
import '../routes/app_routes.dart';
import 'qr_scanner_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

class ProcurementDetailPage extends StatefulWidget {
  final String procurementId;

  const ProcurementDetailPage({
    Key? key,
    required this.procurementId,
  }) : super(key: key);

  @override
  State<ProcurementDetailPage> createState() => _ProcurementDetailPageState();
}

class _ProcurementDetailPageState extends State<ProcurementDetailPage> {
  final _procurementService = ProcurementService();
  bool _isLoading = true;
  String _errorMessage = '';
  ProcurementDetail? _procurementDetail;

  @override
  void initState() {
    super.initState();
    _loadProcurementDetail();
  }

  Future<void> _loadProcurementDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response =
          await _procurementService.getProcurementDetail(widget.procurementId);

      if (response.success) {
        setState(() {
          _procurementDetail = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToQrScanner() {
    print(
        'ProcurementDetailPage - Chuyển đến QrScannerPage với procurementId: ${widget.procurementId}');

    // Đảm bảo procurementId không trống
    final String procId = widget.procurementId.trim();
    if (procId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: ProcurementId trống'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScannerPage(procurementId: procId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin về việc tiêm chủng của lô xuất trong gói thầu',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProcurementDetail,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _procurementDetail == null
                  ? const Center(
                      child: Text('Không có dữ liệu chi tiết gói thầu'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildDetailContent(),
                    ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildDetailContent() {
    if (_procurementDetail == null) return const SizedBox();

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        if (_procurementDetail!.diseaseRequiresForSpecie.isNotEmpty)
          ..._buildDiseaseCards(),
        if (_procurementDetail!.diseaseRequiresForSpecie.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'Không có dữ liệu yêu cầu tiêm chủng',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Gói thầu ${_procurementDetail!.procurementCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _navigateToQrScanner,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Tra cứu thông tin cần tiêm vật'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tổng số lượng: ${_procurementDetail!.livestockQuantity} con'),
            const SizedBox(height: 8),
            Text(
              _procurementDetail!.livestockQuantity > 0
                  ? 'Hạn hoàn thành: ${dateFormat.format(_procurementDetail!.expirationDate)}'
                  : 'Đã hoàn thành',
              style: TextStyle(
                color: _procurementDetail!.livestockQuantity > 0
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDiseaseCards() {
    // Nhóm các bệnh theo tên để hiển thị cùng nhau
    Map<String, List<DiseaseRequire>> groupedDiseases = {};

    for (var disease in _procurementDetail!.diseaseRequiresForSpecie) {
      if (groupedDiseases.containsKey(disease.diseaseName)) {
        groupedDiseases[disease.diseaseName]!.add(disease);
      } else {
        groupedDiseases[disease.diseaseName] = [disease];
      }
    }

    List<Widget> cards = [];

    cards.add(
      const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Yêu cầu tiêm chủng:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );

    groupedDiseases.forEach((diseaseName, diseaseList) {
      cards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Text(
                  diseaseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ...diseaseList
                  .map((disease) => _buildDiseaseItem(disease))
                  .toList(),
            ],
          ),
        ),
      );
    });

    return cards;
  }

  Widget _buildDiseaseItem(DiseaseRequire disease) {
    // Tính tiến độ hoàn thành
    double progress =
        disease.totalQuantity > 0 ? disease.hasDone / disease.totalQuantity : 0;

    // Ánh xạ màu theo tiến độ
    Color getColorByProgress(double progress) {
      if (progress >= 0.8) return Colors.green; // Hoàn thành >80%
      if (progress >= 0.5) return Colors.lightGreen; // Hoàn thành 50-80%
      if (progress >= 0.3) return Colors.yellow; // Hoàn thành 30-50%
      if (progress >= 0.1) return Colors.orange; // Hoàn thành 10-30%
      return Colors.red; // Hoàn thành <10%
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  disease.specieName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                disease.medicineName != 'N/A' ? disease.medicineName : '',
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: getColorByProgress(progress),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${disease.hasDone}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
