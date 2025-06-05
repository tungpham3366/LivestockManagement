import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/export_choose_model.dart';

class ExportChooseService {
  Future<List<ExportOrderModel>> fetchOrders() async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/order-management/get-list-orders-to-choose');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data']['items'] as List;
      return items.map((e) => ExportOrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi lấy danh sách đơn lẻ');
    }
  }

  Future<List<ExportProcurementModel>> fetchProcurements() async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/procurement-management/get-list?status=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data']['items'] as List;
      return items.map((e) => ExportProcurementModel.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi lấy danh sách gói thầu');
    }
  }
}
