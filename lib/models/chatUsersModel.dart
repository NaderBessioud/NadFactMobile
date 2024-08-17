

class ChatUsers{
   int idU;
   String fullname;
   String email;
   bool online;
   String image;
   int nbmsg;
   String content;
   String day;
   bool seen;
  ChatUsers({required this.idU,required this.fullname,required this.email,required this.online,required this.image,required this.nbmsg,required this.content,required this.day,required this.seen});

   factory ChatUsers.fromJson(Map<String, dynamic> json) {
     if(json['day'] != "null"){
       return ChatUsers(
         idU: json['idU'],
         fullname: json['fullname'],
         email: json['email'],
         online: json['online'],
         image: json['image'],
         nbmsg: json['nbmsg'],
         content: json['content'],
         day: json['day'],
         seen: json['seen'],
       );
     }
     else{
       return ChatUsers(
         idU: json['idU'],
         fullname: json['fullname'],
         email: json['email'],
         online: json['online'],
         image: json['image'],
         nbmsg: json['nbmsg'],
         content: json['content'],
         day: "",
         seen: json['seen'],
       );
     }

   }
}

