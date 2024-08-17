import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:nadfact2/DataService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:get/get.dart';

class PdfViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;
  final int id;

  DataService service=new DataService();

  PdfViewerPage({required this.pdfBytes, required this.fileName, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Chat',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(FontAwesomeIcons.angleLeft),
            color: Colors.white,
          ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => service.downloadPDFEmulator(context,fileName,pdfBytes),
            color: Colors.white,
          ),
        ],
      ),
      body: PDFView(
        pdfData: pdfBytes,
      ),
    );
  }
}