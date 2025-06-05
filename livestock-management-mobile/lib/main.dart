import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const LivestockApp());
}

class LivestockApp extends StatelessWidget {
  const LivestockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livestock mobile',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Không tìm thấy trang')),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
