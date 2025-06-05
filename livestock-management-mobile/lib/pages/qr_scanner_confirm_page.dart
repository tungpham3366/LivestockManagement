import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/specie_service.dart';
import '../models/specie_model.dart';
import '../utils/specie_helper.dart';
import '../services/livestock_info_service.dart';
import '../models/livestock_info_model.dart';
import 'batch_vaccination_confirm_page.dart';

class QrScannerConfirmPage extends StatefulWidget {
  final String procurementId;
  const QrScannerConfirmPage({Key? key, required this.procurementId})
      : super(key: key);

  @override
  State<QrScannerConfirmPage> createState() => _QrScannerConfirmPageState();
}

class _QrScannerConfirmPageState extends State<QrScannerConfirmPage> {
  final TextEditingController _tagController = TextEditingController();
  bool _isScanning = false;
  String? _scannedLivestockId;
  List<String> _species = [];
  bool _isLoadingSpecies = true;
  String? _selectedSpecie;
  Map<String, int> _specieTypesMap = {};

  @override
  void initState() {
    super.initState();
    _loadSpecies();
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
      print('Lỗi khi tải danh sách loài: \\${e.toString()}');
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.startsWith('https://www.lms.com/')) {
        final livestockId = code.split('/').last;
        setState(() {
          _scannedLivestockId = livestockId;
          _tagController.text = livestockId;
        });
        _processContinue(isQrScan: true);
        break;
      }
    }
    setState(() => _isScanning = false);
  }

  Future<void> _processContinue({bool isQrScan = false}) async {
    if (_tagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã thẻ tai!')),
      );
      return;
    }
    if (_selectedSpecie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loài!')),
      );
      return;
    }

    try {
      setState(() => _isScanning = true);
      final specieType = _specieTypesMap[_selectedSpecie] ?? 0;

      final livestockInfo = await LivestockInfoService().getLivestockInfo(
        livestockId: isQrScan ? _scannedLivestockId : null,
        inspectionCode: isQrScan ? null : _tagController.text.trim(),
        specieType: specieType,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BatchVaccinationConfirmPage(
            livestockInfo: livestockInfo,
            procurementId: widget.procurementId,
            isQrScan: isQrScan,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR ghi nhận tiêm'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: _scannedLivestockId == null
                      ? MobileScanner(
                          onDetect: _onDetect,
                        )
                      : const Center(
                          child: Icon(Icons.check_circle,
                              size: 100, color: Colors.green)),
                ),
                const SizedBox(height: 24),
                const Text('Nhập mã thẻ tai trên thẻ nhận vật nuôi'),
                const SizedBox(height: 8),
                TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nhập mã thẻ tai',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Loài: '),
                    const SizedBox(width: 8),
                    _isLoadingSpecies
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButton<String>(
                            value: _selectedSpecie,
                            items: _species
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedSpecie = value);
                            },
                          ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _processContinue(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Tiếp tục',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
