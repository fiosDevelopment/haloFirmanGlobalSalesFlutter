import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/managers/call_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core.dart';

class ChatRoomView extends StatefulWidget {
  @override
  _ChatRoomViewState createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final TextEditingController _msgTextController = new TextEditingController();

  double micButton = 45.0;
  String messageType = 'text';

  String chatid = Get.arguments[0];

  final userSelected = Get.arguments[1];
  List<PickedFile> imageFileList;
  dynamic pickImageError;
  final ImagePicker _picker = ImagePicker();
  set _imageFile(PickedFile value) {
    imageFileList = value == null ? null : [value];
  }

  void updateButtonState(String text) {
    if (text.length > 0) {
      AuthControllerss().readPreference('uid').then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userSelected['uID'])
            .collection("chatlist")
            .doc(chatid)
            .update({
          'isTyping': true,
        });
      });
    }
    if (text.length <= 0) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userSelected['uID'])
          .collection("chatlist")
          .doc(chatid)
          .update({
        'isTyping': false,
      });
    }
  }

  Future<void> _saveUserImageToFirebaseStorage(croppedFile, uID) async {
    try {
      String image =
          await ChatService().sendImageToUserInChatRoom(croppedFile, chatid);
      _handleSubmitted(image);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal upload ke server");
    }
  }

  Future<void> _handleSubmitted(
    String text,
  ) async {
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: "Input tidak boleh kosong");
    } else {
      var time = DateTime.now().millisecondsSinceEpoch;

      AuthControllerss().readPreference('uid').then((myID) {
        ChatService().sendChat(
            chatid, myID, userSelected['uID'], text, messageType, time);
        ChatService().updateChatRequestField(
            userSelected['uID'], text, chatid, myID, userSelected['uID']);
        ChatService()
            .updateChatRequestField(
                myID,
                messageType == 'image' ? '(Photo)' : text,
                chatid,
                myID,
                userSelected['uID'])
            .whenComplete(() {
          ProfileService().getUser(myID).then((value) {
            ChatService().sendNotificationMessageToPeerUser(messageType, text,
                value.firstName, chatid, userSelected['FCMToken']);
            CoreService().saveNotifications(
                messageType == 'image' ? '(Photo)' : text,
                myID,
                userSelected['uID'],
                chatid,
                'chat',
                time);
          });
          _msgTextController.text = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf9fafc),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        actions: [
          FutureBuilder<CubeUser>(
              future: getUserByEmail(userSelected['email']),
              builder: (context, sn) {
                return sn.data != null
                    ? IconButton(
                        icon: Icon(LineIcons.video),
                        onPressed: () => CallManager.instance.startNewCall(
                            context,
                            CallType.VIDEO_CALL,
                            {sn.data.id},
                            userSelected['firstName'],
                            userSelected['imageUrl']))
                    : Container();
              }),
          FutureBuilder<CubeUser>(
              future: getUserByEmail(userSelected['email']),
              builder: (context, sn) {
                return sn.data != null
                    ? IconButton(
                        icon: Icon(LineIcons.phone),
                        onPressed: () => CallManager.instance.startNewCall(
                            context,
                            CallType.AUDIO_CALL,
                            {sn.data.id},
                            userSelected['firstName'],
                            userSelected['imageUrl']))
                    : Container();
              })
        ],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userSelected['imageUrl']),
              maxRadius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userSelected['firstName'] + ' ' + userSelected['lastName'],
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                FutureBuilder(
                    future: AuthControllerss().readPreference('uid'),
                    builder: (context, sn) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(sn.data)
                              .collection("chatlist")
                              .where("chatID", isEqualTo: chatid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.data == null
                                ? Container()
                                : snapshot.data.docs.length == 0
                                    ? Container()
                                    : Text(
                                        snapshot.data.docs[0]['isTyping']
                                            ? "Sedang mengetik..."
                                            : "online",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13),
                                      );
                          });
                    }),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chatroom')
              .doc(chatid)
              .collection(chatid)
              .orderBy('timestamp', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            if (snapshot.hasData) {
              for (var data in snapshot.data.docs) {
                AuthControllerss().readPreference('uid').then((value) {
                  if (data['idTo'] == value && data['isread'] == false) {
                    if (data.reference != null) {
                      FirebaseFirestore.instance
                          .runTransaction((Transaction myTransaction) async {
                        myTransaction.update(data.reference, {'isread': true});
                      });
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(value)
                          .collection("notifications")
                          .doc(data.id)
                          .update({'isRead': true});
                    }
                  }
                });
              }
            }
            return Stack(
              children: [
                ListView(
                    reverse: true,
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(4.0, 10, 4, 80),
                    children: snapshot.data.docs.map((data) {
                      //snapshot.data.documents.reversed.map((data) {
                      return data['idFrom'] == userSelected['uID']
                          ? _listItemOther(
                              context,
                              userSelected['firstName'],
                              userSelected['imageUrl'],
                              data['content'],
                              data['timestamp'],
                              data['type'],
                              chatid)
                          : _listItemMine(
                              context,
                              chatid,
                              data['content'],
                              data['timestamp'],
                              data['isread'],
                              data['type'],
                            );
                    }).toList()),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 16, bottom: 10),
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return _bottomSheetContent();
                                });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => updateButtonState(value),
                            controller: _msgTextController,
                            decoration: InputDecoration(
                                hintText: "Type message...",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.only(right: 20, bottom: 27),
                    child: SizedBox(
                      width: micButton,
                      height: micButton,
                      child: FloatingActionButton(
                        onPressed: () {
                          _handleSubmitted(_msgTextController.text);
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 23,
                        ),
                        backgroundColor: kPrimaryColor,
                        elevation: 0,
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }

  Column _bottomSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
        ),
        Center(
          child: Container(
            height: 4,
            width: 50,
            color: Colors.black,
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //   child: Text(
        //     "Chat cepat",
        //     style: TextStyle(
        //         fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //   child: StreamBuilder<QuerySnapshot>(
        //       stream: FirebaseFirestore.instance
        //           .collection('templateChat')
        //           .where('active', isEqualTo: true)
        //           .where('templateFor', isEqualTo: 'admin')
        //           .snapshots(),
        //       builder: (context, snapshot) {
        //         return snapshot.data == null
        //             ? Container()
        //             : SingleChildScrollView(
        //                 scrollDirection: Axis.horizontal,
        //                 child: Row(
        //                   children:
        //                       List.generate(snapshot.data.docs.length, (i) {
        //                     return FutureBuilder(
        //                         future:
        //                             AuthControllerss().readPreference('uid'),
        //                         builder: (context, sn) {
        //                           return sn.data == null
        //                               ? Container()
        //                               : FutureBuilder<UserList>(
        //                                   future:
        //                                       ProfileService().getUser(sn.data),
        //                                   builder: (context, snn) {
        //                                     return snn.data == null
        //                                         ? Container()
        //                                         : GestureDetector(
        //                                             onTap: () {
        //                                               _handleSubmitted(snapshot.data.docs[i][
        //                                                               'type'] ==
        //                                                           'introduce'
        //                                                       ? snapshot.data.docs[i]
        //                                                                   ['content']
        //                                                               [0] +
        //                                                           snn.data
        //                                                               .firstName +
        //                                                           ' ' +
        //                                                           snn.data
        //                                                               .lastName +
        //                                                           ' ' +
        //                                                           snapshot.data.docs[i]
        //                                                                   ['content']
        //                                                               [1]
        //                                                       : snapshot.data.docs[i]
        //                                                           ['content'][0])
        //                                                   .whenComplete(() {
        //                                                 Get.back();
        //                                               });
        //                                             },
        //                                             child: Container(
        //                                               margin: EdgeInsets.only(
        //                                                   right: 10),
        //                                               width: 120,
        //                                               padding:
        //                                                   EdgeInsets.symmetric(
        //                                                       horizontal: 10,
        //                                                       vertical: 5),
        //                                               decoration: BoxDecoration(
        //                                                   border: Border.all(
        //                                                       color:
        //                                                           kPrimaryColor),
        //                                                   borderRadius:
        //                                                       BorderRadius
        //                                                           .circular(
        //                                                               30)),
        //                                               child: Text(
        //                                                 snapshot.data.docs[i]
        //                                                     ['content'][0],
        //                                                 overflow: TextOverflow
        //                                                     .ellipsis,
        //                                                 style: TextStyle(
        //                                                     fontSize: 11,
        //                                                     color:
        //                                                         kPrimaryColor),
        //                                               ),
        //                                             ),
        //                                           );
        //                                   });
        //                         });
        //                   }),
        //                 ),
        //               );
        //       }),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Attachment",
            style: TextStyle(
                fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder(
            future: AuthControllerss().readPreference("uid"),
            builder: (context, snn) {
              return snn.data == null
                  ? Container()
                  : ListTile(
                      onTap: () async {
                        try {
                          final pickedFile = await _picker.getImage(
                            source: ImageSource.gallery,
                            imageQuality: 50,
                          );
                          setState(() {
                            messageType = "image";
                            _imageFile = pickedFile;
                            _saveUserImageToFirebaseStorage(
                                pickedFile.path, snn.data);
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          });
                        } catch (e) {
                          setState(() {
                            pickImageError = e;
                          });
                        }
                      },
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.amber[50],
                        ),
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.image,
                          size: 20,
                          color: Colors.amber.shade400,
                        ),
                      ),
                      title: Text("Photos",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    );
            }),
      ],
    );
  }

  Widget _listItemOther(
    BuildContext context,
    String name,
    String thumbnail,
    String message,
    int time,
    String type,
    String chatid,
  ) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onLongPressUp: () {
        print('ini longpress');
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 15),
        child: Container(
          child: Column(
            children: [
              type == 'barcode' ? buildOptional(time) : Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Text(name),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: size.width - 150),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(17),
                                          bottomRight: Radius.circular(17),
                                          topRight: Radius.circular(17)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[300],
                                          blurRadius: 6,
                                          offset:
                                              Offset(3, 6), // Shadow position
                                        ),
                                      ]),
                                  child: Padding(
                                    padding: type == 'text' ||
                                            type == 'file' ||
                                            type == 'barcode'
                                        ? EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 10,
                                            bottom: 10)
                                        : EdgeInsets.all(0),
                                    child: Container(
                                        child: (type == 'text' ||
                                                type == 'barcode')
                                            ? Text(
                                                message,
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )
                                            : Container(
                                                width: 160,
                                                height: 160,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () => Get.toNamed(
                                                      Routes.FULL_PHOTO,
                                                      arguments: message),
                                                  child: CachedNetworkImage(
                                                    imageUrl: message,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      transform: Matrix4
                                                          .translationValues(
                                                              0, 0, 0),
                                                      child: Container(
                                                          width: 60,
                                                          height: 80,
                                                          child: Center(
                                                              child:
                                                                  new CircularProgressIndicator())),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        new Icon(Icons.error),
                                                    width: 60,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 14.0, left: 4),
                                child: Text(
                                  ChatService().returnTimeStamp(time),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> buildOptional(time) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatroom')
            .doc(chatid)
            .collection(chatid)
            .doc(time.toString())
            .collection('optional')
            .where('type', isEqualTo: 'barcode')
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.data == null
              ? Container()
              : FutureBuilder<Garansi>(
                  future: ScanGaransiService()
                      .getGaransiDetails(snapshot.data.docs[0]['content']),
                  builder: (context, snn) {
                    return snn.data == null
                        ? Container()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300],
                                        blurRadius: 6,
                                        offset: Offset(3, 6), // Shadow position
                                      ),
                                    ]),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "https://fios.firmanindonesia.com/asset/produk_real/" +
                                                    snn.data.data[0].barang
                                                        .data[0].kdBarang +
                                                    "/" +
                                                    snn
                                                        .data
                                                        .data[0]
                                                        .barang
                                                        .data[0]
                                                        .brosurFios
                                                        .data[0]
                                                        .gambar)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data.docs[0]['content'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 10),
                                        ),
                                        Container(
                                          width: 130,
                                          child: Text(
                                            snn.data.data[0].barang.data[0]
                                                .namaBarang,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => Get.toNamed(
                                                  Routes.SCAN_BARCODE_RESULT,
                                                  arguments: snapshot
                                                      .data.docs[0]['content']),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 6),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: kPrimaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  "Detail",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kPrimaryColor,
                                                      fontSize: 11),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            FutureBuilder<AutoNumber>(
                                                future:
                                                    IPRService().autoNumber(),
                                                builder: (context, sn) {
                                                  return GestureDetector(
                                                    onTap: () => Get.toNamed(
                                                        Routes.IPR,
                                                        arguments: [
                                                          sn.data.noIpr,
                                                          snapshot.data.docs[0]
                                                              ['content']
                                                        ]),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 6),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  kPrimaryColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Text(
                                                        "Buat IPR",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                kPrimaryColor,
                                                            fontSize: 11),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                  });
        });
  }

  Widget _listItemMine(BuildContext context, String chatID, String message,
      int time, bool isRead, String type) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: size.width - size.width * 0.26),
                decoration: BoxDecoration(
                  color: type == 'text' || type == 'file'
                      ? kPrimaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(17),
                      bottomRight: Radius.circular(17),
                      topLeft: Radius.circular(17)),
                ),
                child: Padding(
                  padding: type == 'text' || type == 'file'
                      ? EdgeInsets.only(
                          left: 16, right: 16, top: 10, bottom: 10)
                      : EdgeInsets.all(0),
                  child: Container(
                    child: type == 'text'
                        ? Text(
                            message,
                            style: TextStyle(color: Colors.white),
                          )
                        : Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: GestureDetector(
                              onTap: () => Get.toNamed(Routes.FULL_PHOTO,
                                  arguments: message),
                              child: CachedNetworkImage(
                                imageUrl: message,
                                placeholder: (context, url) => Container(
                                  transform: Matrix4.translationValues(0, 0, 0),
                                  child: Container(
                                      width: 60,
                                      height: 80,
                                      child: Center(
                                          child:
                                              new CircularProgressIndicator())),
                                ),
                                errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2, left: 4),
                    child: Icon(
                      isRead ? Icons.done_all : Icons.done,
                      color: isRead ? Colors.blue : Colors.grey,
                      size: 12.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, left: 8),
                    child: Text(
                      ChatService().returnTimeStamp(time),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
