import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../routes/app_routes.dart';
import '../services/specie_service.dart';
import '../utils/specie_helper.dart';
import '../models/specie_model.dart';
import '../models/livestock_vaccination_model.dart';
import 'vaccination_confirm_page.dart';

enum ScanMode {
  search, // Chế độ tìm kiếm thông tin
  vaccination, // Chế độ xác nhận tiêm
}

class QrScannerPage extends StatefulWidget {
  final String? procurementId;
  final ScanMode mode;
  final List<LivestockRequireDisease>? selectedDiseases;
  final LivestockVaccinationInfo? livestockInfo;
  final String? title;
  final String? scanInstruction;
  final int? expectedSpecieType;

  const QrScannerPage({
    Key? key,
    this.procurementId,
    this.mode = ScanMode.search,
    this.selectedDiseases,
    this.livestockInfo,
    this.title,
    this.scanInstruction,
    this.expectedSpecieType,
  }) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _tagIdController = TextEditingController();
  String? _selectedSpecie;
  List<String> _species = [];
  Map<String, int> _specieTypesMap = {}; // Map tên loài với specieType
  bool _isLoadingSpecies = true;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _isShowingDialog = false; // Biến để kiểm soát việc hiển thị dialog

  @override
  void initState() {
    super.initState();
    print('QrScannerPage.initState - procurementId: ${widget.procurementId}');
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    setState(() {
      _isLoadingSpecies = true;
    });

    // Định nghĩa danh sách loài mặc định
    final defaultSpecies = SpecieHelper.getDefaultSpecies();

    // Định nghĩa map mặc định (index bắt đầu từ 0)
    final defaultSpecieTypesMap = SpecieHelper.specieTypeMap;

    try {
      final specieService = SpecieService();
      final response = await specieService.getAllSpecies();

      if (response.success && response.data != null) {
        setState(() {
          // Tạo map tên loài => specieType để sử dụng khi tìm kiếm bằng mã thẻ tai
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
      print('Lỗi khi tải danh sách loài: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tagIdController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    // Nếu đang xử lý hoặc đang hiển thị dialog, không xử lý tiếp
    if (_isProcessing || _isShowingDialog) return;

    _isProcessing = true;

    // Dừng quét tạm thời để tránh quét liên tục
    if (_isScanning) {
      await _scannerController.stop();
      setState(() {
        _isScanning = false;
      });
    }

    // Lấy giá trị trong barcode
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        await _processQrCode(code);
        break;
      }
    }

    _isProcessing = false;
  }

  Future<void> _processQrCode(String code) async {
    // Kiểm tra mã QR có đúng định dạng không
    if (code.startsWith('https://www.lms.com/')) {
      // Lấy livestockId từ URL
      final livestockId = code.split('/').last;

      // Xử lý theo chế độ scan
      if (widget.mode == ScanMode.search) {
        // Chế độ tìm kiếm
        _handleSearchModeByQr(livestockId);
      } else if (widget.mode == ScanMode.vaccination) {
        // Chế độ xác nhận tiêm - đánh dấu là đang xác nhận bằng QR (isQrScan=true)
        _checkAndHandleVaccination(livestockId, isQrScan: true);
      }
    } else {
      print('Mã QR không hợp lệ: $code');

      // Bắt đầu lại quét sau khi hiển thị lỗi
      if (mounted && !_isShowingDialog) {
        _showErrorDialog('Mã QR không hợp lệ',
            'Định dạng mã QR không hợp lệ. Vui lòng quét mã QR đúng.', true);
      }
    }
  }

  // Hiển thị dialog lỗi
  void _showErrorDialog(String title, String content, bool showRescanButton) {
    if (_isShowingDialog)
      return; // Nếu đang hiển thị dialog, không hiển thị thêm

    _isShowingDialog = true;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Không cho phép đóng dialog bằng cách chạm ra ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isShowingDialog = false;

                // Tự động bắt đầu quét lại sau khi đóng dialog
                if (!_isScanning) {
                  _scannerController.start();
                  setState(() {
                    _isScanning = true;
                  });
                }
              },
              child: const Text('Đóng'),
            ),
            if (showRescanButton)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isShowingDialog = false;

                  // Bắt đầu quét lại
                  if (!_isScanning) {
                    _scannerController.start();
                    setState(() {
                      _isScanning = true;
                    });
                  }
                },
                child: const Text('Quét lại'),
              ),
          ],
        );
      },
    ).then((_) {
      // Đảm bảo _isShowingDialog được cập nhật khi dialog đóng
      _isShowingDialog = false;
    });
  }

  // Xử lý chế độ tìm kiếm khi quét QR (sử dụng livestockId)
  void _handleSearchModeByQr(String livestockId) async {
    if (widget.procurementId != null) {
      if (mounted) {
        // Dừng quét
        await _scannerController.stop();

        // Reset specieType hiện tại khi bắt đầu tìm kiếm mới
        SpecieHelper.resetCurrentSpecieType();

        // Chuyển tới trang thông tin vật nuôi với livestockId
        Navigator.pushNamed(
          context,
          AppRoutes.livestockInfo,
          arguments: {
            'procurementId': widget.procurementId,
            'livestockId': livestockId,
            'searchByQr': true, // Đánh dấu là tìm bằng QR
          },
        );
      }
    } else {
      print('Không tìm thấy thông tin gói thầu');
      if (mounted && !_isShowingDialog) {
        _showErrorDialog('Lỗi', 'Không tìm thấy thông tin gói thầu', true);
      }
    }
  }

  // Xử lý chế độ tìm kiếm khi nhập mã thẻ tai (sử dụng inspectionCode và specieType)
  void _handleSearchModeByInspectionCode(String inspectionCode) async {
    if (widget.procurementId != null && _selectedSpecie != null) {
      // Lấy specieType từ map
      final int? specieType = _specieTypesMap[_selectedSpecie];

      if (specieType == null) {
        if (mounted && !_isShowingDialog) {
          _showErrorDialog('Lỗi', 'Không tìm thấy loài đã chọn', false);
        }
        return;
      }

      // Reset specieType hiện tại khi bắt đầu tìm kiếm mới
      print('Reset và xóa specieType đã lưu trước đó');
      SpecieHelper.resetCurrentSpecieType();

      // In ra specieType từ dropdown
      print('SpecieType từ dropdown (${_selectedSpecie}): $specieType');

      // Log trước khi chuyển trang
      print('QrScannerPage._handleSearchModeByInspectionCode - arguments:');
      print({
        'procurementId': widget.procurementId,
        'inspectionCode': inspectionCode,
        'specieType': specieType,
        'searchByQr': false,
      });
      if (widget.mode == ScanMode.search) {
        Navigator.pushNamed(
          context,
          AppRoutes.livestockInfo,
          arguments: {
            'procurementId': widget.procurementId,
            'inspectionCode': inspectionCode,
            'specieType': specieType,
            'searchByQr': false, // Đánh dấu là tìm bằng mã thẻ tai
          },
        );
      }
      // Chuyển tới trang thông tin vật nuôi với inspectionCode và specieType
    } else {
      print('Thiếu thông tin cần thiết');
      if (mounted && !_isShowingDialog) {
        _showErrorDialog(
            'Lỗi', 'Không tìm thấy thông tin gói thầu hoặc loài', false);
      }
    }
  }

  // Kiểm tra và xử lý tiêm chủng
  void _checkAndHandleVaccination(String inputValue, {bool isQrScan = false}) {
    // Kiểm tra thông tin cơ bản
    if (widget.procurementId == null || widget.selectedDiseases == null) {
      print('Thiếu thông tin cần thiết để xác nhận tiêm');
      if (mounted && !_isShowingDialog) {
        _showErrorDialog(
            'Lỗi', 'Thiếu thông tin cần thiết để xác nhận tiêm', isQrScan);
      }
      return;
    }

    // Đảm bảo có thông tin vật nuôi
    if (widget.livestockInfo == null) {
      if (mounted && !_isShowingDialog) {
        _showErrorDialog(
            'Lỗi', 'Không có thông tin vật nuôi để xác nhận tiêm', isQrScan);
      }
      return;
    }

    // Lấy specieType từ livestockInfo (để kiểm tra)
    int expectedSpecieType =
        SpecieHelper.getSpecieTypeFromName(widget.livestockInfo!.specieName);

    // Kiểm tra xem đã có specieType được lưu từ bước trước chưa
    int currentSavedSpecieType =
        SpecieHelper.getCurrentSpecieTypeForVaccination();
    if (currentSavedSpecieType != -1) {
      print('Có specieType đã lưu: $currentSavedSpecieType');

      // Kiểm tra nếu specieType từ livestock khác với specieType đã lưu
      if (currentSavedSpecieType != expectedSpecieType) {
        print(
            'CẢNH BÁO: SpecieType từ livestock ($expectedSpecieType) khác với specieType đã lưu ($currentSavedSpecieType)');
        // Ưu tiên sử dụng specieType đã lưu
        expectedSpecieType = currentSavedSpecieType;
      }
    } else {
      // Chưa có specieType được lưu, lưu specieType từ livestockInfo
      print('Lưu specieType từ livestock: $expectedSpecieType');
      SpecieHelper.setCurrentSpecieTypeForVaccination(expectedSpecieType);
    }

    // Nếu có expectedSpecieType truyền vào, kiểm tra xem có khớp với specieType đã lưu không
    if (widget.expectedSpecieType != null) {
      print('Có expectedSpecieType truyền vào: ${widget.expectedSpecieType}');

      if (widget.expectedSpecieType != expectedSpecieType) {
        print(
            'CẢNH BÁO: SpecieType truyền vào (${widget.expectedSpecieType}) khác với specieType hiện tại ($expectedSpecieType)');

        // Ưu tiên sử dụng expectedSpecieType nếu nó khớp với specieType đã lưu
        if (SpecieHelper.isSpecieTypeMatchingCurrent(
            widget.expectedSpecieType!)) {
          expectedSpecieType = widget.expectedSpecieType!;
          print('Sử dụng specieType truyền vào: $expectedSpecieType');
        } else {
          print(
              'Không sử dụng specieType truyền vào vì không khớp với specieType đã lưu');
        }
      }
    }

    // Nếu nhập mã thẻ tai, lấy specieType từ dropdown đã chọn
    int? inputSpecieType = isQrScan ? null : _specieTypesMap[_selectedSpecie];

    if (!isQrScan && inputSpecieType == null) {
      if (mounted && !_isShowingDialog) {
        _showErrorDialog(
            'Lỗi', 'Loài không hợp lệ, vui lòng chọn lại loài', false);
      }
      return;
    }

    // Nếu nhập thủ công, so sánh với specieType đã lưu trước đó
    if (!isQrScan && inputSpecieType != null) {
      print(
          'So sánh specieType từ dropdown ($inputSpecieType) với specieType đã lưu (${SpecieHelper.getCurrentSpecieTypeForVaccination()})');

      // Nếu specieType từ dropdown khác với specieType đã lưu, hiển thị lỗi
      if (SpecieHelper.getCurrentSpecieTypeForVaccination() != -1 &&
          inputSpecieType !=
              SpecieHelper.getCurrentSpecieTypeForVaccination()) {
        if (mounted && !_isShowingDialog) {
          _showErrorDialog(
              'Lỗi',
              'Loài đã chọn không khớp với loài từ bước trước (${SpecieHelper.getSpecieNameFromType(SpecieHelper.getCurrentSpecieTypeForVaccination())}). Vui lòng chọn đúng loài.',
              false);
        }
        return;
      }
    }

    // Sử dụng dữ liệu từ API để kiểm tra tính nhất quán
    bool isValid = false;
    String errorMessage = '';

    // Lấy dữ liệu chuẩn từ API
    final String correctLivestockId = widget.livestockInfo!.livestockId;
    final String correctInspectionCode = widget.livestockInfo!.inspectionCode;

    print('Kiểm tra tính nhất quán:');
    print('- Phương thức: ${isQrScan ? "Quét QR" : "Nhập mã thẻ tai"}');
    print('- ExpectedSpecieType: $expectedSpecieType');
    print('- SpecieType từ dropdown: $inputSpecieType');
    print(
        '- SpecieType đã lưu: ${SpecieHelper.getCurrentSpecieTypeForVaccination()}');

    if (isQrScan) {
      // Kiểm tra mã QR (livestockId)
      if (inputValue == correctLivestockId) {
        // Khi quét QR, chúng ta không thể nhập specieType trực tiếp
        // Nhưng chúng ta sử dụng specieType đã lưu từ các bước trước
        isValid = true;
        print('QR khớp: Input=$inputValue, Expected=$correctLivestockId');
        print('SpecieType từ livestockInfo: $expectedSpecieType');
      } else {
        errorMessage =
            'Mã QR không khớp với vật nuôi đã chọn. Vui lòng quét đúng mã thẻ tai.';
        print('QR không khớp: Input=$inputValue, Expected=$correctLivestockId');
      }
    } else {
      // Kiểm tra mã thẻ tai (inspectionCode)
      if (inputValue == correctInspectionCode) {
        // Kiểm tra specieType có khớp không
        // Ở đây chúng ta đã biết inputSpecieType phải khớp với specieType đã lưu
        // từ bước kiểm tra bên trên, nên coi như đã hợp lệ
        isValid = true;
        print(
            'Mã thẻ tai khớp: Input=$inputValue, Expected=$correctInspectionCode');
        print(
            'SpecieType khớp: Input=$inputSpecieType, Saved=${SpecieHelper.getCurrentSpecieTypeForVaccination()}');
      } else {
        errorMessage =
            'Mã thẻ tai không khớp với vật nuôi đã chọn. Vui lòng nhập đúng mã thẻ tai.';
        print(
            'Mã thẻ tai không khớp: Input=$inputValue, Expected=$correctInspectionCode');
      }
    }

    // Thêm kiểm tra cuối cùng để lưu lại specieType đã chọn khi sử dụng nhập thông tin
    if (!isQrScan && isValid && inputSpecieType != null) {
      // Lưu specieType đã chọn để sử dụng trong API
      print('Cập nhật specieType đã lưu: $inputSpecieType');
      SpecieHelper.setCurrentSpecieTypeForVaccination(inputSpecieType);
    }

    // Xử lý dựa trên kết quả kiểm tra
    if (isValid) {
      // Nếu thông tin khớp, tiến hành xác nhận tiêm
      print('Thông tin khớp với dữ liệu API. Tiếp tục xác nhận tiêm.');

      // Lấy specieType cuối cùng
      final selectedSpecieType =
          SpecieHelper.getCurrentSpecieTypeForVaccination() != -1
              ? SpecieHelper.getCurrentSpecieTypeForVaccination()
              : expectedSpecieType;

      // Chuyển đến trang xác nhận tiêm
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VaccinationConfirmPage(
            livestockInfo: widget.livestockInfo!,
            selectedDiseases: widget.selectedDiseases!,
            isQrConfirmation: isQrScan,
            selectedSpecieType: selectedSpecieType,
          ),
        ),
      );
    } else {
      // Hiển thị thông báo lỗi nếu không khớp
      if (mounted && !_isShowingDialog) {
        _showErrorDialog('Lỗi xác thực', errorMessage, isQrScan);
      }
    }
  }

  Future<void> _searchInfo() async {
    if (_formKey.currentState!.validate()) {
      // Lấy mã thẻ tai
      final String inspectionCode = _tagIdController.text.trim();

      if (inspectionCode.isEmpty) {
        return;
      }

      if (widget.procurementId == null) {
        print('Không tìm thấy thông tin gói thầu');
        if (mounted && !_isShowingDialog) {
          _showErrorDialog('Lỗi', 'Không tìm thấy thông tin gói thầu', false);
        }
        return;
      }

      // Xử lý theo chế độ scan
      if (widget.mode == ScanMode.search) {
        // Sử dụng phương thức tìm kiếm bằng mã thẻ tai
        _handleSearchModeByInspectionCode(inspectionCode);
      } else if (widget.mode == ScanMode.vaccination) {
        // Trong chế độ xác nhận tiêm, vẫn cần kiểm tra mã thẻ tai
        // Truyền mã thẻ tai và đánh dấu isQrScan = false
        _checkAndHandleVaccination(inspectionCode, isQrScan: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy tiêu đề tương ứng với mode
    final String pageTitle = widget.title ??
        (widget.mode == ScanMode.search
            ? 'Quét QR kiểm tra thông tin'
            : 'Quét QR xác nhận tiêm');

    // Lấy hướng dẫn quét tương ứng với mode
    String scanGuide = widget.scanInstruction ??
        (widget.mode == ScanMode.search
            ? 'Quét mã QR để xem thông tin vật nuôi'
            : 'Quét QR trên thẻ tai để xác nhận tiêm các bệnh');

    // Thêm thông tin vật nuôi vào hướng dẫn nếu có
    if (widget.mode == ScanMode.vaccination && widget.livestockInfo != null) {
      scanGuide +=
          '\nMã thẻ tai: ${widget.livestockInfo!.inspectionCode} - ${widget.livestockInfo!.specieName}';
    }

    // Button text tương ứng với mode
    final String buttonText =
        widget.mode == ScanMode.search ? 'Kiểm tra thông tin' : 'Xác nhận tiêm';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(scanGuide,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Hoặc',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 86, child: Text('Mã thẻ tai')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _tagIdController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã thẻ tai';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 86, child: Text('Loài')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isLoadingSpecies
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSpecie,
                                  icon: const Icon(Icons.arrow_drop_down),
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
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.mode == ScanMode.search ? 150 : 120,
                      child: ElevatedButton(
                        onPressed: _searchInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
    );
  }
}
