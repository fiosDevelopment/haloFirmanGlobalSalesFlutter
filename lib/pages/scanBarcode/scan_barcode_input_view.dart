import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../core.dart';

class InputBarcodeView extends StatelessWidget {
  final TextEditingController barcodeController = new TextEditingController();

  moveToResult(String barcode) {
    Get.toNamed(Routes.SCAN_BARCODE_RESULT, arguments: barcode);
  }

  _handleSubmit(String uid) {
    if (barcodeController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Input tidak boleh kosong");
    } else {
      var time = DateTime.now().millisecondsSinceEpoch;
      FirebaseFirestore.instance
          .collection("historyInputBarcode")
          .doc(time.toString())
          .set({
        'content': barcodeController.text,
        'inputBy': uid,
        'timestamp': DateTime.now(),
      });
      Get.toNamed(Routes.SCAN_BARCODE_RESULT,
          arguments: barcodeController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
          child: Container(
        width: double.infinity,
        child: Column(
          children: [
            AppBarWidget(
              title: "Input barcode",
              back: true,
            ),
            FutureBuilder(
                future: AuthControllerss().readPreference('uid'),
                builder: (context, sn) {
                  return sn.data == null
                      ? Container()
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('historyInputBarcode')
                              .where('inputBy', isEqualTo: sn.data)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.data == null
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(
                                        top: 16, left: 16, right: 16),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: barcodeController,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: snapshot
                                                            .data.docs.length ==
                                                        0
                                                    ? BorderRadius.circular(20)
                                                    : BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(
                                                                20)),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade100)),
                                            hintText: "Input barcode disini",
                                            hintStyle: TextStyle(
                                                color: Colors.grey.shade600),
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: Colors.grey.shade600,
                                              size: 20,
                                            ),
                                            suffixIcon: GestureDetector(
                                              onTap: () =>
                                                  _handleSubmit(sn.data),
                                              child: Container(
                                                width: 30,
                                                margin: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: kPrimaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.all(8),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: snapshot
                                                            .data.docs.length ==
                                                        0
                                                    ? BorderRadius.circular(20)
                                                    : BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(
                                                                20)),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade100)),
                                          ),
                                        ),
                                        snapshot.data.docs.length == 0
                                            ? Container()
                                            : Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(20),
                                                      bottomRight:
                                                          Radius.circular(20),
                                                    )),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Terakhir input",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12),
                                                    ),
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: snapshot
                                                            .data.docs.length,
                                                        itemBuilder:
                                                            (context, i) {
                                                          return ListTile(
                                                            dense: true,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 0.0,
                                                                    right: 0.0),
                                                            leading: new Icon(
                                                                Icons.history),
                                                            title: new Text(
                                                              snapshot.data
                                                                      .docs[i]
                                                                  ['content'],
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            ),
                                                            onTap: () {
                                                              moveToResult(snapshot
                                                                      .data
                                                                      .docs[i]
                                                                  ['content']);
                                                            },
                                                          );
                                                        }),
                                                  ],
                                                ),
                                              )
                                      ],
                                    ),
                                  );
                          });
                })
          ],
        ),
      )),
    );
  }
}
