import 'package:flutter/material.dart';
import '../services/export_choose_scan_service.dart';
import '../services/specie_service.dart';
import '../models/specie_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'order_detail_page.dart';
import 'export_confirm_single_page.dart';
import '../services/livestock_summary_service.dart';
import '../models/livestock_summary_model.dart';

class ExportChooseScanPage extends StatefulWidget {
  final String? orderId;
  final String? procurementId;
  final String? customerName;
  final int? total;
  final int? received;
  final String? code;
  const ExportChooseScanPage(
      {Key? key,
      this.orderId,
      this.procurementId,
      this.customerName,
      this.total,
      this.received,
      this.code})
      : super(key: key);

  @override
  State<ExportChooseScanPage> createState() => _ExportChooseScanPageState();
}

class _ExportChooseScanPageState extends State<ExportChooseScanPage> {
  final ExportChooseScanService _service = ExportChooseScanService();
  List<Specie> _specieList = [];
  List<String> _species = [];
  Map<String, int> _specieTypesMap = {};
  String? _selectedSpecie;
  String? _inspectionCode;
  String? _livestockId;
  bool _isLoadingSpecies = false;
  bool _isFinding = false;
  bool _isCameraActive = false;
  bool _qrSuccess = false;
  final TextEditingController _inspectionCodeController =
      TextEditingController();
  bool _isCameraDialogOpen = false;
  bool _showCamera = false;
  bool _cameraActive = true;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;

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
          _specieTypesMap = {for (var s in _specieList) s.name: s.type};
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

  Future<void> _findLivestockId() async {
    if (_selectedSpecie == null || _inspectionCodeController.text.isEmpty)
      return;
    setState(() => _isFinding = true);
    try {
      final specieType = _specieTypesMap[_selectedSpecie] ?? 0;
      final id = await _service.getLivestockIdByInspectionCodeAndType(
          _inspectionCodeController.text, specieType);
      setState(() {
        _livestockId = id;
        _isFinding = false;
        _qrSuccess = id != null;
      });
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy livestockId')));
      }
    } catch (e) {
      setState(() => _isFinding = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tìm livestockId: $e')));
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
        });
        Future.delayed(const Duration(milliseconds: 100), () async {
          if (mounted) _scannerController.stop();
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
                builder: (_) => ExportConfirmSinglePage(
                  summary: summary,
                  customerName: widget.customerName,
                  code: widget.code,
                  total: widget.total,
                  received: widget.received,
                  orderId: widget.orderId,
                ),
              ),
            );
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn loài vật xuất trại'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.customerName != null)
                  Text('Đơn lẻ cho khách hàng: ${widget.customerName!}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                if (widget.code != null)
                  Text('Mã đơn: ${widget.code!}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.blue)),
                if (widget.total != null && widget.received != null)
                  Text(
                      'Số lượng vật nuôi đã chọn: ${widget.received} / ${widget.total}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange)),
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
                              onTap: () {
                                setState(() {
                                  _qrSuccess = false;
                                  _livestockId = null;
                                  _isScanning = true;
                                });
                                _scannerController.start();
                              },
                              child: const Icon(Icons.check_circle,
                                  size: 100, color: Colors.green),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedSpecie,
                  items: _species
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpecie = v),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'Loài'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _inspectionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã thẻ tai',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isFinding ? null : _findLivestockId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isFinding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Tìm',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                if (_livestockId != null)
                  Text('LivestockId: $_livestockId',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                if (_livestockId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final summary = await LivestockSummaryService()
                            .fetchSummary(_livestockId!);
                        if (summary != null) {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExportConfirmSinglePage(
                                summary: summary,
                                customerName: widget.customerName,
                                code: widget.code,
                                total: widget.total,
                                received: widget.received,
                                orderId: widget.orderId,
                              ),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Không lấy được thông tin vật nuôi!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Xác nhận',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (widget.orderId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailPage(orderId: widget.orderId!),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Các yêu cầu'),
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

class _QrInputDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập mã QR (demo)'),
      content: TextField(
          controller: _controller,
          decoration: const InputDecoration(labelText: 'QR code')),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: const Text('OK')),
      ],
    );
  }
}
