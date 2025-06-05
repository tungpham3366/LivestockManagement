import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/specie_service.dart';
import '../models/specie_model.dart';
import 'livestock_confirm_page.dart';
import '../services/livestock_general_info_service.dart';
import '../services/livestock_summary_service.dart';
import '../models/livestock_summary_model.dart';

enum LivestockActionMode { add, replace, handover }

class LivestockQrScanPage extends StatefulWidget {
  final LivestockActionMode mode;
  final String? customerName;
  final int? total;
  final int? received;
  final String? batchExportId;
  final String? batchExportDetailId;
  const LivestockQrScanPage({
    Key? key,
    required this.mode,
    this.customerName,
    this.total,
    this.received,
    this.batchExportId,
    this.batchExportDetailId,
  }) : super(key: key);

  @override
  State<LivestockQrScanPage> createState() => _LivestockQrScanPageState();
}

class _LivestockQrScanPageState extends State<LivestockQrScanPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _qrSuccess = false;
  String? _livestockId;
  List<Specie> _specieList = [];
  List<String> _species = [];
  String? _selectedSpecie;
  bool _isLoadingSpecies = false;
  final TextEditingController _inspectionCodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecies() async {
    setState(() => _isLoadingSpecies = true);
    try {
      final response = await SpecieService().getAllSpecies();
      if (response.success && response.data != null) {
        setState(() {
          _specieList = response.data!.specieList;
          _species = response.data!.items;
          _selectedSpecie = _species.isNotEmpty ? _species[0] : null;
          _isLoadingSpecies = false;
        });
      } else {
        setState(() {
          _isLoadingSpecies = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingSpecies = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lấy danh sách loài: $e')));
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.startsWith('https://www.lms.com/')) {
        final livestockId = code.split('/').last;
        setState(() {
          _livestockId = livestockId;
          _qrSuccess = true;
          _isScanning = false;
          if (_inspectionCodeController.text.isEmpty) {
            _inspectionCodeController.text = livestockId;
          }
        });
        Future.delayed(const Duration(milliseconds: 100), () async {
          if (mounted) _scannerController.stop();
          // Lấy thông tin livestock summary và chuyển trang luôn
          final summary =
              await LivestockSummaryService().fetchSummary(livestockId);
          if (summary == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Không lấy được thông tin vật nuôi!')));
            }
            return;
          }
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LivestockConfirmPage(
                  mode: widget.mode,
                  livestock: summary,
                  customerName: widget.customerName,
                  total: widget.total,
                  received: widget.received,
                  batchExportId: widget.batchExportId,
                  batchExportDetailId: widget.batchExportDetailId,
                ),
              ),
            );
          }
        });
        break;
      }
    }
  }

  bool get _canConfirm =>
      _livestockId != null &&
      _selectedSpecie != null &&
      _inspectionCodeController.text.isNotEmpty;

  String get _confirmText {
    switch (widget.mode) {
      case LivestockActionMode.add:
        return 'Xác nhận';
      case LivestockActionMode.replace:
        return 'Xác nhận đổi';
      case LivestockActionMode.handover:
        return 'Xác nhận bàn giao';
    }
  }

  int? get _selectedSpecieIndex {
    if (_selectedSpecie == null) return null;
    final idx = _species.indexOf(_selectedSpecie!);
    return idx >= 0 ? idx : null;
  }

  Future<void> _tryFetchLivestockId() async {
    final code = _inspectionCodeController.text.trim();
    final specieIdx = _selectedSpecieIndex;
    if (code.isEmpty || specieIdx == null) return;
    final id = await LivestockGeneralInfoService()
        .getLivestockIdByInspectionCodeAndSpecie(code, specieIdx);
    setState(() {
      _livestockId = id;
      _qrSuccess = id != null;
    });
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy livestockId!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle()), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.customerName != null)
                  Text('Tên khách hàng: ${widget.customerName!}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                if (widget.total != null && widget.received != null)
                  Text(
                      'Số lượng: ${widget.total}, Đã nhận: ${widget.received}'),
                if (_livestockId != null)
                  Text('Mã thẻ tai: $_livestockId',
                      style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 12),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isScanning
                        ? MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          )
                        : Center(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _qrSuccess = false;
                                  _livestockId = null;
                                  _isScanning = true;
                                });
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                await _scannerController.start();
                              },
                              child: const Icon(Icons.check_circle,
                                  size: 100, color: Colors.green),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _inspectionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã thẻ tai',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _tryFetchLivestockId(),
                ),
                const SizedBox(height: 12),
                _isLoadingSpecies
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _selectedSpecie,
                        items: _species
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedSpecie = v);
                          _tryFetchLivestockId();
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: 'Loài'),
                      ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canConfirm
                        ? () async {
                            final summary = await LivestockSummaryService()
                                .fetchSummary(_livestockId!);
                            if (summary == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Không lấy được thông tin vật nuôi!')));
                              }
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LivestockConfirmPage(
                                  mode: widget.mode,
                                  livestock: summary,
                                  customerName: widget.customerName,
                                  total: widget.total,
                                  received: widget.received,
                                  batchExportId: widget.batchExportId,
                                  batchExportDetailId:
                                      widget.batchExportDetailId,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(_confirmText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _canConfirm ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case LivestockActionMode.add:
        return 'Quét QR xác nhận thêm vật nuôi';
      case LivestockActionMode.replace:
        return 'Quét QR xác nhận đổi vật nuôi';
      case LivestockActionMode.handover:
        return 'Quét QR xác nhận bàn giao vật nuôi';
    }
  }
}
