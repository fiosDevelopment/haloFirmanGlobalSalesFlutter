import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/managers/call_manager.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timelines/timelines.dart';

import '../../core.dart';

class MeetingDetailScreen extends StatefulWidget {
  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  ListMeeting controller = Get.arguments;

  final Set _saved = Set();

  bool _loginLoading = false;

  @override
  Widget build(BuildContext context) {
    DateTime tgl = DateTime.fromMillisecondsSinceEpoch(controller.jadwal);
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarWidget(
                  title: "Detail Meeting",
                  back: true,
                ),
                Container(
                  margin:
                      EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[300],
                          blurRadius: 4,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ]),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                        child: Row(
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: controller.status == "Baru"
                                      ? Colors.green
                                      : controller.status == 'Terjadwal'
                                          ? Colors.amber
                                          : controller.status == 'Aktif'
                                              ? Colors.green
                                              : controller.status == 'Berakhir'
                                                  ? Colors.blue
                                                  : Colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              controller.status,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[50],
                            ),
                            height: 40,
                            width: 40,
                            child: Icon(
                              LineIcons.user,
                              size: 20,
                              color: Colors.blue.shade400,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dibuat oleh",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('uID',
                                          isEqualTo: controller.dibuatOleh)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    return snapshot.data == null
                                        ? ShimmerBasic(count: 1, height: 20)
                                        : Text(
                                            snapshot.data.docs[0]['firstName'] +
                                                ' ' +
                                                snapshot.data.docs[0]
                                                    ['lastName'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold));
                                  }),
                            ],
                          ),
                          trailing: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('uID',
                                      isEqualTo: controller.dibuatOleh)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    _moveTochatRoom(
                                        controller.dibuatOleh, snapshot.data);
                                  },
                                  label: Text(
                                    'Chat',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  icon: Icon(
                                    Icons.chat_bubble,
                                    size: 11,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryColor,
                                  ),
                                );
                              })),
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red[50],
                          ),
                          height: 40,
                          width: 40,
                          child: Icon(
                            LineIcons.calendarCheckAlt,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                DateFormat.yMMMMEEEEd("id_ID")
                                    .format(tgl)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                                DateFormat("HH:mm")
                                    .format(tgl.toUtc())
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: (controller.status == 'Berakhir' ||
                                controller.status == 'Batal')
                            ? Text('')
                            : ElevatedButton.icon(
                                onPressed: () => Get.toNamed(
                                    Routes.MEETING_UBAH,
                                    arguments: controller),
                                label: Text(
                                  'Ubah',
                                  style: TextStyle(fontSize: 11),
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  size: 11,
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.purple,
                                ),
                              ),
                      ),
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green[50],
                          ),
                          height: 40,
                          width: 40,
                          child: Icon(
                            LineIcons.editAlt,
                            size: 20,
                            color: Colors.green.shade400,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Topik",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(controller.topik,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Divider(),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 15, 0, 10),
                        child: Row(
                          children: [
                            Text(
                              'Partisipan',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      _partisipan(context),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                        child: Row(
                          children: [
                            Text(
                              'Timeline',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      _timeline(),
                      SizedBox(
                        height: 20,
                      ),
                      _ratingList(),
                      (controller.status == 'Berakhir' ||
                              controller.status == 'Batal')
                          ? Container()
                          : _button()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> _button() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uID', isEqualTo: controller.dibuatOleh)
            .snapshots(),
        builder: (context, snapshot) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _moveTochatRoom(controller.dibuatOleh, snapshot.data);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    child: Icon(Icons.chat),
                  ),
                  controller.status == "Baru"
                      ? Container()
                      : ElevatedButton(
                          onPressed: () => Get.toNamed(
                              Routes.MEETING_BUAT_NOTULEN,
                              arguments: controller),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                          child: Icon(Icons.note_add),
                        ),
                  controller.status == "Baru"
                      ? ElevatedButton(
                          onPressed: () {
                            MeetingService()
                                .terimaPermintaan(controller.meetingid);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(100, 40),
                            primary: Colors.green,
                            padding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 60),
                          ),
                          child: Text(
                            "Terima permintaan",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('uID', isEqualTo: controller.dibuatOleh)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.data == null
                                ? Container()
                                : FutureBuilder<CubeUser>(
                                    future: getUserByEmail(
                                        snapshot.data.docs[0]['email']),
                                    builder: (context, sn) {
                                      return ElevatedButton(
                                        onPressed: () => CallManager.instance
                                            .startNewCall(
                                                context,
                                                CallType.VIDEO_CALL,
                                                {sn.data.id},
                                                snapshot.data.docs[0]
                                                    ['firstName'],
                                                snapshot.data.docs[0]
                                                    ['imageUrl']),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(100, 40),
                                          primary: Colors.green,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 40),
                                        ),
                                        child: Text(
                                          "Mulai Meeting",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    });
                          }),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    Get.toNamed(Routes.MEETING_BATAL, arguments: controller),
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 2, color: kPrimaryColor)),
                  child: Text(
                    "Batalkan Meeting",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          );
        });
  }

  Container _partisipan(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
      child: Row(
        children: [
          Row(
              children: List.generate(controller.partisipan.length, (i) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uID', isEqualTo: controller.partisipan[i])
                    .snapshots(),
                builder: (context, snapshot) {
                  return snapshot.data == null
                      ? Container()
                      : Tooltip(
                          waitDuration: Duration.zero,
                          showDuration: Duration.zero,
                          verticalOffset: -50,
                          message: snapshot.data.docs[0]['firstName'],
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2)),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: NetworkImage(snapshot
                                                .data.docs[0]['imageUrl']),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                });
          })),
          GestureDetector(
            onTap: () {
              _addPartisipanDialog(context);
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black)),
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _timeline() {
    return Container(
        height: 250,
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('meetings')
                .doc(controller.meetingid)
                .collection("timeline")
                .orderBy("createdAt", descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              return snapshot.data == null
                  ? Container()
                  : Timeline.tileBuilder(
                      theme: TimelineThemeData(
                        nodePosition: 0,
                        connectorTheme: ConnectorThemeData(
                          thickness: 3.0,
                          color: Color(0xffd3d3d3),
                        ),
                        indicatorTheme: IndicatorThemeData(
                          size: 15.0,
                        ),
                      ),
                      builder: TimelineTileBuilder.connected(
                        contentsBuilder: (_, i) => Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data.docs[i]['description'],
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              snapshot.data.docs[i]['type'] == 'basic'
                                  ? Text(
                                      snapshot.data.docs[i]['subDescription'],
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.black54),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        _showNotulen(
                                            context,
                                            snapshot.data.docs[i]
                                                ['subDescription']);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(LineIcons.fileContract),
                                          Text("Lihat Notulen",
                                              style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        connectorBuilder: (_, index, __) {
                          if (index == 0) {
                            return SolidLineConnector(color: kPrimaryColor);
                          } else {
                            return SolidLineConnector();
                          }
                        },
                        indicatorBuilder: (_, index) {
                          return DotIndicator(
                            color: kPrimaryColor,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            ),
                          );
                        },
                        itemExtentBuilder: (_, __) => 55,
                        itemCount: snapshot.data.docs.length,
                      ),
                    );
            }));
  }

  StreamBuilder<QuerySnapshot> _ratingList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("meetings")
            .doc(controller.meetingid)
            .collection("rating")
            .snapshots(),
        builder: (context, snrating) {
          return snrating.data == null
              ? Container()
              : snrating.data.docs.length == 0
                  ? Container()
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                          child: Row(
                            children: [
                              Text(
                                'Ulasan & rating',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(.1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            margin: EdgeInsets.only(
                                top: 15, left: 15, right: 15, bottom: 10),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            width: double.infinity,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .where("uID",
                                        isEqualTo: controller.dibuatOleh)
                                    .snapshots(),
                                builder: (context, snuser) {
                                  return ListTile();
                                })),
                      ],
                    );
        });
  }

  void _showNotulen(BuildContext context, String text) {
    AlertDialog dialog = new AlertDialog(
      content: Container(
        width: 260.0,
        height: 400.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Hasil meeting",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _addPartisipanDialog(BuildContext context) {
    AlertDialog dialog = new AlertDialog(
      content: Container(
        width: 260.0,
        height: 400.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Member',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontFamily: 'helvetica_neue_light',
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 7,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('accountType', isEqualTo: "teknisi")
                        .snapshots(),
                    builder: (context, snapshot) {
                      var data = snapshot.data;
                      return data == null
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: data.docs.length,
                              itemBuilder: (context, i) {
                                return CheckboxListTile(
                                  activeColor: Colors.pink[300],
                                  dense: true,
                                  title: Text(
                                    data.docs[i]['firstName'] +
                                        ' ' +
                                        data.docs[i]['lastName'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5),
                                  ),
                                  value: _saved.contains(i),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        MeetingService().updatePartisipan(
                                            controller.meetingid,
                                            data.docs[i]['uID']);
                                        _saved.add(i);
                                      } else {
                                        _saved.remove(i);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                    }),
              );
            }),
            Spacer(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: !_loginLoading ? kPrimaryColor : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  ),
                  child: !_loginLoading
                      ? Text(
                          "Selesai",
                          style: TextStyle(color: Colors.white),
                        )
                      : Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<void> _moveTochatRoom(String uID, QuerySnapshot snapshot) async {
    try {
      AuthControllerss().readPreference('uid').then((value) {
        String chatID = ChatService().makeChatId(value, uID);
        Get.toNamed(
          Routes.CHAT_ROOM,
          arguments: [chatID, snapshot.docs[0]],
        );
      });
    } catch (e) {
      print(e.message);
    }
  }
}
