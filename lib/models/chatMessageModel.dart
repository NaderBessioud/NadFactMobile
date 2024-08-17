import 'package:flutter/cupertino.dart';
import 'package:nadfact2/models/UserModel.dart';

class ChatMessage{
  int idM;
  String content;
  String hour;
  DateTime date;
  String day;
  bool seen;
  User sender;
  User reciever;

  ChatMessage({required this.idM, required this.content,required this.hour, required this.date, required this.day,required this.seen, required this.sender, required this.reciever});
  factory ChatMessage.fromJson(Map<String, dynamic> json) {

    return ChatMessage(
      idM: json['idM'],
      content: json['content'],
      hour: json['hour'],
      date: DateTime.parse(json['date']),
      day: json['day'],
      seen: json['seen'],
      sender: User.fromJson(json['sender']),
      reciever: User.fromJson(json['reciever']),
    );
  }


}