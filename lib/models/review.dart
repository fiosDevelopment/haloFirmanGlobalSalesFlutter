import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String id;
  String uid;
  String content;
  int rating;
  int createdAt;

  Review(this.id, this.content, this.uid, this.rating, this.createdAt);
  Review.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.id;
    uid = documentSnapshot['uID'];
    content = documentSnapshot["content"];
    rating = documentSnapshot["rating"];
    createdAt = documentSnapshot["createdAt"];
  }
}
