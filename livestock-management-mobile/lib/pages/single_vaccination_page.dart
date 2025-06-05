import 'package:flutter/material.dart';
import '../services/disease_service.dart';
import '../models/disease_model.dart';
import '../services/livestock_info_service.dart';
import '../models/livestock_info_model.dart';
import 'vaccination_confirm_page_custom.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/specie_service.dart';
import '../models/specie_model.dart';
import '../utils/specie_helper.dart';

class SingleVaccinationPage extends StatefulWidget {
  const SingleVaccinationPage({Key? key}) : super(key: key);

  @override
  State<SingleVaccinationPage> createState() => _SingleVaccinationPageState();
}

class _SingleVaccinationPageState extends State<SingleVaccinationPage> {
  final DiseaseService _diseaseService = DiseaseService();
  List<Disease> _diseases = [];
  List<Medicine> _medicines = [];
  Disease? _selectedDisease;
  Medicine? _selectedMedicine;
  bool _loadingDisease = true;
  bool _loadingMedicine = false;
  final TextEditingController _tagController = TextEditingController();
  String _selectedSpecies = 'Bò';
  bool _loadingConfirm = false;
  bool _isScanning = false;
  String? _scannedLivestockId;
  List<String> _species = [];
  bool _isLoadingSpecies = true;
  String? _selectedSpecie;
  Map<String, int> _specieTypesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
    _loadSpecies();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
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

  Future<void> _onConfirm() async {
    if (_selectedDisease == null || _selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ bệnh và thuốc!')),
      );
      return;
    }
    if (_scannedLivestockId == null) {
      if (_tagController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập mã thẻ tai!')),
        );
        return;
      }
    }
    setState(() => _loadingConfirm = true);
    try {
      LivestockInfo livestockInfo;
      if (_scannedLivestockId != null) {
        livestockInfo = await LivestockInfoService().getLivestockInfo(
          livestockId: _scannedLivestockId,
          specieType: 0,
        );
      } else {
        final specieType = _specieTypesMap[_selectedSpecie] ?? 0;
        livestockInfo = await LivestockInfoService().getLivestockInfo(
          inspectionCode: _tagController.text.trim(),
          specieType: specieType,
        );
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VaccinationConfirmPageCustom(
            livestockInfo: livestockInfo,
            selectedDisease: _selectedDisease!,
            selectedMedicine: _selectedMedicine!,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lấy được thông tin vật nuôi: $e')),
      );
    } finally {
      setState(() => _loadingConfirm = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận tiêm'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text('Bệnh'),
                  _loadingDisease
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButton<Disease>(
                          isExpanded: true,
                          value: _selectedDisease,
                          hint: const Text('Chọn bệnh'),
                          items: _diseases
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.name),
                                  ))
                              .toList(),
                          onChanged: (disease) {
                            setState(() {
                              _selectedDisease = disease;
                              _selectedMedicine = null;
                              _medicines = [];
                            });
                            if (disease != null) {
                              _fetchMedicines(disease.id);
                            }
                          },
                        ),
                  const SizedBox(height: 24),
                  const Text('Thuốc'),
                  _loadingMedicine
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButton<Medicine>(
                          isExpanded: true,
                          value: _selectedMedicine,
                          hint: const Text('Chọn thuốc'),
                          items: _medicines
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m.name),
                                  ))
                              .toList(),
                          onChanged: (medicine) {
                            setState(() {
                              _selectedMedicine = medicine;
                            });
                          },
                        ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: _openQrScanner,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _scannedLivestockId == null
                            ? const Icon(Icons.camera_alt, size: 100)
                            : const Icon(Icons.check_circle,
                                size: 100, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Hoặc'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_scannedLivestockId == null) ...[
                    const Text('Mã thẻ tai'),
                    TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập mã thẻ tai',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loài'),
                    _isLoadingSpecies
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButton<String>(
                            isExpanded: true,
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
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadingConfirm ? null : _onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: _loadingConfirm
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Xác nhận tiêm',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Hủy'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
