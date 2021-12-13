import 'package:cloud_firestore/cloud_firestore.dart';

class ChatList {
  String chatid;
  String chatwith;
  String lastchat;
  bool isTyping;

  ChatList(this.chatid, this.chatwith, this.lastchat, this.isTyping);
  ChatList.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    chatid = documentSnapshot['chatID'];
    chatwith = documentSnapshot['chatWith'];
    lastchat = documentSnapshot["lastChat"];
    isTyping = documentSnapshot["isTyping"];
  }
}
