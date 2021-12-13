import 'package:cloud_firestore/cloud_firestore.dart';

class PostList {
  String caption;
  String content;

  PostList(this.caption, this.content);
  PostList.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    caption = documentSnapshot["caption"];
    content = documentSnapshot["content"];
  }
}
