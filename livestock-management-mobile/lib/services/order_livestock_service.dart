import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class OrderLivestockService {
  Future<Map<String, dynamic>> addLivestockToOrder({
    required String orderId,
    required String livestockId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('auth_token');
    if (userId == null) {
      return {'success': false, 'message': 'Không tìm thấy userId'};
    }
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/order-management/add-livestock-to-order/$orderId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'livestockId': livestockId,
        'requestedBy': userId,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Thành công'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Thất bại'};
      }
    } else {
      return {'success': false, 'message': 'Lỗi mạng hoặc máy chủ'};
    }
  }
}
