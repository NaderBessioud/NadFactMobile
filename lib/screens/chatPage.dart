import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:nadfact2/DataService.dart';
import 'package:nadfact2/models/chatMessageModel.dart';
import 'package:nadfact2/models/chatUsersModel.dart';
import 'package:nadfact2/widgets/conversationList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();

}


class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  DataService dataService = DataService();
  List<ChatUsers> chatUsers = [];
  final String webSocketUrl = 'ws://192.168.1.18:8080/ERPPro/nadfactmobile';
  late StompClient _client;



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

    fetchUsers();

  }

  void onConnectCallback(StompFrame connectFrame) {
    _client.subscribe(
        destination: '/topic/messages',
        headers: {},
        callback: (frame) {

          Map<String, dynamic> jsonResponse = jsonDecode(frame.body!);
          ChatMessage msg=ChatMessage.fromJson(jsonResponse);
          for(int i=0;i<chatUsers.length;i++) {
            if(chatUsers[i].idU == msg.sender.idU ||msg.reciever.idU ==chatUsers[i].idU)
              setState(() {
                chatUsers[i].content = msg.content;
                chatUsers[i].day = msg.day;
                chatUsers[i].seen = msg.seen;

              });
          }




          // Received a frame for this subscription

        });

    _client.subscribe(
        destination: '/topic/online',
        headers: {},
        callback: (frame) {
          print(frame.body);
          // Received a frame for this subscription

            int id =int.parse(frame.body!);
          for(int i=0;i<chatUsers.length;i++) {
            if (chatUsers[i].idU == id) {
              setState(() {
                chatUsers[i].online = true;// Update state with fetched invoices
              });
            }
          }



        });
    _client.subscribe(
        destination: '/topic/offline',
        headers: {},
        callback: (frame) {
          print(frame.body);
          // Received a frame for this subscription

          int id =int.parse(frame.body!);
          for(int i=0;i<chatUsers.length;i++) {
            if (chatUsers[i].idU == id) {

              setState(() {
                chatUsers[i].online = false; // Update state with fetched invoices
              });
            }
          }



        });
  }
  @override
  void dispose() {
    // Close WebSocket connection when widget is disposed

    super.dispose();
  }

  void updateMsg(ChatMessage newmsg) async {



    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId != null) {





        for(int i=0;i<chatUsers.length;i++) {
          if(newmsg.sender.idU==userId! ||newmsg.reciever.idU==userId! ){


            setState(() {
              chatUsers[i].content = newmsg.content; // Update state with fetched invoices
            });

        }

      }

    }
  }

  void fetchUsers() async {
    try {

      List<ChatUsers> fetchedUsers = await dataService.fetchIChatUser();
      setState(() {
        chatUsers = fetchedUsers; // Update state with fetched invoices
      });
    } catch (e) {
      // Handle error
      print('Error fetching users: $e');
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
        title: Text('Chat',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Conversations",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),

                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16,left: 16,right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Colors.grey.shade100
                      )
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return ConversationList(
                    usr:chatUsers[index]

                );
              },
            )
          ],
        ),
      ),
    );
  }
}