import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/import_management_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/batch_import_service.dart';

class ImportLivestockInfoPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isReplacement;
  const ImportLivestockInfoPage(
      {Key? key, required this.data, required this.isReplacement})
      : super(key: key);

  @override
  State<ImportLivestockInfoPage> createState() =>
      _ImportLivestockInfoPageState();
}

class _ImportLivestockInfoPageState extends State<ImportLivestockInfoPage> {
  late TextEditingController colorController;
  late TextEditingController weightController;
  late TextEditingController dobController;
  late TextEditingController genderController;
  late TextEditingController batchImportNameController;
  late TextEditingController specieNameController;
  late TextEditingController inspectionCodeController;
  late TextEditingController livestockIdController;
  bool isExport = false;
  final ImportManagementService _importService = ImportManagementService();
  final BatchImportService _batchImportService = BatchImportService();
  List<Map<String, dynamic>> _batchImports = [];
  List<Map<String, dynamic>> _species = [];
  String? _selectedBatchImportId;
  String? _selectedSpecieName;
  int? _specieId;
  bool _editDataLoaded = false;

  Future<void> _loadEditData() async {
    final batchImports = await _importService.getListMissingBatchImport();
    int specieId = 0;
    if (widget.data['specieId'] != null) {
      specieId = widget.data['specieId'] is int
          ? widget.data['specieId']
          : int.tryParse(widget.data['specieId'].toString()) ?? 0;
    }
    final species = specieId > 0
        ? (await _batchImportService.getSpecieNamesById(specieId))
            .cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    setState(() {
      _batchImports = batchImports;
      _species = species;
      _selectedBatchImportId =
          batchImports.isNotEmpty ? batchImports[0]['batchImportId'] : null;
      _selectedSpecieName = species.isNotEmpty ? species[0]['name'] : null;
      _editDataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    colorController =
        TextEditingController(text: widget.data['color']?.toString() ?? '');
    weightController =
        TextEditingController(text: widget.data['weight']?.toString() ?? '');
    dobController = TextEditingController(
        text: widget.data['dob']?.toString()?.split('T').first ?? '');
    genderController =
        TextEditingController(text: widget.data['gender']?.toString() ?? '');
    batchImportNameController = TextEditingController(
        text: widget.data['batchImportName']?.toString() ?? '');
    specieNameController = TextEditingController(
        text: widget.data['specieName']?.toString() ?? '');
    inspectionCodeController = TextEditingController(
        text: widget.data['inspectionCode']?.toString() ?? '');
    livestockIdController = TextEditingController(
        text: widget.data['livestockId']?.toString() ?? '');
    if (widget.isReplacement) {
      _loadEditData();
    }
  }

  @override
  void dispose() {
    colorController.dispose();
    weightController.dispose();
    dobController.dispose();
    genderController.dispose();
    batchImportNameController.dispose();
    specieNameController.dispose();
    inspectionCodeController.dispose();
    livestockIdController.dispose();
    super.dispose();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // hoặc key user phù hợp
  }

  @override
  Widget build(BuildContext context) {
    final isReplacement = widget.isReplacement;
    final qrData = widget.data['inspectionCode'] ?? '';
    final livestockId = widget.data['livestockId'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(isReplacement
            ? 'Xác nhận nhập loài vật thay thế'
            : 'Xác nhận nhập loài vật'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    isReplacement
                        ? 'Mã kiểm dịch cho mã QR'
                        : 'Thông tin loài vật',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(widget.data['inspectionCode'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 8),
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 120,
                  gapless: false,
                ),
                const SizedBox(height: 16),
                if (!isReplacement) ...[
                  _infoRow(
                      'Tên lô nhập:', widget.data['batchImportName'] ?? ''),
                  _infoRow('Loài vật:', widget.data['specieName'] ?? ''),
                  _infoRow('Giới tính:', widget.data['gender'] ?? ''),
                  _infoRow('Màu lông:', widget.data['color'] ?? ''),
                  _infoRow(
                      'Cân nặng:', widget.data['weight']?.toString() ?? ''),
                  _infoRow('Ngày sinh:',
                      (widget.data['dob']?.toString()?.split('T').first ?? '')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: isExport,
                        onChanged: (v) async {
                          if (v == true) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Center(
                                    child: Text('Xác nhận xuất bán thịt')),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(widget.data['inspectionCode'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 12),
                                    _dialogInfoRow('Tên lô nhập:',
                                        widget.data['batchImportName'] ?? ''),
                                    _dialogInfoRow('Loài vật:',
                                        widget.data['specieName'] ?? ''),
                                    _dialogInfoRow('Giới tính:',
                                        widget.data['gender'] ?? ''),
                                    _dialogInfoRow('Màu lông:',
                                        widget.data['color'] ?? ''),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final success = await _importService
                                          .confirmLivestockForMeatSale(
                                              livestockId);
                                      if (success) {
                                        if (mounted) {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).popUntil(
                                              (route) =>
                                                  route.settings.name == null ||
                                                  route.settings.name ==
                                                      '/import-confirm');
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Xác nhận xuất bán thịt thất bại!')));
                                      }
                                    },
                                    child: const Text('Xác nhận'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            setState(() {
                              isExport = false;
                            });
                          }
                        },
                      ),
                      const Text('Xuất bán thịt'),
                    ],
                  ),
                ] else ...[
                  // Dropdown Tên lô nhập
                  !_editDataLoaded
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tên lô nhập:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedBatchImportId,
                                items: _batchImports
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item['batchImportId'],
                                          child: Text(
                                              item['batchImportName'] ?? ''),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBatchImportId = value;
                                    final selected = _batchImports.firstWhere(
                                        (e) => e['batchImportId'] == value,
                                        orElse: () => {});
                                    batchImportNameController.text =
                                        selected['batchImportName'] ?? '';
                                  });
                                },
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder()),
                              ),
                            ],
                          ),
                        ),
                  // Dropdown Loài vật
                  !_editDataLoaded
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Loài Vật:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedSpecieName,
                                items: _species
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item['name'],
                                          child: Text(item['name'] ?? ''),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSpecieName = value;
                                    specieNameController.text = value ?? '';
                                  });
                                },
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder()),
                              ),
                            ],
                          ),
                        ),
                  // Dropdown Giới tính
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giới tính:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: genderController.text.isNotEmpty
                              ? genderController.text
                              : null,
                          items: const [
                            DropdownMenuItem(value: 'ĐỰC', child: Text('Đực')),
                            DropdownMenuItem(value: 'CÁI', child: Text('Cái')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              genderController.text = value ?? '';
                            });
                          },
                          decoration: const InputDecoration(
                              isDense: true, border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  _editInputFull('Màu lông:', colorController),
                  _editInputFull('Cân nặng:', weightController),
                  _editInputFull('Ngày sinh:', dobController),
                ],
                const SizedBox(height: 8),
                Text(
                    'Số lượng vật nuôi đã xác nhận: ${widget.data['imported'] ?? 0}/${widget.data['total'] ?? 0}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Quét lại'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.isReplacement) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Center(
                                  child: Text('Xác nhận nhập thay thế')),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(widget.data['inspectionCode'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 12),
                                  _dialogInfoRow('Tên lô nhập:',
                                      batchImportNameController.text),
                                  _dialogInfoRow(
                                      'Loài vật:', specieNameController.text),
                                  _dialogInfoRow(
                                      'Giới tính:', genderController.text),
                                  _dialogInfoRow(
                                      'Màu lông:', colorController.text),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userId =
                                        prefs.getString('auth_token');
                                    if (userId == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Không tìm thấy userId!')));
                                      return;
                                    }
                                    final batchImportId =
                                        _selectedBatchImportId ?? '';
                                    final specieId = _species
                                            .firstWhere(
                                                (e) =>
                                                    e['name'] ==
                                                    _selectedSpecieName,
                                                orElse: () => {})['id']
                                            ?.toString() ??
                                        '';
                                    final genderValue =
                                        (genderController.text.toUpperCase() ==
                                                'ĐỰC')
                                            ? 0
                                            : 1;
                                    final body = {
                                      'id': widget.data['livestockId'],
                                      'inspectionCode':
                                          inspectionCodeController.text,
                                      'specieId': specieId,
                                      'livestockStatus': 0,
                                      'gender': genderValue,
                                      'color': colorController.text,
                                      'weight': double.tryParse(
                                              weightController.text) ??
                                          0.1,
                                      'dob': dobController.text,
                                      'medicineId': null,
                                      'requestedBy': userId,
                                    };
                                    final result = await _importService
                                        .confirmReplaceLivestockToBatchImport(
                                            batchImportId, body);
                                    if (result['success'] == true) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).popUntil(
                                            (route) =>
                                                route.settings.name == null ||
                                                route.settings.name ==
                                                    '/import-confirm');
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result['message'] ??
                                                'Xác nhận thay thế thất bại!')),
                                      );
                                    }
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Center(child: Text('Xác nhận nhập')),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(widget.data['inspectionCode'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 12),
                                  _dialogInfoRow('Tên lô nhập:',
                                      widget.data['batchImportName'] ?? ''),
                                  _dialogInfoRow('Loài vật:',
                                      widget.data['specieName'] ?? ''),
                                  _dialogInfoRow('Giới tính:',
                                      widget.data['gender'] ?? ''),
                                  _dialogInfoRow(
                                      'Màu lông:', widget.data['color'] ?? ''),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final success = await _importService
                                        .confirmImported(livestockId);
                                    if (success) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).popUntil(
                                            (route) =>
                                                route.settings.name == null ||
                                                route.settings.name ==
                                                    '/import-confirm');
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Xác nhận nhập thất bại!')));
                                    }
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _editInputFull(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
