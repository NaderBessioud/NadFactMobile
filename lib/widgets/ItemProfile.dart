import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nadfact2/screens/UpdateProfilePage.dart';


class ItemProfile extends StatelessWidget{

  String title;
  String subtitle;
  IconData icondata;
  String email;
  String addr;
  ItemProfile({Key? key,required this.title, required this.subtitle, required this.icondata,required this.email, required this.addr}) :super(key: key);

  @override
  Widget build(BuildContext context){

    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(600),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0,5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
       ]
      ),
      child:  InkWell(
        onTap: ()=>Get.to(()=>UpdateProfile(email: email,addr: addr,)),
        child:  ListTile(
          title:  Text(title),
          subtitle: Text(subtitle),
          leading: Icon(icondata),
          trailing: Icon(Icons.arrow_forward,color: Colors.grey),
          tileColor: Colors.white,

        ),
      ),
  );
  }

}