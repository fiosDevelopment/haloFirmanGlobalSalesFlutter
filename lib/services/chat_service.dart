import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart ' as firebase_storage;
import 'package:path_provider/path_provider.dart';

import '../core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as Im;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatList>> getChatList(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chatlist')
        .where("lastChat", isNotEqualTo: "")
        .snapshots()
        .map((QuerySnapshot query) {
      List<ChatList> retVal = [];
      query.docs.forEach((element) {
        retVal.add(ChatList.fromDocumentSnapshot(element));
      });
      return retVal;
    });
  }

  Future<void> sendChat(String chatID, String myID, String selectedUserID,
      String content, String messageType, time) async {
    try {
      await _firestore
          .collection('chatroom')
          .doc(chatID)
          .collection(chatID)
          .doc(time.toString())
          .set({
        'idFrom': myID,
        'idTo': selectedUserID,
        'timestamp': time,
        'content': content,
        'type': messageType,
        'isread': false,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future sendImageToUserInChatRoom(croppedFile, chatID) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      File file = File(croppedFile);
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
      final compressedImageFile = File('$path/img_$imageTimeStamp.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 50));
      String filePath = 'chatrooms/$chatID/$imageTimeStamp';
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

  Future<void> updateChatRequestField(
      String id, String lastMessage, chatID, myID, selectedUserID) async {
    try {
      await _firestore
          .collection('users')
          .doc(id)
          .collection('chatlist')
          .doc(chatID)
          .set({
        'chatID': chatID,
        'chatWith': id == myID ? selectedUserID : myID,
        'lastChat': lastMessage,
        'isTyping': false,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  String makeChatId(myID, selectedUserID) {
    String chatID;
    if (myID.hashCode > selectedUserID.hashCode) {
      chatID = '$selectedUserID-$myID';
    } else {
      chatID = '$myID-$selectedUserID';
    }
    return chatID;
  }

  String returnTimeStamp(int messageTimeStamp) {
    String resultString = '';
    var format = DateFormat('d MMM yyyy hh:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(messageTimeStamp);
    resultString = format.format(date);
    return resultString;
  }

  Stream<QuerySnapshot> countUnreadMSG(String chatId, String myID) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection('chatroom')
        .doc(chatId)
        .collection(chatId)
        .where('idTo', isEqualTo: myID)
        .where('isread', isEqualTo: false)
        .snapshots();
  }

  Future<void> sendNotificationMessageToPeerUser(
      messageType, textFromTextField, myName, chatID, peerUserToken) async {
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA5E_KSyc:APA91bGLrRS-yfQX3yY9GVq2vdkMH9fny3Cjqc9Qdh5-kK-yllVrtExZos3B01v4Pgp4qxvfE69F3TEZ5siD_gym1zNWsBSq5I-r8oQJnMQ_t5kspPCrzKku5feMwra3n1decZNuZZNk',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': messageType == 'text' ? '$textFromTextField' : '(Photo)',
            'title': '$myName',
            "sound": "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatID,
          },
          'to': peerUserToken,
        },
      ),
    );
  }
}
