import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import '../services/batch_import_service.dart';
import '../services/disease_service.dart';
import '../models/disease_model.dart';
import 'package:intl/intl.dart';

class QrInfoLayoutPage extends StatefulWidget {
  final String code;
  final String specie;
  final int specieId;
  final String batchImportId;
  const QrInfoLayoutPage(
      {Key? key,
      required this.code,
      required this.specie,
      required this.specieId,
      required this.batchImportId})
      : super(key: key);

  @override
  State<QrInfoLayoutPage> createState() => _QrInfoLayoutPageState();
}

class _QrInfoLayoutPageState extends State<QrInfoLayoutPage> {
  String? _selectedSpecieName;
  final DiseaseService _diseaseService = DiseaseService();
  List<Disease> _diseases = [];
  List<Medicine> _medicines = [];
  Disease? _selectedDisease;
  Medicine? _selectedMedicine;
  bool _loadingDisease = true;
  bool _loadingMedicine = false;

  late Future<String?> _futureInspectionCode;
  late Future<List<Map<String, dynamic>>> _futureSpecies;

  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  int? _selectedGender; // 0: Đực, 1: Cái
  String? _livestockId; // lấy từ mã QR (widget.code)
  String? _inspectionCode; // lấy từ mã QR hoặc input
  String? _selectedSpecieId; // lấy từ dropdown loài vật

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
    _futureInspectionCode =
        BatchImportService().getInspectionCodeFromSpecie(widget.specie);
    _futureSpecies = BatchImportService().getSpecieNamesById(widget.specieId);
    _livestockId = widget.code.split('/').last;
    _inspectionCode = widget.code.split('/').last;
  }

  Future<void> _fetchDiseases() async {
    setState(() => _loadingDisease = true);
    try {
      final diseases = await _diseaseService.getDiseases();
      setState(() {
        _diseases = diseases;
        _loadingDisease = false;
      });
    } catch (e) {
      setState(() => _loadingDisease = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách bệnh: $e')),
      );
    }
  }

  Future<void> _fetchMedicines(String diseaseId) async {
    setState(() {
      _loadingMedicine = true;
      _medicines = [];
      _selectedMedicine = null;
    });
    try {
      final medicines = await _diseaseService.getMedicinesByDisease(diseaseId);
      setState(() {
        _medicines = medicines;
        _loadingMedicine = false;
      });
    } catch (e) {
      setState(() => _loadingMedicine = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách thuốc: $e')),
      );
    }
  }

  Future<void> _addLivestockToBatchImport() async {
    // Lấy specieId từ dropdown loài vật
    if (_selectedSpecieName != null) {
      final speciesList = await _futureSpecies;
      final specie = speciesList.firstWhere(
          (e) => e['name'] == _selectedSpecieName,
          orElse: () => {});
      _selectedSpecieId = specie['id']?.toString();
    }
    final body = {
      "id": _livestockId,
      "inspectionCode": _inspectionCode,
      "specieId": _selectedSpecieId,
      "livestockStatus": 0,
      "gender": _selectedGender,
      "color": _colorController.text,
      "weight": double.tryParse(_weightController.text) ?? 0.1,
      "dob": _dobController.text,
      "medicineId": _selectedMedicine?.id,
    };
    final batchImportService = BatchImportService();
    final success = await batchImportService.addLivestockToBatchImport(
      batchImportId: widget.batchImportId,
      body: body,
    );
    if (success) {
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm vật nuôi thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // QR Section
                Text('Mã kiểm dịch cho mã QR',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 8),
                FutureBuilder<String?>(
                  future: BatchImportService()
                      .getInspectionCodeFromSpecie(widget.specie),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Text('Không lấy được mã kiểm dịch',
                          style: TextStyle(color: Colors.red, fontSize: 24));
                    }
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: qr_flutter.QrPainter(
                      data: widget.code,
                      version: qr_flutter.QrVersions.auto,
                      emptyColor: Colors.white,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Card nhập liệu
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tên lô nhập:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('Lô Nhập 1', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text('Loài Vật:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _futureSpecies,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError ||
                                snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return const Text('Không có dữ liệu loài vật',
                                  style: TextStyle(color: Colors.red));
                            }
                            final items = snapshot.data!;
                            return DropdownButtonFormField<String>(
                              value: _selectedSpecieName,
                              items: items
                                  .map((e) => DropdownMenuItem<String>(
                                        value: e['name'],
                                        child: Text(e['name']),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedSpecieName = val;
                                });
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), isDense: true),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Giới tính:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButtonFormField<int>(
                                    value: _selectedGender,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 0, child: Text('Đực')),
                                      DropdownMenuItem(
                                          value: 1, child: Text('Cái')),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedGender = val;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bệnh:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  _loadingDisease
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : DropdownButtonFormField<String>(
                                          value: _selectedDisease?.id,
                                          hint: const Text('Chọn bệnh'),
                                          items: _diseases
                                              .map((d) => DropdownMenuItem(
                                                    value: d.id,
                                                    child: Text(d.name),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final selected =
                                                  _diseases.firstWhere(
                                                      (e) => e.id == val);
                                              setState(() {
                                                _selectedDisease = selected;
                                                _loadingMedicine = true;
                                                _medicines = [];
                                                _selectedMedicine = null;
                                              });
                                              _fetchMedicines(selected.id);
                                            }
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              isDense: true),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Màu lông:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  TextField(
                                    controller: _colorController,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Vaccin:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  _loadingMedicine
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : DropdownButtonFormField<String>(
                                          value: _selectedMedicine?.id,
                                          hint: const Text('Chọn vaccin'),
                                          items: _medicines
                                              .map((m) => DropdownMenuItem(
                                                    value: m.id,
                                                    child: Text(m.name),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedMedicine =
                                                    _medicines.firstWhere(
                                                        (e) => e.id == val);
                                              });
                                            }
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              isDense: true),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Trọng lượng nhập:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  TextField(
                                    controller: _weightController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      suffixText: 'kg',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ngày sinh:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  TextField(
                                    controller: _dobController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      suffixIcon:
                                          Icon(Icons.calendar_today, size: 18),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        // Format ngày thành YYYY-MM-DD
                                        _dobController.text =
                                            DateFormat('yyyy-MM-dd')
                                                .format(picked);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Số lượng vật nuôi đã chọn: 0/100',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Quét lại'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addLivestockToBatchImport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Xác nhận'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
