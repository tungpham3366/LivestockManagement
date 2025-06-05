import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/procurement_list_page.dart';
import '../pages/procurement_detail_page.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/livestock_info_page.dart';
import '../pages/vaccination_confirm_page.dart';
import '../pages/single_vaccination_page.dart';
import '../pages/vaccinations_list_page.dart';
import '../pages/import_page.dart';
import '../pages/import_menu_page.dart';
import '../pages/export_menu_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String procurementList = '/procurement-list';
  static const String procurementDetail = '/procurement-detail';
  static const String qrScanner = '/qr-scanner';
  static const String livestockInfo = '/livestock-info';
  static const String vaccinationConfirm = '/vaccination-confirm';
  static const String singleVaccination = '/single-vaccination';
  static const String vaccinationsList = '/vaccinations-list';
  static const String import = '/import';
  static const String importMenu = '/import-menu';
  static const String exportMenu = '/export-menu';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    procurementList: (context) => const ProcurementListPage(),
    singleVaccination: (context) => const SingleVaccinationPage(),
    vaccinationsList: (context) => const VaccinationsListPage(),
    import: (context) => const ImportPage(),
    importMenu: (context) => const ImportMenuPage(),
    exportMenu: (context) => const ExportMenuPage(),
  };

  // Các routes với tham số động
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case procurementList:
        return MaterialPageRoute(builder: (_) => const ProcurementListPage());
      case singleVaccination:
        return MaterialPageRoute(builder: (_) => const SingleVaccinationPage());
      case vaccinationsList:
        return MaterialPageRoute(builder: (_) => const VaccinationsListPage());
      case import:
        return MaterialPageRoute(builder: (_) => const ImportPage());
      case importMenu:
        return MaterialPageRoute(builder: (_) => const ImportMenuPage());
      case exportMenu:
        return MaterialPageRoute(builder: (_) => const ExportMenuPage());
      case procurementDetail:
        final String procurementId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProcurementDetailPage(procurementId: procurementId),
        );
      case qrScanner:
        // Xử lý trường hợp chỉ truyền procurementId
        if (settings.arguments is String) {
          final String procurementId = settings.arguments as String;
          print("Route QrScannerPage với procurementId: $procurementId");
          return MaterialPageRoute(
            builder: (_) => QrScannerPage(procurementId: procurementId),
          );
        }
        // Xử lý trường hợp truyền Map với các thông tin
        else if (settings.arguments is Map<String, dynamic>) {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;

          // Kiểm tra xem có selectedDiseases và livestockInfo không
          if (args.containsKey('selectedDiseases') &&
              args.containsKey('livestockInfo')) {
            return MaterialPageRoute(
              builder: (_) => VaccinationConfirmPage(
                livestockInfo: args['livestockInfo'],
                selectedDiseases: args['selectedDiseases'],
              ),
            );
          } else {
            // Trường hợp chỉ có procurementId
            final String? procurementId = args['procurementId'] as String?;
            return MaterialPageRoute(
              builder: (_) => QrScannerPage(procurementId: procurementId),
            );
          }
        } else {
          // Trường hợp không có arguments
          return MaterialPageRoute(
            builder: (_) => const QrScannerPage(),
          );
        }
      case livestockInfo:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;

        // Thêm log để debug
        print('AppRoutes.livestockInfo - arguments:');
        print(args);

        return MaterialPageRoute(
          builder: (_) => LivestockInfoPage.fromArguments(args),
        );
      case vaccinationConfirm:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VaccinationConfirmPage(
            livestockInfo: args['livestockInfo'],
            selectedDiseases: args['selectedDiseases'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Không tìm thấy trang')),
          ),
        );
    }
  }
}
