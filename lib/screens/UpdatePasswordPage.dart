import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/screens/chatPage.dart';
import 'package:nadfact2/utils/global.colors.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class UpdatePassword extends StatefulWidget{

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}


class _UpdatePasswordState extends State<UpdatePassword>{
  final TextEditingController oldpassController=TextEditingController();
  final TextEditingController newpassController=TextEditingController();
  final TextEditingController newpassvController=TextEditingController();
  DataService service = new DataService();
  String _base64Image="";
  bool odlpassgood=false;


  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imgname = prefs.getString("image");
    String name="";
    if(imgname != null){
      name=imgname;
    }
    try {
      String base64Image = await service.downloadImage(name);

      _base64Image = base64Image;

    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<void> UpdatePass() async {
    odlpassgood= await  service.CheckOldPass(oldpassController.text);
    print(odlpassgood);

    if (newpassController.text != newpassvController.text){
      _showTemporaryAlert(context,"le 2 mot de passe ne correspondent pas");
    }
    else{
      if(!odlpassgood){
        _showTemporaryAlert(context,"Verrifier Votre ancien mot de passe");
      }
      else{
        service.UpdatePass(newpassController.text);
      }

    }



  }

  Future<void> CheckoldPass(BuildContext context) async {
    odlpassgood= await  service.CheckOldPass(newpassController.text);
    _showTemporaryAlert(context,"Veuillez verifier votre ancien mot de passe");
  }

  void _showTemporaryAlert(BuildContext context,String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulBuilder to access setState in the dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Start a timer to automatically dismiss the dialog after 2 seconds
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop(true); // Close dialog
            });

            // Return the AlertDialog
            return AlertDialog(
              title: Text('Attention !!!'),
              content: Text(msg),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
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
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          color: Colors.white,
        ),
        title: Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FutureBuilder<String>(
                        future: fetchBase64Image(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            String base64Image = snapshot.data!;
                            String base64String = base64Image.split(',').last;
                            Uint8List imageBytes = base64Decode(base64String);

                            return Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Text('No image data');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: oldpassController,
                      decoration: InputDecoration(
                        label: Text("ancien mdp"),

                        prefixIcon: Icon(Icons.lock_clock_outlined),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: GlobalColors.textColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: GlobalColors.mainColor),
                        ),
                      ),
                      obscureText:true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: newpassController,
                      decoration: InputDecoration(
                        label: Text("nouveau mdp"),
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: GlobalColors.textColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: GlobalColors.mainColor),
                        ),
                      ),
                      obscureText:true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: newpassvController,
                      decoration: InputDecoration(
                        label: Text("confirmer mdp"),
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: GlobalColors.textColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: GlobalColors.mainColor),
                        ),
                      ),
                      obscureText:true,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => UpdatePass(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColors.mainColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          "Modifier",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}