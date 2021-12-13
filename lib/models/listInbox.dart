import 'package:cloud_firestore/cloud_firestore.dart';

class ListInbox {
  String id;
  String content;
  String ref;
  String idSender;
  String timestamp;
  String type;

  ListInbox(this.id, this.content, this.ref, this.idSender, this.timestamp,
      this.type);
  ListInbox.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot["ID"];
    content = documentSnapshot["content"];
    ref = documentSnapshot["idReferensi"];
    idSender = documentSnapshot["idSender"];
    timestamp = documentSnapshot["timestamp"];
    type = documentSnapshot["type"];
  }
}
