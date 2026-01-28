import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(const TicketApp());
}

class TicketApp extends StatelessWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LiveWave',
      initialRoute: Routes.welcome, 
      onGenerateRoute: AppRoutes.onGenerateRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
    );
  }
}
