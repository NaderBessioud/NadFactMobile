import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nadfact2/screens/LogoAnimPage.dart';
import 'package:nadfact2/screens/SplashScreenPage.dart';
import 'package:nadfact2/screens/homePage.dart';
import 'invoice_list.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NadFact',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
