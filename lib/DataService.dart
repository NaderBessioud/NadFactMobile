import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nadfact2/invoice.dart';
import 'package:nadfact2/models/UserModel.dart';
import 'package:nadfact2/models/chatMessageModel.dart';
import 'package:nadfact2/models/chatUsersModel.dart';
import 'package:nadfact2/models/clientModel.dart';
import 'package:nadfact2/pdf_viewer_page.dart';
import 'package:nadfact2/screens/LoginPage.dart';
import 'package:nadfact2/screens/ProfilPage.dart';
import 'package:nadfact2/screens/homePage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;


class DataService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String baseUrl = 'http://192.168.1.18:8080/ERPPro/client';
  static const String baseUrlChat = 'http://192.168.1.18:8080/ERPPro/chat';
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

;    return prefs.getString('token');
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {

      var user= await _googleSignIn.signIn();

      if(user != null){
        _sendEmailToServer(context,user.email);
      }
      //_sendTokenToServer(user);
    } catch (error) {
      print(error);
    }
  }

  /*Future<void> handleGoogleSignout() async {
    try {

       await _googleSignIn.signOut();


      //_sendTokenToServer(user);
    } catch (error) {
      print(error);
    }
  }*/

  Future<void> Signout() async {
    try {

      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
     String? email=prefs.getString("email");
      final response = await http.post(
        Uri.parse('http://192.168.1.18:8080/ERPPro/home/logout?email=$email'),
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('id');
        await prefs.remove('image');
        await prefs.remove('email');
      }else {
        print('Failed to logout with backend');
      }


      //_sendTokenToServer(user);
    } catch (error) {

    }
  }

  Future<void> _sendEmailToServer(BuildContext context,String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse('http://192.168.1.18:8080/ERPPro/home/loginWithGoogle?email=$email'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // Access fields directly from 'data'
        String msg = data['msg'];
        if(msg=="Bad Credentials"){
          _showTemporaryAlert(context,"Veuiller vérifier vos information");
        }
        else if(msg =="Not Exist"){
          _showTemporaryAlert(context,"Cet utilisateur n'esxiste pas");

        }

        else if(msg =="Disabled"){
          _showTemporaryAlert(context,"Cet utilisateur n'est pas actif");

        }
        else if(msg=="good"){

          prefs.setInt("id", data['user']['idU']);
          prefs.setString("token", data['token']);

          prefs.setString("email", data['user']['email']);
          prefs.setString("image", data['user']['image']);
          Get.to(HomePage());
        }
        else{
          print('Failed to authenticate with backend');
        }
      } else {
        print('Failed to authenticate with backend');
      }


  }

  Future<void> Signin(BuildContext context,String email,String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse('http://192.168.1.18:8080/ERPPro/home/login?email=$email&password=$pass'),


    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      // Access fields directly from 'data'
      String msg = data['msg'];
      if(msg=="Bad Credentials"){
        _showTemporaryAlert(context,"Veuiller vérifier vos information");
      }
      else if(msg =="Not Exist"){
        _showTemporaryAlert(context,"Cet utilisateur n'esxiste pas");

      }
      else if(msg =="Disabled"){
        _showTemporaryAlert(context,"Cet utilisateur n'est pas actif");

      }
      else if(msg=="good"){
        prefs.setInt("id", data['user']['idU']);
        prefs.setString("token", data['token']);
        prefs.setString("email", data['user']['email']);
        prefs.setString("image", data['user']['image']);
        Get.to(HomePage());
      }
      else{
        print('Failed to authenticate with backend');
      }
      // Use the data as needed
    } else {
      throw Exception('Failed to load data');
    }
  }


  Future<List<Invoice>> fetchInvoicesByClient() async {
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clientem=prefs.getString("email");
    final response = await http.get(Uri.parse('$baseUrl/FactureByClient/$clientem'),
      headers: {
        'Authorization': 'Bearer $token',
      },);

    if (response.statusCode == 200) {
      // Successful request
      Iterable jsonResponse = jsonDecode(response.body);

      return jsonResponse.map((invoiceJson) => Invoice.fromJson(invoiceJson)).toList();
    } else {
      // Handle errors
      throw Exception('Failed to load invoices');
    }
  }

  Future<void> validateFacture(int factureId) async {
    String? token = await getToken();
    final String endpoint = "/validateProforma/$factureId";

    try {
      final response = await http.put(
        Uri.parse(baseUrl + endpoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',

        },

      );

      if (response.statusCode == 200) {
        // Handle success
        print('Facture validated successfully');
      } else {
        // Handle other status codes (e.g., 404, 500)
        print('Failed to validate facture. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or exceptions
      print('Error validating facture: $e');
    }
  }

  Future<void> DenyFacture(int factureId) async {
    String? token = await getToken();
    final String endpoint = "/denyProforma/$factureId";

    try {
      final response = await http.put(
        Uri.parse(baseUrl + endpoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',

        },

      );

      if (response.statusCode == 200) {
        // Handle success
        print('Facture validated successfully');
      } else {
        // Handle other status codes (e.g., 404, 500)
        print('Failed to validate facture. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or exceptions
      print('Error validating facture: $e');
    }
  }


  Future<List<ChatUsers>> fetchIChatUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId=prefs.getInt("id");
    String? token = await getToken();
    final response = await http.get(Uri.parse('$baseUrl/UsersMobile/$clientId'),
      headers: {
        'Authorization': 'Bearer $token',
      },);

    if (response.statusCode == 200) {
      // Successful request
      Iterable jsonResponse = jsonDecode(response.body);

      return jsonResponse.map((usersJson) => ChatUsers.fromJson(usersJson)).toList();
    } else {
      // Handle errors
      throw Exception('Failed to load Users');
    }
  }


  Future<void> markMessageAsRead(int messageId) async {
    String? token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrlChat/readmsgbyid/$messageId'),
      headers: {
    'Authorization': 'Bearer $token',
    },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read');
    }
  }


  Future<List<ChatMessage>> fetchIChatMSG(int ids,int idr) async {
    String? token = await getToken();
    final response = await http.get(Uri.parse('$baseUrl/MessagesMobile/$ids/$idr'),
      headers: {
        'Authorization': 'Bearer $token',
      },);

    if (response.statusCode == 200) {
      // Successful request
      Iterable jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((chatjson) => ChatMessage.fromJson(chatjson)).toList();
    } else {
      // Handle errors
      throw Exception('Failed to load Users');
    }
  }

  Future<String> _getDownloadsDirectoryPath() async {
    try {
      if (Platform.isAndroid) {
        // Use Android-specific code to get the Downloads directory
        final String downloadsPath = await MethodChannel(
            'com.example.app/files')
            .invokeMethod('getDownloadsDirectory');
        return downloadsPath;
      } else {
        // For iOS or other platforms, use the application documents directory
        final Directory directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } on PlatformException catch (e) {
      print('Failed to get downloads directory: $e');
      // Fallback to the application documents directory
      final Directory directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> sendMessage(String content, int idr) async {
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? ids=prefs.getInt("id");
    try {
      var url = Uri.parse('$baseUrlChat/addMessage?content=$content&idr=$idr&ids=$ids');
      var response = await http.post(
        url,
        headers: {
      'Authorization': 'Bearer $token',
      },

      );

      if (response.statusCode == 200) {
        // Successfully added message
        print('Message sent successfully');
      } else {
        // Handle other status codes if needed
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Function to show the temporary alert
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

  Future<void> UpdateProfile(String email,String addr,String image) async {
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id=prefs.getInt("id");
    final response = await http.put(
      Uri.parse('http://192.168.1.18:8080/ERPPro/client/updateprofile?email=$email&addr=$addr&id=$id&image=$image'),
      headers: {
                'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
    Get.to(()=>Profil());
    } else {
      print('Failed to authenticate with backend');
    }


  }


  Future<void> UpdatePass(String pass) async {
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id=prefs.getInt("id");
    final response = await http.put(
      Uri.parse('http://192.168.1.18:8080/ERPPro/client/updatePass?pass=$pass&id=$id'),
      headers: {'Authorization': 'Bearer $token',},

    );

    if (response.statusCode == 200) {
      Get.to(()=>Profil());
    } else {
      print('Failed to authenticate with backend');
    }


  }


  Future<String> UploadImage(File _imageFile) async {
    if (_imageFile == null) return "";
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.18:8080/ERPPro/home/uploadImage'),
    );
    request.files.add(await http.MultipartFile.fromPath(
      'imageFile',
      _imageFile!.path,
    ));
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
      final responseData = await response.stream.bytesToString();
      return responseData;

    } else {

      print('Image upload failed with status: ${response.statusCode}');
      return "";

    }


  }


  Future<String> downloadImage(String name) async {

    final response = await http.post(
      Uri.parse('http://192.168.1.18:8080/ERPPro/home/downloadImageMobile?name=$name'),


    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to download image with status: ${response.statusCode}');
    }
  }


  Future<bool> CheckOldPass(String pass) async {
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id=prefs.getInt("id");
    final response = await http.post(
      Uri.parse('http://192.168.1.18:8080/ERPPro/client/checkoldpass?pass=$pass&id=$id'),
      headers: {'Authorization': 'Bearer $token',},

    );

    if (response.statusCode == 200) {
        return  jsonDecode(response.body);
    } else {
      print(response);
      print('Failed to authenticate with backend');
      return false;
    }


  }

  Future<Client> fetchUserById() async {
    String? token =await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id=prefs.getInt("id");
    final response = await http.get(
        Uri.parse('$baseUrl/clientById/$id'),
      headers: {
        'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Convert the response body to a JSON object.
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Convert the JSON object to a User object.
      return Client.fromJson(json);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> DisplayFacture(BuildContext context,int id) async {
    try {
      // Define the API endpoint


      // Convert the Facture object to a JSON string if needed (assuming it's necessary)

      // Send the POST request
      final http.Response response = await http.get(
        Uri.parse(baseUrl+"/previewFacture/$id"),


      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Get the document directory for saving the file
        final Uint8List pdfBytes = response.bodyBytes;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              pdfBytes: pdfBytes,
              fileName: 'facture.pdf',
              id: id,
            ),
          ),
        );
        // You can use a PDF viewer to open the file here
      } else {
        print('Failed to download the facture: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading facture: $e');
    }



  }


  Future<void> downloadPDF(BuildContext context,String fileName,Uint8List pdfBytes) async {
    // Check for storage permission
    if (await Permission.storage.request().isGranted) {
      // Get the downloads directory
      final Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        final String filePath = '${directory.path}/$fileName';

        // Save the PDF file
        final File file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facture downloaded and saved at $filePath')),
        );
        print('Facture downloaded and saved at $filePath');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }


  Future<void> downloadPDFEmulator(BuildContext context,String fileName,Uint8List pdfBytes) async {
    // Check for storage permission
    if (await Permission.storage.request().isGranted) {
      // Get the downloads directory
      final Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (downloadsDirectory != null && await downloadsDirectory.exists()) {
        final String filePath = '${downloadsDirectory.path}/$fileName';

        // Save the PDF file
        final File file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facture downloaded and saved at $filePath')),
        );
        print('Facture downloaded and saved at $filePath');
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloads directory not found.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }
}


