import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core.dart';

class ChatListView extends StatefulWidget {
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  var controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
          child: Container(
        width: double.infinity,
        // padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            AppBarWidget(
              title: "Chat",
              back: true,
            ),
            // _searchTextField(),
            _listChat()
          ],
        ),
      )),
    );
  }

  GetX<ChatListController> _listChat() {
    return GetX<ChatListController>(
        init: Get.put<ChatListController>(ChatListController()),
        builder: (ChatListController chatController) {
          return chatController.chatLists == null
              ? Container()
              : ListView.builder(
                  itemCount: chatController.chatLists.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uID',
                                isEqualTo:
                                    chatController.chatLists[index].chatwith)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null &&
                              snapshot.data.docs.length > 0) {
                            return GestureDetector(
                              onTap: () => Get.toNamed(Routes.CHAT_ROOM,
                                  arguments: [
                                    chatController.chatLists[index].chatid,
                                    snapshot.data.docs[0]
                                  ]),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300],
                                        blurRadius: 4,
                                        offset: Offset(4, 8), // Shadow position
                                      ),
                                    ]),
                                margin: EdgeInsets.only(
                                    bottom: 10, left: 15, right: 15),
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 20, bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                snapshot.data.docs[0]
                                                    ['imageUrl']),
                                            maxRadius: 20,
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data.docs[0]
                                                            ['firstName'] +
                                                        ' ' +
                                                        snapshot.data.docs[0]
                                                            ['lastName'],
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  chatController
                                                              .chatLists[index]
                                                              .isTyping ==
                                                          true
                                                      ? Text(
                                                          "Sedang mengetik..",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12),
                                                        )
                                                      : Text(
                                                          chatController
                                                              .chatLists[index]
                                                              .lastchat,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: snapshot.data.docs[0]
                                                              ['status'] ==
                                                          "available"
                                                      ? Colors.green
                                                      : snapshot.data.docs[0]
                                                                  ['status'] ==
                                                              "Offline"
                                                          ? Colors.grey
                                                          : Colors.orange),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              snapshot.data.docs[0]['status'],
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: snapshot.data.docs[0]
                                                              ['status'] ==
                                                          "available"
                                                      ? Colors.green
                                                      : snapshot.data.docs[0]
                                                                  ['status'] ==
                                                              "Offline"
                                                          ? Colors.grey
                                                          : Colors.orange),
                                            )
                                          ],
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: FutureBuilder(
                                              future: AuthControllerss()
                                                  .readPreference('uid'),
                                              builder: (context, sn) {
                                                return StreamBuilder<
                                                        QuerySnapshot>(
                                                    stream: ChatService()
                                                        .countUnreadMSG(
                                                            chatController
                                                                .chatLists[
                                                                    index]
                                                                .chatid,
                                                            sn.data),
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        (snapshot.hasData &&
                                                                snapshot
                                                                        .data
                                                                        .docs
                                                                        .length >
                                                                    0)
                                                            ? ((snapshot.hasData &&
                                                                    snapshot
                                                                            .data
                                                                            .docs
                                                                            .length >
                                                                        0)
                                                                ? '${snapshot.data.docs.length}'
                                                                : '')
                                                            : '',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    });
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return ShimmerBasic(count: 1, height: 80);
                          }
                        });
                  },
                );
        });
  }

  // Padding _searchTextField() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 16, left: 16, right: 16),
  //     child: TextField(
  //       decoration: InputDecoration(
  //         hintText: "Search...",
  //         hintStyle: TextStyle(color: Colors.grey.shade600),
  //         prefixIcon: Icon(
  //           Icons.search,
  //           color: Colors.grey.shade600,
  //           size: 20,
  //         ),
  //         filled: true,
  //         fillColor: Colors.white,
  //         contentPadding: EdgeInsets.all(8),
  //         enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(20),
  //             borderSide: BorderSide(color: Colors.grey.shade100)),
  //       ),
  //     ),
  //   );
  // }
}
