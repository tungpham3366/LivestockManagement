import 'package:flutter/material.dart';
import '../models/livestock_info_model.dart';
import '../models/disease_model.dart';

class VaccinationConfirmPageCustom extends StatelessWidget {
  final LivestockInfo livestockInfo;
  final Disease selectedDisease;
  final Medicine selectedMedicine;

  const VaccinationConfirmPageCustom({
    Key? key,
    required this.livestockInfo,
    required this.selectedDisease,
    required this.selectedMedicine,
  }) : super(key: key);

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
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text: 'Mã thẻ tai: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: livestockInfo.inspectionCode),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text: 'Giống: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: livestockInfo.specieName),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text: 'Màu lông: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: livestockInfo.color),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text: 'Thuốc: ',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(text: selectedMedicine.name),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text: 'Bệnh: ',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(text: selectedDisease.name),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Lịch sử tiêm chủng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Column(
              children: livestockInfo.vaccinationInfos.isEmpty
                  ? [
                      Card(
                        color: Colors.grey[100],
                        child: const ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title:
                              Text('Hiện không có lịch sử nào được ghi nhận'),
                        ),
                      ),
                    ]
                  : livestockInfo.vaccinationInfos
                      .map((info) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.vaccines,
                                  color: Colors.blue),
                              title: Text(info.diseaseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Số lần tiêm: ${info.numberOfVaccination}'),
                            ),
                          ))
                      .toList(),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Gọi API xác nhận tiêm ở đây
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xác nhận tiêm!')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Xác nhận'),
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
