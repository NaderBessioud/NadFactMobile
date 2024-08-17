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
import 'package:http/http.dart' as http;

class UpdateProfile extends StatefulWidget{
  String email;
  String addr;
  UpdateProfile({required this.email,required this.addr});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}


class _UpdateProfileState extends State<UpdateProfile>{
   TextEditingController emailController=TextEditingController();
   TextEditingController addressController=TextEditingController();
  DataService service = new DataService();
  final picker = ImagePicker();
  File? _imageFile;
  String imagename="";

  String? base64String;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    addressController = TextEditingController(text: widget.addr);

  }



  Future<void> _updateprofile() async {

    service.UpdateProfile(emailController.text,addressController.text,imagename);

  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);


      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        imagename=await service.UploadImage(_imageFile!);
        Uint8List imgbyte = await pickedFile.readAsBytes();
        print("hawwww byteee========>"+imgbyte.toString());
        print("hawwww ism image========>"+imagename);
        setState(() {
          base64String = base64.encode(imgbyte);
        });



      } else {
        print('No image selected.');
      }

  }

  Future<String> fetchBase64Image() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageName1 = prefs.getString('image');
    if (imageName1 == null || imageName1.isEmpty) {
      throw Exception('No image name found');
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.18:8080/ERPPro/home/downloadImagemobil?name=$imageName1'),

    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load image');
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
              child: base64String != null
                  ? Image.memory(
                base64Decode(base64String!),
                fit: BoxFit.cover,
              )
                  : FutureBuilder<String>(
                future: fetchBase64Image(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    String base64Image = snapshot.data!;
                    base64String = base64Image.split(',').last;
                    Uint8List imageBytes = base64Decode(base64String!);

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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color(0xFFFFE400),
                      ),
                      child: InkWell(
                        onTap: () => _pickImage(),
                        child: Icon(
                          FontAwesomeIcons.camera,
                          color: GlobalColors.mainColor,
                          size: 20,
                        ),
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
                      controller: emailController,
                      decoration: InputDecoration(
                        label: Text(widget.email),
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: GlobalColors.textColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: GlobalColors.mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        label: Text(widget.addr),
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: GlobalColors.textColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: GlobalColors.mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => _updateprofile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColors.mainColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          "Modifier profil",
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