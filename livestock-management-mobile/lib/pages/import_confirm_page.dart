import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/specie_service.dart';
import '../models/specie_model.dart';
import '../services/import_management_service.dart';
import '../services/livestock_management_service.dart';
import 'import_livestock_info_page.dart';

class ImportConfirmPage extends StatefulWidget {
  const ImportConfirmPage({Key? key}) : super(key: key);

  @override
  State<ImportConfirmPage> createState() => _ImportConfirmPageState();
}

class _ImportConfirmPageState extends State<ImportConfirmPage> {
  final SpecieService _specieService = SpecieService();
  final ImportManagementService _importService = ImportManagementService();
  final LivestockManagementService _livestockService =
      LivestockManagementService();
  List<Specie> _species = [];
  Specie? _selectedSpecie;
  bool _isLoading = true;
  String _inspectionCode = '';
  bool _isReplacement = false;
  String? _livestockId;
  bool _isScanning = true;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
  }

  Future<void> _fetchSpecies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _specieService.getAllSpecies();
      setState(() {
        _species = response.data?.specieList ?? [];
        if (_species.isNotEmpty) {
          _selectedSpecie = _species.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy danh sách loài vật: ' + e.toString())),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _livestockId = code.split('/').last;
          _isScanning = false;
        });
        _scannerController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã quét livestockId: $_livestockId')),
        );
        break;
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR xác nhận nhập loài vật'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: 260,
                        width: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isScanning
                            ? MobileScanner(
                                controller: _scannerController,
                                onDetect: _onDetect,
                              )
                            : (_livestockId != null
                                ? Center(
                                    child: Icon(Icons.check_circle,
                                        size: 56, color: Colors.green),
                                  )
                                : Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt,
                                          size: 56),
                                      onPressed: () {
                                        setState(() {
                                          _isScanning = true;
                                          _scannerController.start();
                                        });
                                      },
                                    ),
                                  )),
                      ),
                    ),
                    if (_livestockId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mã QR: $_livestockId',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Input mã thẻ tai
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Nhập mã thẻ tai',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _inspectionCode = value;
                          });
                        },
                      ),
                    ),
                    // Dropdown loài vật

                    const SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: DropdownButtonFormField<Specie>(
                        value: _selectedSpecie,
                        items: _species
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecie = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nút tìm
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          String? livestockId;
                          if (_livestockId != null) {
                            livestockId = _livestockId;
                          } else if (_inspectionCode.isNotEmpty &&
                              _selectedSpecie != null) {
                            livestockId = await _livestockService
                                .getLivestockIdByInspectionCodeAndType(
                                    _inspectionCode, _selectedSpecie!.type);
                          }
                          if (livestockId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Không tìm thấy vật nuôi với mã thẻ tai và loài đã chọn!')),
                            );
                            return;
                          }
                          final data = await _importService
                              .getBatchImportLivestockScanInfo(livestockId);
                          if (data == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Không lấy được thông tin vật nuôi!')),
                            );
                            return;
                          }
                          if (_selectedSpecie != null) {
                            data['specieId'] = _selectedSpecie!.type;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImportLivestockInfoPage(
                                data: data,
                                isReplacement: _isReplacement,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('Tìm',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: _isReplacement,
                          onChanged: (value) {
                            setState(() {
                              _isReplacement = value ?? false;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isReplacement = !_isReplacement;
                            });
                          },
                          child: const Text('Con thay thế'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
