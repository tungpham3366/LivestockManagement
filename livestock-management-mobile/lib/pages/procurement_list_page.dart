import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/procurement_model.dart';
import '../services/procurement_service.dart';
import '../widgets/error_dialog.dart';
import '../routes/app_routes.dart';

class ProcurementListPage extends StatefulWidget {
  const ProcurementListPage({Key? key}) : super(key: key);

  @override
  State<ProcurementListPage> createState() => _ProcurementListPageState();
}

class _ProcurementListPageState extends State<ProcurementListPage> {
  final _procurementService = ProcurementService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<ProcurementItem> _procurementList = [];

  @override
  void initState() {
    super.initState();
    _loadProcurements();
  }

  Future<void> _loadProcurements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _procurementService.getProcurementList();

      if (response.success) {
        setState(() {
          _procurementList = response.data ?? [];
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

  void _navigateToDetail(String procurementId) {
    Navigator.pushNamed(
      context,
      AppRoutes.procurementDetail,
      arguments: procurementId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Các lô xuất của gói thầu chưa đảm bảo yêu cầu tiêm chủng',
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
                        onPressed: _loadProcurements,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _procurementList.isEmpty
                  ? const Center(child: Text('Không có dữ liệu gói thầu'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _procurementList.length,
                      itemBuilder: (context, index) {
                        final item = _procurementList[index];
                        return _buildProcurementCard(item);
                      },
                    ),
    );
  }

  Widget _buildProcurementCard(ProcurementItem item) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(item.procurementId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gói thầu ${item.procurementCode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text('Số lượng: ${item.livestockQuantity} con'),
              const SizedBox(height: 4),
              Text(
                item.livestockQuantity > 0
                    ? 'Ngày hết hạn: ${dateFormat.format(item.expirationDate)}'
                    : 'Hoàn thành',
                style: TextStyle(
                  color: item.livestockQuantity > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (item.diseaseRequires.isNotEmpty) const SizedBox(height: 16),
              ...item.diseaseRequires
                  .map((disease) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(disease.diseaseName),
                          const SizedBox(height: 4),
                          _buildProgressBar(
                            disease.hasDone.toDouble(),
                            item.livestockQuantity.toDouble(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value, double max) {
    final progress = max > 0 ? value / max : 0.0;

    // Ánh xạ màu theo tiến độ
    Color getColorByProgress(double progress) {
      if (progress >= 0.8) return Colors.green; // Hoàn thành >80%
      if (progress >= 0.5) return Colors.lightGreen; // Hoàn thành 50-80%
      if (progress >= 0.3) return Colors.yellow; // Hoàn thành 30-50%
      if (progress >= 0.1) return Colors.orange; // Hoàn thành 10-30%
      return Colors.red; // Hoàn thành <10%
    }

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              // Progress
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
        // Percent text
        Text(
          (value).toStringAsFixed(0),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
