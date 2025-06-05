import 'package:flutter/material.dart';
import '../models/livestock_vaccination_model.dart';
import '../services/livestock_service.dart';
import '../routes/app_routes.dart';
import '../utils/specie_helper.dart';

class VaccinationConfirmPage extends StatefulWidget {
  final LivestockVaccinationInfo livestockInfo;
  final List<LivestockRequireDisease> selectedDiseases;
  final bool isQrConfirmation; // Thêm tham số để phân biệt phương thức xác nhận
  final int selectedSpecieType; // Thêm tham số specieType đã chọn

  const VaccinationConfirmPage({
    Key? key,
    required this.livestockInfo,
    required this.selectedDiseases,
    this.isQrConfirmation = true, // Mặc định là xác nhận bằng QR
    this.selectedSpecieType = 0, // Mặc định là 0 (không xác định)
  }) : super(key: key);

  @override
  State<VaccinationConfirmPage> createState() => _VaccinationConfirmPageState();
}

class _VaccinationConfirmPageState extends State<VaccinationConfirmPage> {
  final LivestockService _livestockService = LivestockService();
  bool _isProcessing = false;

  // Phương thức xác nhận tiêm
  Future<void> _confirmVaccination() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Tạo danh sách các cuộc gọi API
      List<Future<Map<String, dynamic>>> apiCalls = [];

      // Lấy dữ liệu chính xác từ livestockInfo và tham số truyền vào
      final String livestockId = widget.livestockInfo.livestockId;
      final String inspectionCode = widget.livestockInfo.inspectionCode;

      // Quyết định sử dụng selectedSpecieType nếu được truyền,
      // nếu không thì lấy từ SpecieHelper
      int specieType = widget.selectedSpecieType;

      // Kiểm tra specieType đã lưu trong SpecieHelper
      int savedSpecieType = SpecieHelper.getCurrentSpecieTypeForVaccination();

      if (savedSpecieType != -1 && specieType != savedSpecieType) {
        print(
            'CẢNH BÁO: SpecieType từ tham số ($specieType) khác với specieType đã lưu ($savedSpecieType)');

        // Dùng giá trị từ SpecieHelper nếu có sự khác biệt
        specieType = savedSpecieType;
      }

      // Nếu không có specieType hợp lệ, lấy từ livestockInfo
      if (specieType == 0) {
        specieType =
            SpecieHelper.getSpecieTypeFromName(widget.livestockInfo.specieName);
        print('Sử dụng specieType từ tên loài: $specieType');
      }

      print('Thông tin xác nhận tiêm:');
      print('- livestockId: $livestockId');
      print('- inspectionCode: $inspectionCode');
      print('- specieType cuối cùng: $specieType');
      print('- selectedSpecieType từ tham số: ${widget.selectedSpecieType}');
      print('- SpecieType đã lưu: $savedSpecieType');
      print('- specieName: ${widget.livestockInfo.specieName}');
      print('- isQrConfirmation: ${widget.isQrConfirmation}');

      // Xác định phương thức xác nhận tiêm (QR hoặc mã thẻ tai)
      if (widget.isQrConfirmation) {
        // Xác nhận bằng QR (sử dụng livestockId)
        print('Xác nhận tiêm bằng QR (livestockId)');

        // Tạo request cho từng batchVaccinationId
        for (var disease in widget.selectedDiseases) {
          apiCalls.add(_livestockService.confirmVaccination(
              livestockId, disease.batchVaccinationId));
        }
      } else {
        // Xác nhận bằng mã thẻ tai và loài
        print('Xác nhận tiêm bằng mã thẻ tai (inspectionCode)');

        // Tạo request cho từng batchVaccinationId
        for (var disease in widget.selectedDiseases) {
          apiCalls.add(_livestockService.confirmVaccinationByInspectionCode(
              inspectionCode, specieType, disease.batchVaccinationId));
        }
      }

      // Gọi tất cả API cùng lúc
      final results = await Future.wait(apiCalls);

      // Kiểm tra kết quả
      bool hasError = false;
      String errorMessage = '';

      // Duyệt qua kết quả để tìm lỗi
      for (var result in results) {
        if (!(result['success'] as bool)) {
          hasError = true;

          // Lấy thông báo lỗi từ API (nếu có)
          if (result['data'] != null && result['data'] is String) {
            errorMessage = result['data'] as String;
          } else if (result['message'] != null) {
            errorMessage = result['message'] as String;
          } else {
            errorMessage = 'Có lỗi xảy ra khi xác nhận tiêm. Vui lòng thử lại.';
          }

          print('Lỗi từ API: $errorMessage');
          print('Chi tiết lỗi: $result');

          // Dừng xử lý khi gặp lỗi đầu tiên
          break;
        }
      }

      if (hasError) {
        if (mounted) {
          _showDialog('Lỗi', errorMessage, false);
        }
      } else {
        // Reset specieType sau khi xác nhận thành công
        SpecieHelper.resetCurrentSpecieType();

        if (mounted) {
          // Thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xác nhận tiêm thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Chuyển về trang procurement_detail
          Navigator.of(context).popUntil(
              (route) => route.settings.name == AppRoutes.procurementDetail);
        }
      }
    } catch (e) {
      if (mounted) {
        _showDialog(
            'Lỗi kết nối',
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.',
            false);
      }
      print('Lỗi khi xác nhận tiêm: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Phương thức lấy specieType từ tên loài
  int getSpecieTypeFromName(String specieName) {
    return SpecieHelper.getSpecieTypeFromName(specieName);
  }

  // Hiển thị dialog thông báo
  void _showDialog(String title, String content, bool canCancel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận tiêm vật nuôi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          widget.livestockInfo.inspectionCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 100, child: Text('Giống')),
                        const SizedBox(width: 8),
                        Text(widget.livestockInfo.specieName),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 100, child: Text('Màu lông')),
                        const SizedBox(width: 8),
                        Text(widget.livestockInfo.color),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tiêu đề danh sách mũi tiêm
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Các mũi tiêm đã chọn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Danh sách mũi tiêm dạng card
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedDiseases.length,
                itemBuilder: (context, index) {
                  final disease = widget.selectedDiseases[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 100, child: Text('Bệnh')),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  disease.diseaseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(width: 100, child: Text('Thuốc')),
                              const SizedBox(width: 8),
                              Expanded(child: Text(disease.medicineName)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Các nút hành động
            Row(
              children: [
                // Nút Hủy
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),

                // Nút Xác nhận
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmVaccination,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ))
                        : const Text(
                            'Xác nhận',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // Nút Quét lại
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.qrScanner,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Quét lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
