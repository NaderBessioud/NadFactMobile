import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/utils/global.colors.dart';
import 'package:nadfact2/widgets/TextForm.dart';

class FormButton extends StatelessWidget{
  DataService service = new DataService();
  BuildContext context;
  String email;
  String pass;
  FormButton({Key? key,required this.context, required this.email, required this.pass}) :super(key: key);

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: (){

        service.Signin(context,email,pass);
      },
      child: Container(
        alignment: Alignment.center,
        height: 55,
        decoration: BoxDecoration(
          color: GlobalColors.mainColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ]
        ),
        child: const Text(
          "Sign in",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600
          ),
        ),
      ),

    );
  }

}