import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/models/chatMessageModel.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';


import 'package:visibility_detector/visibility_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';



class ChatDetailPage extends StatefulWidget{
  DataService dataService = DataService();
  List<ChatMessage> messages = [];
  String username;
  String image;
  bool online;
  int idr;

  ChatDetailPage({required this.username,required this.image,required this.online,required this.idr});
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  DataService service=new DataService();
  String _base64Image="";
  final String webSocketUrl = 'ws://192.168.1.18:8080/ERPPro/nadfactmobile';
  late StompClient _client;
  final TextEditingController msgController=TextEditingController();
  int id=0;

  ScrollController listScrollController = ScrollController();





  Future<String> fetchBase64Image() async {

    String imageName = widget.image;


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

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500), () {
      _scrollToBottom();
    });
    });
    fetchMSG();

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
         if(id==widget.idr){
           setState(() {
             widget.online = true; // Update state with fetched invoices
           });
         }

          // Received a frame for this subscription

        });

    _client.subscribe(
        destination: '/topic/offline',
        headers: {},
        callback: (frame) {
          int id=int.parse(frame.body!);
          if(id==widget.idr){
            setState(() {
              widget.online = false; // Update state with fetched invoices
            });
          }

          // Received a frame for this subscription

        });
  }




  @override
  void dispose() {
    // Close WebSocket connection when widget is disposed
    _client.deactivate();
    super.dispose();
  }

  markMsgAsRead(int idm) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

     ;
    if(idm != prefs.getInt('id')){
      widget.dataService.markMessageAsRead(idm).then((_) {}).catchError((error) {
        print('Failed to mark message as read: $error');
      });
    }

  }
  void updateMsg(ChatMessage newmsg) async {



    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId != null) {



      if(newmsg.sender.idU==userId! ||newmsg.reciever.idU==userId! ){

        setState(() {
          widget.messages.add(newmsg);
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 200), () {
            _scrollToBottom();
          });
        });
      }

    }
  }
  void _scrollToBottom() {
    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;

      listScrollController.jumpTo(position);
    }
  }
  void fetchMSG() async {

      int id=1;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('id');

        if (userId != null) {
          setState(() {
            id = userId;
          });

      List<ChatMessage> fetchedMessages = await widget.dataService.fetchIChatMSG(id,widget.idr);
      setState(() {
        widget.messages = fetchedMessages; // Update state with fetched invoices
      });

        }

  }

  Future<void> sendMessageAndScroll() async {
    await service.sendMessage(msgController.text, widget.idr);

  }
  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId != null) {
      setState(() {
        id = userId; // Parse the non-null String to int
      });
    }

  }


  @override
  Widget build(BuildContext context) {






    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,

        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                SizedBox(width: 2),
                FutureBuilder<String>(
                  future: fetchBase64Image(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        maxRadius: 20,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        maxRadius: 20,
                        child: Icon(Icons.error),
                      );
                    } else if (snapshot.hasData) {
                      String base64Image = snapshot.data!;
                      String base64String = base64Image.split(',').last;
                      Uint8List imageBytes = base64Decode(base64String);
                      return CircleAvatar(
                        backgroundImage: MemoryImage(imageBytes),
                        maxRadius: 20,
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        maxRadius: 20,
                        child: Icon(Icons.person),
                      );
                    }
                  },
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.username,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        widget.online ? 'Online' : 'Offline',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.settings, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: listScrollController,

                  shrinkWrap: true,
                  itemCount: widget.messages.length,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    return VisibilityDetector(
                      key: Key(message.idM.toString()),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.5 && !message.seen) {
                         markMsgAsRead(message.idM);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment: (message.reciever.idU == id ? Alignment.topLeft : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (message.reciever.idU == id ? Colors.grey.shade200 : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              message.content,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: msgController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    FloatingActionButton(
                      onPressed: () {
                        sendMessageAndScroll();
                        },
                      child: Icon(Icons.send, color: Colors.white, size: 18),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}