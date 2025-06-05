// Lớp hỗ trợ quản lý thông tin loài và specieType
class SpecieHelper {
  // Map tên loài => specieType (phải đồng bộ giữa các trang)
  static final Map<String, int> specieTypeMap = {
    'TRÂU': 0,
    'BÒ': 1,
    'LỢN': 2,
    'GÀ': 3,
    'DÊ': 4,
    'CỪU': 5,
    'NGỰA': 6,
    'LA': 7,
    'LỪA': 8
  };

  // Biến lưu trữ specieType hiện tại cho quy trình xác nhận
  static int _currentSpecieTypeForVaccination = -1;

  // Phương thức lấy specieType từ tên loài
  static int getSpecieTypeFromName(String specieName) {
    return specieTypeMap[specieName.toUpperCase()] ?? 0;
  }

  // Phương thức lấy tên loài từ specieType
  static String getSpecieNameFromType(int specieType) {
    final entry = specieTypeMap.entries.firstWhere(
      (e) => e.value == specieType,
      orElse: () => const MapEntry('KHÔNG XÁC ĐỊNH', 0),
    );
    return entry.key;
  }

  // Phương thức kiểm tra tính hợp lệ của specieType
  static bool isValidSpecieType(int? specieType) {
    if (specieType == null) return false;
    return specieTypeMap.values.contains(specieType);
  }

  // Danh sách tên loài mặc định
  static List<String> getDefaultSpecies() {
    return ['TRÂU', 'BÒ', 'LỢN', 'GÀ', 'DÊ', 'CỪU', 'NGỰA', 'LA', 'LỪA'];
  }

  // Lưu specieType hiện tại cho quá trình xác nhận
  static void setCurrentSpecieTypeForVaccination(int specieType) {
    print('Lưu specieType hiện tại: $specieType');
    _currentSpecieTypeForVaccination = specieType;
  }

  // Lấy specieType hiện tại đã lưu
  static int getCurrentSpecieTypeForVaccination() {
    return _currentSpecieTypeForVaccination;
  }

  // Kiểm tra xem specieType có khớp với giá trị hiện tại không
  static bool isSpecieTypeMatchingCurrent(int specieType) {
    // Nếu chưa có specieType được lưu (-1), thì luôn coi là khớp
    if (_currentSpecieTypeForVaccination == -1) return true;

    // Nếu đã có specieType lưu trữ, so sánh với giá trị cần kiểm tra
    return specieType == _currentSpecieTypeForVaccination;
  }

  // Reset specieType hiện tại
  static void resetCurrentSpecieType() {
    _currentSpecieTypeForVaccination = -1;
  }
}
