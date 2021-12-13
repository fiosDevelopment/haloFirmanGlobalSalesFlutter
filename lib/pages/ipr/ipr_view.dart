import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class IPRView extends StatefulWidget {
  @override
  _IPRViewState createState() => _IPRViewState();
}

class _IPRViewState extends State<IPRView> {
  final TextEditingController _namaPartTextController =
      new TextEditingController();
  final TextEditingController _kodePartTextController =
      new TextEditingController();
  final TextEditingController _masalahTextController =
      new TextEditingController();

  final String noipr = Get.arguments[0];
  final String kdBarcode = Get.arguments[1];
  String kelompok = '';
  bool _tambahPart = false;
  String _valJenis;
  var hasilCari;
  bool displayAll = false;
  String _valListBarang;
  String query;
  bool searching = false;
  List<dynamic> dataInformasi = [];
  Future<XFile> fileAttach1;
  Future<XFile> fileAttach2;
  Future<XFile> fileAttach3;
  String tmpFile1;
  String tmpFile2;
  String tmpFile3;
  bool isLoading = false;
  bool _tombolTambah = false;
  bool displayFinal = false;
  bool displayButtonTambah = false;
  bool _loginLoading = false;
  List<IprUserList> user = [];
  final Set _saved = Set();
  List _jenis = [
    "Sparepart",
    "Unit",
    "Marketing",
    "General Affair",
    "Pack & ACC",
  ];
  final ImagePicker _picker = ImagePicker();

  void getListBarang() {
    IPRService().cariListBarang(_valJenis).then((value) {
      setState(() {
        dataInformasi = value;
      });
    });
  }

  void getUserIpr() {
    IPRService().iprUserList().then((value) {
      user = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  void getSuggestion(String jenis, String barang) async {
    var res = await http.post(
        Uri.parse(
            "https://fios.firmanindonesia.com/haloFirman/IPR/cariProduk.php"),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "jenis": _valJenis,
          "kategori": _valListBarang,
          "search": Uri.encodeComponent(query),
        });
    if (res.statusCode == 200) {
      setState(() {
        hasilCari = json.decode(res.body);
      });
    } else {
      print('gagal');
    }
  }

  void simpanIPR(String noIpr, String nik, String name) async {
    String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await firestoreInstance2
        .collection('IPR')
        .doc(noIpr)
        .collection('users')
        .doc('187.1110')
        .set({
      'nik': '187.1110',
      'name': 'HENDRA KURNIAWAN',
    });

    await firestoreInstance2
        .collection('IPR')
        .doc(noIpr)
        .collection('users')
        .doc('424.0712')
        .set({
      'nik': '424.0712',
      'name': 'INDRA KURNIAWAN',
    });

    await firestoreInstance2
        .collection('IPR')
        .doc(noIpr)
        .collection('users')
        .doc(nik)
        .set({
      'nik': nik,
      'name': name,
    });

    IPRService().iprSimpanAll(noipr, nik).whenComplete(() async {
      Fluttertoast.showToast(msg: "Berhasil Simpan IPR");
      Get.back();
    });
  }

  void iprTambahKelompok(String noIpr) async {
    setState(() {
      _tombolTambah = true;
    });
    await firestoreInstance2
        .collection('IPR')
        .doc(noIpr)
        .collection('ipr_produk')
        .doc(kelompok)
        .update({
      'kasusDone': 'yes',
    }).whenComplete(() {
      IPRService().iprTambahKelompok(noipr, kelompok);
      setState(() {
        displayButtonTambah = false;
        displayAll = false;
        displayFinal = true;
        _tombolTambah = true;
      });
      Fluttertoast.showToast(msg: "Berhasil Tambah");
    });
  }

  startUpload() async {
    setState(() {
      _tambahPart = true;
    });
    String noIpr = noipr.replaceAll("/", "_");
    var uri = Uri.parse(
        "https://fios.firmanindonesia.com/haloFirman/IPR/iprPart.php");
    var request = new http.MultipartRequest("POST", uri);

    if (tmpFile1 != null && tmpFile1.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath("gambarattach1", tmpFile1));
    } else {
      request.fields['gambarattach1'] = '';
    }

    if (tmpFile2 != null && tmpFile2.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath("gambarattach2", tmpFile2));
    } else {
      request.fields['gambarattach2'] = '';
    }

    if (tmpFile3 != null && tmpFile3.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath("gambarattach3", tmpFile3));
    } else {
      request.fields['gambarattach3'] = '';
    }

