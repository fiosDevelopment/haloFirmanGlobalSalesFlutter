import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/services/home_service.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../core.dart';

class HomeView extends GetWidget<HomeController> {
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (barcodeScanRes == '-1') {
        Get.back();
      } else {
        Get.toNamed(Routes.SCAN_BARCODE_RESULT, arguments: barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  showModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(LineIcons.camera),
                title: new Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  scanBarcodeNormal();
                },
              ),
              ListTile(
                leading: new Icon(Icons.keyboard),
                title: new Text('Manual input'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.SCAN_BARCODE_INPUT);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: FutureBuilder(
                  future: AuthControllerss().readPreference('uid'),
                  builder: (context, sn) {
                    return sn.hasData
                        ? FutureBuilder<UserList>(
                            future: HomeService().getUser(sn.data),
                            builder: (context, snapshot) {
                              return snapshot.data == null
                                  ? ShimmerBasic(count: 1, height: 90)
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blue.withOpacity(.1),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: 30, left: 15, right: 15),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            width: double.infinity,
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    snapshot.data.imageUrl),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(
                                                    snapshot.data.firstName +
                                                        ' ' +
                                                        snapshot.data.lastName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              subtitle: Row(
                                                children: [
                                                  Text(snapshot
                                                      .data.accountType),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons.double_arrow,
                                                    size: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          builder: (context) {
                                                            return _buttomSheetContent();
                                                          });
                                                    },
                                                    child: Text(
                                                      "Ulasan saya",
                                                      style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 23),
                                          child: RichText(
                                              text: TextSpan(
                                                  style: new TextStyle(
                                                    fontSize: 22.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: [
                                                new TextSpan(text: 'Hello, '),
                                                new TextSpan(
                                                    text: snapshot
                                                            .data.firstName +
                                                        '!',
                                                    style: new TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ])),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 20),
                                          child: snapshot.data.accountType ==
                                                  'sales'
                                              ? _menuSales(context, sn.data)
                                              : snapshot.data.accountType ==
                                                      'customer_service'
                                                  ? buildMenuCS()
                                                  : buildMenuTeknisi(),
                                        )
                                      ],
                                    );
                            })
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  },
                ),
              ))),
    );
  }

  Column _buttomSheetContent() {
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Ulasan saya",
            style: TextStyle(
                fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder(
            future: AuthControllerss().readPreference('uid'),
            builder: (context, sn) {
              return StreamBuilder<QuerySnapshot>(
                  stream: HomeService().getUlasan(sn.data),
                  builder: (context, snUlasan) {
                    return snUlasan.data == null
                        ? Container()
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 16),
                            itemCount: snUlasan.data.docs.length,
                            itemBuilder: (context, i) {
                              return StreamBuilder<QuerySnapshot>(
                                  stream: HomeService()
                                      .getRating(snUlasan.data.docs[i].id),
                                  builder: (context, snn) {
                                    return snn.data == null
                                        ? Container()
                                        : snn.data.docs.length == 0
                                            ? Container()
                                            : StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .where('uID',
                                                        isEqualTo: snUlasan
                                                                .data.docs[i]
                                                            ['dibuatOleh'])
                                                    .snapshots(),
                                                builder: (context, snUser) {
                                                  return snUser.data == null
                                                      ? Container()
                                                      : Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    .1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  15),
                                                            ),
                                                          ),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 15,
                                                                  right: 15,
                                                                  bottom: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5),
                                                          width:
                                                              double.infinity,
                                                          child: ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(snUser
                                                                          .data
                                                                          .docs[0]
                                                                      [
                                                                      'imageUrl']),
                                                            ),
                                                            title: Text(
                                                              snn.data.docs[0]
                                                                  ['ulasan'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                            ),
                                                            subtitle: Text(
                                                              'Diulas oleh ' +
                                                                  snUser.data
                                                                          .docs[0]
                                                                      [
                                                                      "firstName"],
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                            trailing: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.star,
                                                                  size: 23,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                                Text(
                                                                  snn
                                                                      .data
                                                                      .docs[0][
                                                                          'rating']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                });
                                  });
                            });
                  });
            })
      ],
    );
  }

  StreamBuilder<QuerySnapshot> _menuSales(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("menuSales")
            .where("status", isEqualTo: 'on')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, homeController) {
          return homeController.data == null
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 3 / 1.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: homeController.data.docs.length,
                      itemBuilder: (context, i) {
                        var data = homeController.data.docs[i];
                        final icon = IconData(
                            int.parse(homeController.data.docs[i]['icon']),
                            fontFamily: 'MaterialIcons');
                        final color = Color(int.parse(data['color']));
                        return GestureDetector(
                          onTap: () => data['link'] == 'cek-garansi'
                              ? showModal(context)
                              : Get.toNamed("/${data['link']}"),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                data['title'] == 'Chat'
                                    ? _chatUnread(uid)
                                    : data['title'] == 'Meeting'
                                        ? _meetingNew(uid)
                                        : data['title'] == 'IPR' ||
                                                data['title'] == 'Cek garansi'
                                            ? Icon(
                                                icon,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            : Container(),
                                Text(
                                  data['title'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                );
        });
  }

  StreamBuilder<QuerySnapshot> _chatUnread(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: HomeService().getNewChatBadge(uid),
        builder: (context, snapshot) {
          return Text(
              (snapshot.hasData && snapshot.data.docs.length > 0)
                  ? ((snapshot.hasData && snapshot.data.docs.length > 0)
                      ? '${snapshot.data.docs.length}'
                      : '0')
                  : '0',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        });
  }

  StreamBuilder<QuerySnapshot> _meetingNew(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: HomeService().getNewMeetingBadge(uid),
        builder: (context, snapshot) {
          return Text(
              (snapshot.hasData && snapshot.data.docs.length > 0)
                  ? ((snapshot.hasData && snapshot.data.docs.length > 0)
                      ? '${snapshot.data.docs.length}'
                      : '0')
                  : '0',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        });
  }

  Row buildMenuSales(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BubbleMenu(
          onTap: () => Get.toNamed(Routes.CHAT_LIST),
          title: "Chat",
          icon: LineIcons.envelope,
        ),
        BubbleMenu(
          onTap: () => Get.toNamed(Routes.MEETING),
          title: "Meeting",
          icon: LineIcons.meetup,
        ),
        BubbleMenu(
          onTap: () {
            showModal(context);
          },
          title: "Cek garansi",
          icon: LineIcons.servicestack,
        ),
      ],
    );
  }

  Row buildMenuCS() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BubbleMenu(
          onTap: () => Get.toNamed(Routes.CHAT_LIST),
          title: "Chat",
          icon: LineIcons.envelope,
        ),
        BubbleMenu(
          onTap: () {},
          title: "IPR",
          icon: Icons.info,
        ),
      ],
    );
  }

  Row buildMenuTeknisi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BubbleMenu(
          onTap: () => Get.toNamed(Routes.CHAT_LIST),
          title: "Chat",
          icon: LineIcons.envelope,
        ),
      ],
    );
  }
}

class BubbleMenu extends StatelessWidget {
  const BubbleMenu({
    @required this.onTap,
    @required this.title,
    @required this.icon,
  });

  final GestureTapCallback onTap;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(
                  icon,
                  color: kPrimaryColor,
                  size: 40,
                ),
              ),
              // Positioned(
              //   right: 0,
              //   child: ButtonRoundedWidget(
              //     colorButton: kPrimaryColor,
              //     onTap: () {},
              //     titleButton: "2 baru",
              //     colorText: Colors.white,
              //   ),
              // ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
