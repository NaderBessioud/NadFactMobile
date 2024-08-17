import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/models/UserModel.dart';
import 'package:nadfact2/screens/LoginPage.dart';
import 'package:nadfact2/screens/UpdatePasswordPage.dart';
import 'package:nadfact2/screens/UpdateProfilePage.dart';
import 'package:nadfact2/screens/chatPage.dart';
import 'package:nadfact2/utils/global.colors.dart';
import 'package:nadfact2/widgets/ItemProfile.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Profil extends StatefulWidget{

  @override
  _ProfildState createState() => _ProfildState();
}


class _ProfildState extends State<Profil>{
  DataService service = new DataService();
  String _base64Image="";
  String name="";
  String addr="";
  String email="";



  Future<void> _logout() async {
    service.Signout();
    // Redirige vers la page de connexion
    Get.offAll(()=>Loginpage(),
      transition: Transition.rightToLeft, // Animation de transition
      duration: Duration(seconds: 1),   // Durée de l'animation
      curve: Curves.easeInOut, );
  }




  @override
  void initState() {
    super.initState();
     service.fetchUserById().then((user){


       setState(() {
         email = user.email;
         addr = user.addresse;
         name = user.libelle;
       });
     });

  }


  Future<String> fetchBase64Image() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageName = prefs.getString('image');
    if (imageName == null || imageName.isEmpty) {
      throw Exception('No image name found');
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.18:8080/ERPPro/home/downloadImagemobil?name=$imageName'),

    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load image');
    }
  }






  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64Decode(_base64Image);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          color: Colors.white,
        ),
        title: Text('Profil',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: fetchBase64Image(), // Function to fetch the Base64 image
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  String base64Image = snapshot.data!;
                  String base64String = base64Image.split(',').last;
                  Uint8List imageBytes = base64Decode(base64String);

                  return CircleAvatar(
                    radius: 70,
                    backgroundImage: MemoryImage(imageBytes),
                  );
                } else {
                  return Text('No image data');
                }
              },
            ),
            const SizedBox(height: 20),
            ItemProfile(title: "Name", subtitle: name, icondata: CupertinoIcons.person,email: email,addr: addr,),
            const SizedBox(height: 10),
            ItemProfile(title: "Email", subtitle: email, icondata: CupertinoIcons.mail,email: email,addr: addr),
            const SizedBox(height: 10),
            ItemProfile(title: "Address", subtitle: addr, icondata: CupertinoIcons.location,email: email,addr: addr),
            const SizedBox(height: 20),
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => Get.to(() => UpdateProfile(email: email,addr: addr)),
                      child: const Text("Modifier profile")
                  ),
                  const SizedBox(width: 20),

                  ElevatedButton(
                      onPressed: () => Get.to(() => UpdatePassword()),
                      child: const Text("Modifier mot de passe")
                  ),

                ],
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                      onPressed: () =>  _logout(),
                      child: const Text("déconnexion")
                  )
                ],
              )
            ],
          ),
        )

          ],
        ),
      ),
    );
  }
}