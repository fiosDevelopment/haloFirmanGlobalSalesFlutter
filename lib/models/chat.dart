import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String content;
  String idFrom;
  String idTo;
  bool isread;
  Timestamp timestamp;
  String type;

  Chat(this.content, this.idFrom, this.idTo, this.isread, this.timestamp,
      this.type);
  Chat.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    content = documentSnapshot['content'];
    idFrom = documentSnapshot['idFrom'];
    idTo = documentSnapshot['idTo'];
    isread = documentSnapshot['isread'];
    timestamp = documentSnapshot['timestamp'];
    type = documentSnapshot['type'];
  }
}
