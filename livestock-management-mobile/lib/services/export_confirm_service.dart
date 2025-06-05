import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/export_confirm_model.dart';

class ExportConfirmService {
  Future<List<ExportConfirmModel>> fetchExportOrders() async {
    final url = Uri.parse(AppConstants.baseUrl +
        '/api/order-management/get-list-orders-to-export');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final items = body['data']['items'] as List<dynamic>;
      return items.map((e) => ExportConfirmModel.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách đơn xuất trại');
    }
  }

  Future<bool> confirmExported(String orderId, String userId) async {
    final url = Uri.parse(AppConstants.baseUrl +
        '/api/order-management/confirm-exported/$orderId?requestedBy=$userId');
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true) {
        return true;
      } else {
        throw Exception(body['message'] ?? 'Xác nhận xuất trại thất bại');
      }
    } else {
      throw Exception('Lỗi xác nhận xuất trại');
    }
  }
}
