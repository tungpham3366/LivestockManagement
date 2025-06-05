import 'package:flutter/material.dart';
import '../services/batch_vaccination_service.dart';
import '../models/batch_vaccination_model.dart';
import 'qr_scanner_confirm_page.dart';

class VaccinationsListPage extends StatefulWidget {
  const VaccinationsListPage({Key? key}) : super(key: key);

  @override
  State<VaccinationsListPage> createState() => _VaccinationsListPageState();
}

class _VaccinationsListPageState extends State<VaccinationsListPage> {
  final BatchVaccinationService _service = BatchVaccinationService();
  List<BatchVaccination> _batches = [];
  bool _loading = true;
  int _skip = 0;
  int _take = 5;
  int _total = 0;
  DateTime? _fromDate;
  DateTime? _toDate;
  final List<int> _takeOptions = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    setState(() => _loading = true);
    try {
      final batches = await _service.getBatchVaccinations(
        skip: _skip,
        take: _take,
        fromDate: _fromDate != null ? _fromDate!.toIso8601String() : null,
        toDate: _toDate != null ? _toDate!.toIso8601String() : null,
      );
      // Lấy tổng số từ API nếu có, ở đây giả sử service trả về total
      // Nếu muốn lấy total thực tế, cần sửa service trả về cả total
      setState(() {
        _batches = batches;
        _loading = false;
        // _total = total; // Nếu có
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách lô tiêm: $e')),
      );
    }
  }

  void _changePage(int delta) {
    setState(() {
      _skip = (_skip + delta * _take).clamp(0, 10000); // Giới hạn skip
    });
    _fetchBatches();
  }

  void _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
      _skip = 0;
      _fetchBatches();
    }
  }

  void _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
      _skip = 0;
      _fetchBatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = (_skip / _take).floor() + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách các lô tiêm'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickFromDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Từ ngày',
                                hintText: 'Chọn ngày bắt đầu',
                                suffixIcon: const Icon(Icons.date_range),
                              ),
                              controller: TextEditingController(
                                text: _fromDate != null
                                    ? _fromDate!.toString().substring(0, 10)
                                    : '',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickToDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Đến ngày',
                                hintText: 'Chọn ngày kết thúc',
                                suffixIcon: const Icon(Icons.date_range),
                              ),
                              controller: TextEditingController(
                                text: _toDate != null
                                    ? _toDate!.toString().substring(0, 10)
                                    : '',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<int>(
                          value: _take,
                          decoration:
                              const InputDecoration(labelText: 'Số dòng'),
                          items: _takeOptions
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _take = value;
                                _skip = 0;
                              });
                              _fetchBatches();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _batches.length,
                    itemBuilder: (context, index) {
                      final batch = _batches[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(batch.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: batch.status == 'HOÀN_THÀNH'
                                          ? Colors.green[100]
                                          : batch.status == 'ĐÃ_HỦY'
                                              ? Colors.red[100]
                                              : Colors.yellow[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(batch.status,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Thuốc: ${batch.medcicalType}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              Text('Triệu chứng: ${batch.symptom}'),
                              Text(
                                'Lịch tiêm: ${batch.dateSchedule.substring(0, 10)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                              Text(
                                'Thực hiện: ${batch.dateConduct != null ? batch.dateConduct!.substring(0, 10) : 'Chưa thực hiện'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            QrScannerConfirmPage(
                                          procurementId: batch.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 32),
                      onPressed: _skip == 0 ? null : () => _changePage(-1),
                    ),
                    Text('Trang $page',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 32),
                      onPressed: () => _changePage(1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }
}
