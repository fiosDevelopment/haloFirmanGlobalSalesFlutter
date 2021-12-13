import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  String uid;

  Follower(this.uid);
  Follower.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    uid = documentSnapshot["uID"];
  }
}
