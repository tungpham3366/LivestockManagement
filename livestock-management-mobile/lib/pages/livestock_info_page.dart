import 'package:flutter/material.dart';
import '../models/livestock_vaccination_model.dart';
import '../services/livestock_service.dart';
import '../routes/app_routes.dart';
import 'qr_scanner_page.dart';
import '../utils/specie_helper.dart';

class LivestockInfoPage extends StatefulWidget {
  final String procurementId;
  final String livestockId;
  final int? specieType;
  final String? inspectionCode;
  final bool searchByQr; // Xác định phương thức tìm kiếm

  const LivestockInfoPage({
    Key? key,
    required this.procurementId,
    this.livestockId = '',
    this.specieType,
    this.inspectionCode,
    this.searchByQr = true, // Mặc định là tìm bằng QR
  }) : super(key: key);

  // Factory constructor để xử lý arguments từ Navigator.pushNamed
  factory LivestockInfoPage.fromArguments(Map<String, dynamic> arguments) {
    return LivestockInfoPage(
      procurementId: arguments['procurementId'] ?? '',
      livestockId: arguments['livestockId'] ?? '',
      specieType: arguments['specieType'],
      inspectionCode: arguments['inspectionCode'],
      searchByQr: arguments['searchByQr'] ?? true,
    );
  }

  @override
  State<LivestockInfoPage> createState() => _LivestockInfoPageState();
}

class _LivestockInfoPageState extends State<LivestockInfoPage> {
  final _livestockService = LivestockService();
  bool _isLoading = true;
  String _errorMessage = '';
  LivestockVaccinationInfo? _livestockInfo;

  // Danh sách các mũi tiêm được chọn
  final Set<String> _selectedVaccinations = {};

  @override
  void initState() {
    super.initState();

    // Thêm log để debug
    print('LivestockInfoPage.initState:');
    print('  procurementId: ${widget.procurementId}');
    print('  livestockId: ${widget.livestockId}');
    print('  specieType: ${widget.specieType}');
    print('  inspectionCode: ${widget.inspectionCode}');
    print('  searchByQr: ${widget.searchByQr}');

    _loadLivestockInfo();
  }

  Future<void> _loadLivestockInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      LivestockVaccinationResponse response;

      // Kiểm tra phương thức tìm kiếm
      if (widget.searchByQr) {
        // Tìm bằng QR (sử dụng livestockId)
        if (widget.livestockId.isEmpty) {
          throw Exception('Thiếu mã vật nuôi');
        }

        print('Tìm thông tin vật nuôi bằng livestockId: ${widget.livestockId}');
        response = await _livestockService.getLivestockVaccinationInfo(
          widget.procurementId,
          widget.livestockId,
        );
      } else {
        // Tìm bằng mã thẻ tai và loài
        if (widget.specieType == null ||
            widget.inspectionCode == null ||
            widget.inspectionCode!.isEmpty) {
          throw Exception('Thiếu thông tin mã thẻ tai hoặc loài');
        }

        print(
            'Tìm thông tin vật nuôi bằng inspectionCode: ${widget.inspectionCode} và specieType: ${widget.specieType}');
        response = await _livestockService.getLivestockVaccinationInfoByCode(
          widget.procurementId,
          widget.specieType!,
          widget.inspectionCode!,
        );
      }

