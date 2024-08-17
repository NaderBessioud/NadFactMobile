import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/models/chatMessageModel.dart';
import 'package:nadfact2/models/chatUsersModel.dart';
import 'package:nadfact2/screens/chatDetailPage.dart';


import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';


class ConversationList extends StatefulWidget{
  ChatUsers usr;
  ConversationList({required this.usr});
  @override
  _ConversationListState createState() => _ConversationListState();
}


class _ConversationListState extends State<ConversationList> {
  final String webSocketUrl = 'ws://192.168.1.18:8080/ERPPro/nadfactmobile';
  late StompClient _client;
  DataService service=new DataService();


  @override
  void initState() {

    super.initState();
    _client = StompClient(
      config: StompConfig(
        url: webSocketUrl,
        onConnect: onConnectCallback,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        onStompError: (StompFrame frame) => print('Stomp Error: ${frame.body}'),
        onWebSocketDone: () => print('WebSocket Done'),
        onDebugMessage: (String message) => print('Debug: $message'),
      ),
    );
    _client.activate();


  }
  @override
  void dispose() {
    _client.deactivate();

    super.dispose();
  }

  void onConnectCallback(StompFrame connectFrame) {

    _client.subscribe(
        destination: '/topic/messages',
        headers: {},
        callback: (frame) {

          Map<String, dynamic> jsonResponse = jsonDecode(frame.body!);
          ChatMessage msg=ChatMessage.fromJson(jsonResponse);
          updateMsg(msg);



          // Received a frame for this subscription

        });

    _client.subscribe(
        destination: '/topic/online',
        headers: {},
        callback: (frame) {
          int id=int.parse(frame.body!);
          if(id==widget.usr.idU){
            setState(() {
              widget.usr.online = true; // Update state with fetched invoices
            });
          }

          // Received a frame for this subscription

        });

    _client.subscribe(
        destination: '/topic/offline',
        headers: {},
        callback: (frame) {
          int id=int.parse(frame.body!);
          if(id==widget.usr.idU){
            setState(() {
              widget.usr.online = false; // Update state with fetched invoices
            });
          }

          // Received a frame for this subscription

        });
  }



  void updateMsg(ChatMessage newmsg) async {



    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId != null) {



      if(newmsg.sender.idU==userId! ||newmsg.reciever.idU==userId! ){

        setState(() {
          widget.usr.content=newmsg.content;
          widget.usr.day = newmsg.day;
          widget.usr.seen = newmsg.seen;
        });

      }

    }
  }
  String imageUrl(String imageName) {
    return 'http://localhost:8080/ERPPro/images/$imageName';
  }



  Future<String> fetchBase64Image() async {

    String imageName = widget.usr.image;


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
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetailPage(
            username: widget.usr.fullname,
            image: widget.usr.image,
            online: widget.usr.online,
            idr: widget.usr.idU,
          );
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  FutureBuilder<String>(
                    future: fetchBase64Image(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              maxRadius: 30,
                              child: CircularProgressIndicator(),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: widget.usr.online ? Colors.green : Colors.red,
                                radius: 8,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              maxRadius: 30,
                              child: Icon(Icons.error),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: widget.usr.online ? Colors.green : Colors.red,
                                radius: 8,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasData) {
                        String base64Image = snapshot.data!;
                        String base64String = base64Image.split(',').last;
                        Uint8List imageBytes = base64Decode(base64String);
                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: MemoryImage(imageBytes),
                              maxRadius: 30,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: widget.usr.online ? Colors.green : Colors.red,
                                radius: 8,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              maxRadius: 30,
                              child: Icon(Icons.person),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: widget.usr.online ? Colors.green : Colors.red,
                                radius: 8,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.usr.fullname,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.usr.content,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: widget.usr.online ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.usr.day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.usr.online ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );

  }
}