    request.fields['no_ipr'] = noipr;
    request.fields['no_identifikasi'] = kelompok;
    request.fields['masalah'] = _masalahTextController.text;
    request.fields['kd_barang'] = _kodePartTextController.text;

    http.StreamedResponse response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {});
    if (response.statusCode == 200) {
      setState(() {
        _tombolTambah = false;
        displayButtonTambah = true;
        fileAttach1 = null;
        fileAttach2 = null;
        fileAttach3 = null;
        tmpFile1 = null;
        tmpFile2 = null;
        tmpFile3 = null;
        _tambahPart = false;
        _namaPartTextController.clear();
        _masalahTextController.clear();
        _kodePartTextController.clear();
      });
      Fluttertoast.showToast(msg: "berhasil tambah part");
    } else if (response.statusCode == 400) {
      setState(() {
        _tambahPart = false;
      });
      Fluttertoast.showToast(msg: "Part Sudah Ada, pilih part lain");
    } else {
      setState(() {
        _tambahPart = false;
      });
      Fluttertoast.showToast(msg: "Gagal tambah, silahkan coba lagi");
    }
  }

  @override
  void initState() {
    saveIpr();
    getUserIpr();
    super.initState();
  }

  saveIpr() {
    String noIpr = noipr.replaceAll("/", "_");

    IPRService()
        .iprInput(noipr, "822.0418", "DIV05", kdBarcode, "Halo Firman")
        .then((value) {
      if (value.status == 1) {
        Fluttertoast.showToast(msg: "Kode barcode Sudah terdaftar");
        setState(() {
          displayAll = true;
        });
      } else if (value.status == 2) {
        Fluttertoast.showToast(msg: "Barcode tidak terdaftar");
      } else {
        Fluttertoast.showToast(msg: "Berhasil simpan");
        setState(() {
          displayAll = true;
          kelompok = value.kelompok;
        });

        IPRService().saveIprToFirebase(noIpr, noipr, kelompok, kdBarcode);
      }
    });
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Get.back(),
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {},
    );
    AlertDialog alert = AlertDialog(
      title: Text("Yakin ingin keluar?"),
      content: Text("Data IPR akan di hapus"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final firestoreInstance2 =
      FirebaseFirestore.instanceFor(app: Firebase.app("SecondaryApp"));
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String noIpr = noipr.replaceAll("/", "_");
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreInstance2
            .collection('IPR')
            .doc(noIpr)
            .collection('ipr_produk')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Color(0xffdee4eb),
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.keyboard_backspace,
                    color: Colors.black54,
                  ),
                  onPressed: () => showAlertDialog(context),
                ),
                title: Text(
                  noipr,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 21.0,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 21),
                        margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.0,
                              color: Colors.grey[300],
                              spreadRadius: 5.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(41),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            FutureBuilder<IprListBarang>(
                                future: IPRService().iprListBarang(
                                    noipr,
                                    kelompok == ''
                                        ? snapshot.data.docs[0].id
                                        : kelompok),
                                builder: (context, listIprSnapshot) {
                                  IprListBarang iprListBarang =
                                      listIprSnapshot.data;
                                  return (iprListBarang == null)
                                      ? Container()
                                      : Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Nama Barang',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      iprListBarang.data.length,
                                                  itemBuilder: (context, i) {
                                                    return StreamBuilder<
                                                            QuerySnapshot>(
                                                        stream: firestoreInstance2
                                                            .collection('IPR')
                                                            .doc(noIpr)
                                                            .collection(
                                                                'ipr_produk')
                                                            .doc(kelompok == ''
                                                                ? snapshot.data
                                                                    .docs[0].id
                                                                : kelompok)
                                                            .collection(
                                                                'barcode')
                                                            .where('kdBarcode',
                                                                isEqualTo:
                                                                    iprListBarang
                                                                        .data[i]
                                                                        .kdBarcode)
                                                            .snapshots(),
                                                        builder: (context,
                                                            barcodeSnapshot) {
                                                          return barcodeSnapshot
                                                                      .data !=
                                                                  null
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          iprListBarang
                                                                              .data[
                                                                                  i]
                                                                              .namaBarang,
                                                                          style:
                                                                              TextStyle(fontSize: 14)),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Container();
                                                        });
                                                  }),
                                            ),
                                          ],
                                        );
                                })
                          ],
                        )),
                    Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 21),
                        margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.0,
                              color: Colors.grey[300],
                              spreadRadius: 5.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(41),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      DropdownButton(
                                        isExpanded: true,
                                        hint: Text(
                                          "Jenis",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value: _valJenis,
                                        items: _jenis.map((value) {
                                          return DropdownMenuItem(
                                            child: Text(value),
                                            value: value == "Marketing"
                                                ? "mrt"
                                                : value == "Unit"
                                                    ? "unit"
                                                    : value == "Sparepart"
                                                        ? "sp"
                                                        : value ==
                                                                "General Affair"
                                                            ? "ga"
                                                            : "pa",
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _valJenis = value;
                                            getListBarang();
                                          });
                                        },
                                      ),
                                      Stack(
                                        children: [
                                          TextField(
                                            enabled: false,
                                            controller: _namaPartTextController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.only(top: 15),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              hintText: "Nama Part",
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                  onPressed: () {
                                                    (_valJenis != null)
                                                        ? searchPartDialog(
                                                            context)
                                                        : Fluttertoast.showToast(
                                                            msg:
                                                                "Pilih jenis terlebih dahulu");
                                                    getListBarang();
                                                  }),
                                            ),
                                          )
                                        ],
                                      ),
                                      TextField(
                                        enabled: false,
                                        controller: _kodePartTextController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 15),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          hintText: "Kode Part",
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: _masalahTextController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 15),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          hintText: "Masalah",
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            fileAttach1 == null
                                                ? CustomAttachContainer(
                                                    caption: 'Attach 1',
                                                    onTap: () {
                                                      setState(() {
                                                        fileAttach1 =
                                                            _picker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        fileAttach1
                                                            .then((value) {
                                                          tmpFile1 = value.path;
                                                        });
                                                      });
                                                    })
                                                : showImage('attach1'),
                                            fileAttach2 == null
                                                ? CustomAttachContainer(
                                                    caption: "Attach 2",
                                                    onTap: () {
                                                      setState(() {
                                                        fileAttach2 =
                                                            _picker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        fileAttach2
                                                            .then((value) {
                                                          tmpFile2 = value.path;
                                                        });
                                                      });
                                                    })
                                                : showImage('attach2'),
                                            fileAttach3 == null
                                                ? CustomAttachContainer(
                                                    caption: "Attach 3",
                                                    onTap: () {
                                                      setState(() {
                                                        fileAttach3 =
                                                            _picker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        fileAttach3
                                                            .then((value) {
                                                          tmpFile3 = value.path;
                                                        });
                                                      });
                                                    })
                                                : showImage('attach3'),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        width: size.width * 0.8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(29),
                                          child: TextButton(
                                              onPressed: _tambahPart == false
                                                  ? startUpload
                                                  : () {},
                                              style: TextButton.styleFrom(
                                                backgroundColor: !_loginLoading
                                                    ? Colors.blueAccent
                                                    : Colors.grey,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 40),
                                              ),
                                              child: _tambahPart == false
                                                  ? Text(
                                                      "Tambah Part",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  : Container(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                    )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                    (snapshot.data.docs.length > 0 &&
                            snapshot.hasData &&
                            displayAll == true)
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 21),
                            margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5.0,
                                  color: Colors.grey[300],
                                  spreadRadius: 5.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(41),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: <Widget>[
                                FutureBuilder<IprListPart>(
                                    future: IPRService()
                                        .iprListPart(noipr, kelompok),
                                    builder: (context, listIprPartSnapshot) {
                                      IprListPart iprListPart =
                                          listIprPartSnapshot.data;
                                      return (iprListPart == null)
                                          ? Container()
                                          : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Container(
                                                width: 600,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20),
                                                      child: Row(
                                                        children: [
                                                          PartContainer(
                                                              value:
                                                                  "Nama Part",
                                                              type: "title",
                                                              width: 170),
                                                          PartContainer(
                                                              value: "Masalah",
                                                              type: "title",
                                                              width: 100),
                                                          PartContainer(
                                                              value: "Image 1",
                                                              type: "title",
                                                              width: 80),
                                                          PartContainer(
                                                              value: "Image 2",
                                                              type: "title",
                                                              width: 80),
                                                          PartContainer(
                                                              value: "Image 3",
                                                              type: "title",
                                                              width: 80),
                                                          Text('Aksi',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 100,
                                                      child: ListView.builder(
                                                          itemCount: iprListPart
                                                              .data.length,
                                                          itemBuilder:
                                                              (context, i) {
                                                            return StreamBuilder<
                                                                    QuerySnapshot>(
                                                                stream: firestoreInstance2
                                                                    .collection(
                                                                        'IPR')
                                                                    .doc(noIpr)
                                                                    .collection(
                                                                        'ipr_produk')
                                                                    .doc(
                                                                        kelompok)
                                                                    .collection(
                                                                        'part')
                                                                    .where(
                                                                        'kdPart',
                                                                        isEqualTo: iprListPart
                                                                            .data[
                                                                                i]
                                                                            .kdPart)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    barcodeSnapshot) {
                                                                  return barcodeSnapshot !=
                                                                          null
                                                                      ? Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 20),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              PartContainer(value: iprListPart.data[i].namaBarang, type: "subtitle", width: 170),
                                                                              PartContainer(value: iprListPart.data[i].masalah, type: "subtitle", width: 100),
                                                                              (iprListPart.data[i].attach1 == null || iprListPart.data[i].attach1.isEmpty || iprListPart.data[i].attach1 == '')
                                                                                  ? SizedBox()
                                                                                  : Container(
                                                                                      width: 30,
                                                                                      child: Image.network(
                                                                                        iprListPart.data[i].attach1,
                                                                                        width: 30,
                                                                                      ),
                                                                                    ),
                                                                              SizedBox(
                                                                                width: 50,
                                                                              ),
                                                                              (iprListPart.data[i].attach2 == null || iprListPart.data[i].attach2.isEmpty || iprListPart.data[i].attach2 == '')
                                                                                  ? SizedBox()
                                                                                  : Container(
                                                                                      width: 30,
                                                                                      child: Image.network(
                                                                                        iprListPart.data[i].attach2,
                                                                                        width: 30,
                                                                                      ),
                                                                                    ),
                                                                              SizedBox(
                                                                                width: 50,
                                                                              ),
                                                                              (iprListPart.data[i].attach3 == null || iprListPart.data[i].attach3.isEmpty || iprListPart.data[i].attach3 == '')
                                                                                  ? SizedBox()
                                                                                  : Container(
                                                                                      width: 30,
                                                                                      child: Image.network(
                                                                                        iprListPart.data[i].attach3,
                                                                                      ),
                                                                                    ),
                                                                              SizedBox(
                                                                                width: 50,
                                                                              ),
                                                                              IconButton(
                                                                                  icon: Icon(
                                                                                    Icons.delete,
                                                                                    size: 18,
                                                                                    color: Colors.deepOrange,
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    confirmDeleteDialogPart(context, noIpr, iprListPart.data[i].kdPart, iprListPart.data[i].namaBarang);
                                                                                  }),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Container();
                                                                });
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                    }),
                              ],
                            ),
                          )
                        : SizedBox(),
                    (snapshot.data.docs.length > 0 &&
                            snapshot.hasData &&
                            displayButtonTambah == true)
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            width: size.width * 0.8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: TextButton(
                                  onPressed: _tombolTambah == false
                                      ? () {
                                          iprTambahKelompok(noIpr);
                                        }
                                      : () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: !_loginLoading
                                        ? Colors.blueAccent
                                        : Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 40),
                                  ),
                                  child: _tombolTambah == false
                                      ? Text(
                                          "Tambah",
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
                          )
                        : SizedBox(),
                    (snapshot.data.docs.length > 0 &&
                            snapshot.hasData &&
                            displayFinal == true)
                        ? Column(
                            children: [
                              CustomContainer(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Mengetahui",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: size.width * 0.3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: TextButton(
                                              onPressed: () {
                                                searchUser(context);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: !_loginLoading
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                              child: !_loginLoading
                                                  ? Text(
                                                      "Pilih User",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  : Container(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                    )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: size.width * 0.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(29),
                                  child: FutureBuilder<DetailUser>(
                                      future: IPRService().detailUser(),
                                      builder: (context, snapshot) {
                                        return TextButton(
                                            onPressed: () {
                                              simpanIPR(
                                                  noIpr,
                                                  snapshot.data.data.nik,
                                                  snapshot.data.data.name);
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20, horizontal: 40),
                                              backgroundColor: !_loginLoading
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                            ),
                                            child: !_loginLoading
                                                ? Text(
                                                    "Simpan IPR",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Container(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ));
                                      }),
                                ),
                              )
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget showImage(String value) {
    return FutureBuilder<XFile>(
      future: value == 'attach1'
          ? fileAttach1
          : value == 'attach2'
              ? fileAttach2
              : fileAttach3,
      builder: (BuildContext context, AsyncSnapshot<XFile> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          return Flexible(
            child: Stack(
              children: [
                Image.file(
                  File(snapshot.data.path),
                  width: 90,
                  height: 80,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                        onPressed: () {
                          if (value == 'attach1') {
                            setState(() {
                              fileAttach1 = null;
                              tmpFile1 = null;
                              // base64Image1 = null;
                            });
                          } else if (value == 'attach2') {
                            setState(() {
                              fileAttach2 = null;
                              tmpFile2 = null;
                              // base64Image2 = null;
                            });
                          } else {
                            setState(() {
                              fileAttach3 = null;
                              tmpFile3 = null;
                              // base64Image3 = null;
                            });
                          }
                        },
                      )),
                )
              ],
            ),
          );
        } else if (null != snapshot.error) {
          return CustomAttachContainer(
              caption: value,
              onTap: () {
                setState(() {
                  if (value == 'attach1') {
                    // fileAttach1 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  } else if (value == 'attach2') {
                    // fileAttach2 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  } else {
                    // fileAttach3 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  }
                });
              });
        } else {
          return CustomAttachContainer(
              caption: value == 'attach1'
                  ? 'Attach 1'
                  : value == 'attach2'
                      ? 'Attach 2'
                      : 'Attach 3',
              onTap: () {
                setState(() {
                  if (value == 'attach1') {
                    // fileAttach1 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  } else if (value == 'attach2') {
                    // fileAttach2 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  } else {
                    // fileAttach3 =
                    //     ImagePicker.pickImage(source: ImageSource.gallery);
                  }
                });
              });
        }
      },
    );
  }

  void searchPartDialog(BuildContext context) {
    AlertDialog dialog = new AlertDialog(
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return new Container(
          width: 260.0,
          height: 380.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Informasi',
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
              DropdownButton(
                isExpanded: true,
                hint: Text("Semua Kategori"),
                value: _valListBarang,
                items: dataInformasi.map((item) {
                  return DropdownMenuItem(
                    child: Text(item.kategori.toString()),
                    value: item.kategori.toString(),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _valListBarang = value;
                  });
                },
              ),
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontStyle: FontStyle.normal),
                  decoration: InputDecoration(hintText: 'Nama Barang'),
                ),
                suggestionsCallback: (pattern) async {
                  return await IPRService()
                      .getSuggestions(pattern, _valJenis, _valListBarang);
                },
                itemBuilder: (context, Map<String, String> suggestion) {
                  return ListTile(
                    title: Text(suggestion['namaBarang']),
                  );
                },
                onSuggestionSelected: (Map<String, String> suggestion) {
                  setState(() {
                    _namaPartTextController.text = suggestion['namaBarang'];
                    _kodePartTextController.text = suggestion['kdBarang'];
                    _valListBarang = null;
                  });
                },
              ),
              // TextField(
              //   decoration: InputDecoration(
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.blueAccent,
              //       ),
              //     ),
              //     labelText: "Nama Barang",
              //     labelStyle:
              //         TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              //   ),
              //   onChanged: (value) {
              //     query = value;
              //     getSuggestion(_valJenis, _valListBarang);
              //     setState(() {
              //       searching = true;
              //     });
              //   },
              // ),
              Container(
                child: searching == true ? showSearchSuggestions() : SizedBox(),
              )
            ],
          ),
        );
      }),
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () {
              setState(() {
                _valListBarang = null;
                searching = false;
              });
              Navigator.of(context, rootNavigator: true).pop('dialog');
            },
            child: dialog,
          );
        });
  }

  confirmDeleteDialogPart(
      BuildContext context, String noIpr, String kdPart, String namaBarang) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Batal"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text("Hapus"),
      onPressed: () {
        IPRService().iprDeletePart(kdPart, noipr, kelompok).then((value) async {
          if (value.status == '1') {
            await firestoreInstance2
                .collection('IPR')
                .doc(noIpr)
                .collection('ipr_produk')
                .doc(kelompok)
                .collection('part')
                .doc(kdPart)
                .delete();
          }
          Navigator.of(context, rootNavigator: true).pop('dialog');
        });
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Konfirmasi Hapus"),
      content: Text(
          "Yakin akan menghapus $namaBarang dengan kode barcode $kdPart dari list ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void searchUser(BuildContext context) {
    String noIpr = noipr.replaceAll("/", "_");
    AlertDialog dialog = new AlertDialog(
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return new Container(
          width: 260.0,
          height: 380.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: Column(
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 300,
                  child: user == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : FutureBuilder<DetailUser>(
                          future: IPRService().detailUser(),
                          builder: (context, snapshot) {
                            return ListView.builder(
                                itemCount: user[0].data.length,
                                itemBuilder: (context, i) {
                                  if (snapshot.data.data.nik ==
                                      user[0].data[i].nik) {
                                    return Container();
                                  } else {
                                    return CheckboxListTile(
                                        activeColor: Colors.pink[300],
                                        dense: true,
                                        //font change
                                        title: new Text(
                                          user[0].data[i].namaUser,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5),
                                        ),
                                        value: _saved.contains(i),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              firestoreInstance2
                                                  .collection('IPR')
                                                  .doc(noIpr)
                                                  .collection('users')
                                                  .doc(user[0].data[i].nik)
                                                  .set({
                                                'nik': user[0].data[i].nik,
                                                'name':
                                                    user[0].data[i].namaUser,
                                              }).whenComplete(() {
                                                IPRService().iprTambahUser(
                                                    noipr,
                                                    user[0].data[i].nik,
                                                    'tambah');
                                              });
                                              _saved.add(i);
                                            } else {
                                              firestoreInstance2
                                                  .collection('IPR')
                                                  .doc(noIpr)
                                                  .collection('users')
                                                  .doc(user[0].data[i].nik)
                                                  .delete()
                                                  .whenComplete(() {
                                                IPRService().iprTambahUser(
                                                    noipr,
                                                    user[0].data[i].nik,
                                                    'kurang');
                                              });
                                              _saved.remove(i);
                                            }
                                          });
                                        });
                                  }
                                });
                          }),
                );
              }),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: new Container(
                  width: double.infinity,
                  padding: new EdgeInsets.all(16.0),
                  decoration: new BoxDecoration(
                    color: const Color(0xFF33b17c),
                  ),
                  child: new Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: 'helvetica_neue_light',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget showSearchSuggestions() {
    List<SearchSuggestion> suggestionlist =
        List<SearchSuggestion>.from(hasilCari["data"].map((i) {
      return SearchSuggestion.fromJSON(i);
    }));
    return Container(
      height: MediaQuery.of(context).size.height / 3.7,
      child: ListView(
        children: [
          Column(
            children: suggestionlist.map((suggestion) {
                  return InkResponse(
                      onTap: () {
                        setState(() {
                          _namaPartTextController.text = suggestion.namaBarang;
                          _kodePartTextController.text = suggestion.kdBarang;
                          _valListBarang = null;
                          searching = false;
                        });
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                suggestion.namaBarang,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )));
                }).toList() ??
                [],
          ),
        ],
      ),
    );
  }

  confirmDeleteDialog(BuildContext context, String noIpr, String kdBarcode,
      String kdBarang, String namaBarang) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Batal"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text("Hapus"),
      onPressed: () {
        IPRService()
            .iprDelete(kdBarang, kdBarcode, noipr, kelompok)
            .then((value) async {
          if (value.status == '1') {
            await FirebaseFirestore.instance
                .collection('IPR')
                .doc(noIpr)
                .collection('ipr_produk')
                .doc(kelompok.toString())
                .collection('barcode')
                .doc(kdBarcode)
                .delete();
          } else if (value.status == '3') {
            FirebaseFirestore.instance
                .collection('IPR')
                .doc(noIpr)
                .collection('ipr_produk')
                .get()
                .then((snapshot) {
              for (DocumentSnapshot doc in snapshot.docs) {
                doc.reference.delete();
              }
            });
          }
          Navigator.of(context, rootNavigator: true).pop('dialog');
        });
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Konfirmasi Hapus"),
      content: Text(
          "Yakin akan menghapus $namaBarang dengan kode barcode $kdBarcode dari list ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class CustomContainer extends StatelessWidget {
  final Widget child;
  CustomContainer({@required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 21),
      margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            color: Colors.grey[300],
            spreadRadius: 5.0,
          ),
        ],
        borderRadius: BorderRadius.circular(41),
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class PartContainer extends StatelessWidget {
  final String value;
  final String type;
  final String subType;
  final double width;
  PartContainer(
      {@required this.value,
      @required this.type,
      this.subType,
      @required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: type == 'title'
          ? Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )
          : Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
    );
  }
}

class SearchSuggestion {
  String kdBarang, namaBarang, brand;
  SearchSuggestion({this.kdBarang, this.namaBarang, this.brand});

  factory SearchSuggestion.fromJSON(Map<String, dynamic> json) {
    return SearchSuggestion(
      kdBarang: json["kdBarang"],
      namaBarang: json["namaBarang"],
      brand: json["brand"],
    );
  }
}
