import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livestock_mobile/pages/qr_info_layout_page.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/specie_service.dart';
import '../utils/specie_helper.dart';
import 'scan_history_page.dart';
import '../services/batch_import_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ImportBatchDetailPage extends StatefulWidget {
  final String batchImportId;
  const ImportBatchDetailPage({Key? key, required this.batchImportId})
      : super(key: key);

  @override
  State<ImportBatchDetailPage> createState() => _ImportBatchDetailPageState();
}

class _ImportBatchDetailPageState extends State<ImportBatchDetailPage> {
  late Future<Map<String, dynamic>> _futureDetail;
  String? _scannedLivestockId;
  bool _isScanning = false;
  List<String> _species = [];
  bool _isLoadingSpecies = true;
  String? _selectedSpecie;
  Map<String, int> _specieTypesMap = {};
  BatchImportService _batchImportService = BatchImportService();
  String? _userId;
  String? _inspectionCode;

  @override
  void initState() {
    super.initState();
    _futureDetail = _fetchDetail();
    _loadSpecies();
    _loadUserId();
  }

  Future<Map<String, dynamic>> _fetchDetail() async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/import-management/get-import-batch-details/${widget.batchImportId}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi lấy chi tiết lô nhập');
    }
  }

  Future<void> _loadSpecies() async {
    setState(() {
      _isLoadingSpecies = true;
    });
    final defaultSpecies = SpecieHelper.getDefaultSpecies();
    final defaultSpecieTypesMap = SpecieHelper.specieTypeMap;
    try {
      final specieService = SpecieService();
      final response = await specieService.getAllSpecies();
      if (response.success && response.data != null) {
        setState(() {
          _specieTypesMap = {};
          for (var specie in response.data!.specieList) {
            _specieTypesMap[specie.name] = specie.type;
          }
          _species = response.data!.items;
          _selectedSpecie = _species.isNotEmpty ? _species[0] : null;
          _isLoadingSpecies = false;
        });
      } else {
        setState(() {
          _species = defaultSpecies;
          _selectedSpecie = 'BÒ';
          _specieTypesMap = defaultSpecieTypesMap;
          _isLoadingSpecies = false;
        });
      }
    } catch (e) {
      setState(() {
        _species = defaultSpecies;
        _selectedSpecie = 'BÒ';
        _specieTypesMap = defaultSpecieTypesMap;
        _isLoadingSpecies = false;
      });
      print('Lỗi khi tải danh sách loài:  {e.toString()}');
    }
  }

  Future<void> _loadUserId() async {
    final userId = await _batchImportService.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  void _openQrScanner() async {
    setState(() => _isScanning = true);
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 300,
          height: 400,
          child: MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final code = barcode.rawValue;
                if (code != null && code.startsWith('https://www.lms.com/')) {
                  final livestockId = code.split('/').last;
                  setState(() {
                    _scannedLivestockId = livestockId;
                    _isScanning = false;
                  });
                  Navigator.of(context).pop();
                  _processQrCode(code);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
    setState(() => _isScanning = false);
  }

  void _processQrCode(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrInfoLayoutPage(
          code: code,
          specie: _selectedSpecie ?? '',
          specieId: _specieTypesMap[_selectedSpecie] ?? 0,
          batchImportId: widget.batchImportId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn loài vật cho các lô nhập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử quét',
            onPressed: () async {
              if (_userId == null) {
                final userId = await _batchImportService.getUserId();
                if (userId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanHistoryPage(userId: userId),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanHistoryPage(userId: _userId!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final data = snapshot.data?['data'];
          if (data == null)
            return const Center(child: Text('Không có dữ liệu'));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên lô nhập: ${data['name']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                    'Số lượng vật nuôi đã chọn: ${data['importedQuantity']} / ${data['estimatedQuantity']}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _openQrScanner,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _scannedLivestockId == null
                          ? const Icon(Icons.camera_alt, size: 100)
                          : const Icon(Icons.check_circle,
                              size: 100, color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Loại loài vật: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isLoadingSpecies
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButton<String>(
                              value: _selectedSpecie,
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSpecie = newValue;
                                });
                              },
                              items: _species.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
                // Thêm các thông tin khác nếu cần
              ],
            ),
          );
        },
      ),
    );
  }
}