      if (response.success && response.data != null) {
        setState(() {
          _livestockInfo = response.data;
          _isLoading = false;

          // Xác định specieType ưu tiên để lưu
          int specieTypeToSave;

          if (!widget.searchByQr && widget.specieType != null) {
            // Nếu tìm bằng mã thẻ tai, ưu tiên sử dụng specieType từ parameter
            specieTypeToSave = widget.specieType!;
            print('Ưu tiên lưu specieType từ parameter: $specieTypeToSave');
          } else {
            // Nếu tìm bằng QR, sử dụng specieType từ response
            specieTypeToSave =
                SpecieHelper.getSpecieTypeFromName(_livestockInfo!.specieName);
            print(
                'Lưu specieType từ livestock_info response: $specieTypeToSave');
          }

          // Lưu specieType đã xác định
          SpecieHelper.setCurrentSpecieTypeForVaccination(specieTypeToSave);
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

  // Chuyển đến trang xác nhận tiêm
  void _navigateToConfirmVaccination() {
    if (_selectedVaccinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một mũi tiêm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Lấy danh sách mũi tiêm đã chọn
    final selectedDiseases = _livestockInfo!.livestockRequireDisease
        .where((disease) =>
            _selectedVaccinations.contains(disease.batchVaccinationId))
        .toList();

    // Lấy specieType từ tên loài
    final int specieType =
        SpecieHelper.getSpecieTypeFromName(_livestockInfo!.specieName);

    // Chuẩn bị dữ liệu để xác định loại tìm kiếm
    final String searchTitle = widget.searchByQr
        ? 'Quét QR trên thẻ tai để xác nhận tiêm các bệnh'
        : 'Nhập mã thẻ tai để xác nhận tiêm các bệnh';

    // Chuyển sang trang quét QR để xác nhận tiêm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerPage(
          procurementId: widget.procurementId,
          mode: ScanMode.vaccination,
          selectedDiseases: selectedDiseases,
          livestockInfo: _livestockInfo,
          title: 'Xác nhận tiêm vật nuôi',
          scanInstruction: searchTitle,
          expectedSpecieType: specieType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cần tiêm chủng'),
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
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLivestockInfo,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_livestockInfo == null) {
      return const Center(
        child: Text('Không có thông tin vật nuôi'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'Thông tin cần tiêm chủng cho gói thầu B',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Nút báo cáo
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Xử lý báo cáo thông tin
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật thông tin tiêm chủng'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Báo cáo thông tin này'),
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin vật nuôi
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 100, child: Text('Mã thẻ tai')),
                      const SizedBox(width: 8),
                      Text(
                        _livestockInfo!.inspectionCode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 100, child: Text('Loài')),
                      const SizedBox(width: 8),
                      Text(_livestockInfo!.specieName),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 100, child: Text('Màu lông')),
                      const SizedBox(width: 8),
                      Text(_livestockInfo!.color),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tiêu đề các mũi cần tiêm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Các mũi cần tiêm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedVaccinations.length ==
                        _livestockInfo!.livestockRequireDisease.length) {
                      // Nếu đã chọn tất cả, bỏ chọn hết
                      _selectedVaccinations.clear();
                    } else {
                      // Nếu chưa chọn tất cả, chọn tất cả
                      _selectedVaccinations.clear();
                      for (final disease
                          in _livestockInfo!.livestockRequireDisease) {
                        _selectedVaccinations.add(disease.batchVaccinationId);
                      }
                    }
                  });
                },
                child: Text(
                  _selectedVaccinations.length ==
                          _livestockInfo!.livestockRequireDisease.length
                      ? 'Bỏ chọn tất cả'
                      : 'Chọn tất cả',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danh sách các mũi cần tiêm dạng card
          _buildVaccinationCards(),

          // Nút xác nhận tiêm tất cả được chọn
          if (_selectedVaccinations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToConfirmVaccination,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Xác nhận tiêm ${_selectedVaccinations.length} mũi đã chọn',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCards() {
    return Column(
      children: _livestockInfo!.livestockRequireDisease
          .asMap()
          .entries
          .map((entry) => _buildVaccinationCard(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildVaccinationCard(int index, LivestockRequireDisease disease) {
    final bool isSelected =
        _selectedVaccinations.contains(disease.batchVaccinationId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedVaccinations.remove(disease.batchVaccinationId);
            } else {
              _selectedVaccinations.add(disease.batchVaccinationId);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedVaccinations.add(disease.batchVaccinationId);
                    } else {
                      _selectedVaccinations.remove(disease.batchVaccinationId);
                    }
                  });
                },
              ),
              const SizedBox(width: 16),

              // Thông tin bệnh và thuốc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.diseaseName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      disease.medicineName,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút xác nhận tiêm đơn lẻ
              ElevatedButton(
                onPressed: () {
                  // Chuyển sang trang quét QR để xác nhận tiêm đơn lẻ
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScannerPage(
                        procurementId: widget.procurementId,
                        mode: ScanMode.vaccination,
                        selectedDiseases: [disease],
                        livestockInfo: _livestockInfo,
                        title: 'Xác nhận tiêm vật nuôi',
                        scanInstruction:
                            'Quét QR trên thẻ tai để xác nhận tiêm ${disease.diseaseName}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xác nhận tiêm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
