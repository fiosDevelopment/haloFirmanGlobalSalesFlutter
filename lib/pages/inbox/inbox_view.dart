import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/core.dart';

class InboxView extends GetView<InboxController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        title: AppBarWidget(
          title: "Inbox",
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(Duration(seconds: 1), () {});
        },
        child: SafeArea(
          child: Container(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 30),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "RECENTS",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        // Text(
                        //   "(4 Belum dibaca)",
                        //   style: TextStyle(
                        //     color: Colors.grey,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildListInbox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder<String> _buildListInbox() {
    return FutureBuilder(
        future: AuthControllerss().readPreference("uid"),
        builder: (context, sn) {
          return sn.data == null
              ? Container()
              : StreamBuilder<QuerySnapshot>(
                  stream: InboxService().getInboxList(sn.data),
                  builder: (context, snapshot) {
                    return snapshot.data == null
                        ? ShimmerBasic(count: 3, height: 100)
                        : snapshot.data.docs.length < 1
                            ? Center(child: Text("Tidak ada data"))
                            : ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 16),
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  var data = snapshot.data.docs;
                                  return data[i]['type'] == 'chat'
                                      ? _buildChatInbox(
                                          context,
                                          data[i]['content'],
                                          data[i]['idReferensi'],
                                          data[i]['idSender'],
                                          data[i]['timestamp'])
                                      : _buildMeetingInbox(
                                          data[i]['content'],
                                          data[i]['idReferensi'],
                                          data[i]['idSender'],
                                          data[i]['timestamp']);
                                });
                  },
                );
        });
  }

  StreamBuilder _buildMeetingInbox(
      String content, String idReferensi, String idSender, Timestamp time) {
    int waktu = time.millisecondsSinceEpoch.toInt();

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uID', isEqualTo: idSender)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.data == null
              ? Container()
              : GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "Permintaan Meeting",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),
                                          ),
                                          Spacer(),
                                          Text(
                                            ChatService()
                                                .returnTimeStamp(waktu),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        content,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0),
                                      ),
                                      SizedBox(
                                        height: 3.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "Dibuat oleh " +
                                                snapshot.data.docs[0]
                                                    ['firstName'] +
                                                ' ' +
                                                snapshot.data.docs[0]
                                                    ['lastName'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.0),
                                          ),
                                          Spacer(),
                                          ButtonRoundedWidget(
                                            titleButton: "Meeting",
                                            colorButton: kPrimaryColor,
                                            colorText: Colors.white,
                                            onTap: () {},
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  StreamBuilder _buildChatInbox(BuildContext context, String content,
      String idReferensi, String idSender, Timestamp time) {
    int waktu = time.millisecondsSinceEpoch.toInt();
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uID', isEqualTo: idSender)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.data == null
              ? ShimmerBasic(count: 4, height: 80)
              : GestureDetector(
                  onTap: () => Get.toNamed(Routes.CHAT_ROOM,
                      arguments: [idReferensi, snapshot.data.docs[0]]),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Image.network(
                                snapshot.data.docs[0]['imageUrl'],
                                height: 60.0,
                                width: 60.0,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        snapshot.data.docs[0]['firstName'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),
                                      ),
                                      Spacer(),
                                      Text(
                                        ChatService().returnTimeStamp(waktu),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    content,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14.0),
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          ButtonRoundedWidget(
                                            titleButton: "Balas Cepat",
                                            colorButton: Colors.blue,
                                            colorText: Colors.white,
                                            onTap: () {
                                              openBottomSheet(context, content);
                                            },
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          ButtonRoundedWidget(
                                            titleButton: 'Chat',
                                            colorButton: Colors.green,
                                            onTap: () {},
                                            colorText: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  void openBottomSheet(BuildContext context, String content) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 500.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.network(
                              "https://randomuser.me/api/portraits/men/3.jpg",
                              height: 60.0,
                              width: 60.0,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "Arief Nurrohman",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.blue[700],
                                    ),
                                    Icon(
                                      Icons.more_vert,
                                      color: Colors.blue[700],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      content,
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Reply..",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 18.0),
                            ),
                            Spacer(),
                            CircleAvatar(
                              backgroundColor: Colors.blue[600],
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
