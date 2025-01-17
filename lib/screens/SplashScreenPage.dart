import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nadfact2/screens/LoginPage.dart';
import 'package:nadfact2/utils/global.colors.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({Key? key }) :super(key: key);

  @override
  Widget build(BuildContext context){
    Timer(const Duration(seconds: 1), (){
      Get.to(Loginpage());
    });
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      body: const Center(
        child: Text(
          'NadFact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}