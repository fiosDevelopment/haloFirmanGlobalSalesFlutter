import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart ' as firebase_storage;
import 'package:halo_firman_sales/models/followers.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import '../core.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserList> getUser(String uid) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("users").doc(uid).get();

      return UserList.fromDocumentSnapshot(documentSnapshot: _doc);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<PostList>> getPostList(String uid) {
    return _firestore
        .collection('posts')
        .where('uID', isEqualTo: uid)
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<PostList> retVal = [];
      query.docs.forEach((element) {
        retVal.add(PostList.fromDocumentSnapshot(element));
      });
      print(retVal);
      return retVal;
    });
  }

  Stream<List<Follower>> getFollowersList(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<Follower> value = [];
      query.docs.forEach((element) {
        value.add(Follower.fromDocumentSnapshot(element));
      });
      return value;
    });
  }

  Future savePostingToServer(croppedFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      File file = File(croppedFile);
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
      final compressedImageFile = File('$path/img_$imageTimeStamp.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 50));
      String filePath = 'post/$imageTimeStamp';
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref(filePath);
      firebase_storage.UploadTask task = ref.putFile(compressedImageFile);
      firebase_storage.TaskSnapshot snapshot = await task;
      String result = await snapshot.ref.getDownloadURL();
      return result;
    } catch (e) {
      print('error');
    }
  }

  Future<void> tambahPosting(String content, String uid, String caption) async {
    try {
      await _firestore.collection('posts').add({
        'dateCreated': Timestamp.now(),
        'content': content,
        'caption': caption,
        'uID': uid,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
