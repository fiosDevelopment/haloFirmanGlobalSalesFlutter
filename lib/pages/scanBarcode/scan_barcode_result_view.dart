import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core.dart';

class ScanBarcodeResult extends StatefulWidget {
  final barcode = Get.arguments;

  @override
  _ScanBarcodeResultState createState() => _ScanBarcodeResultState();
}

class _ScanBarcodeResultState extends State<ScanBarcodeResult> {
  // ignore: missing_return
  Future<Garansi> getGaransiDetails() async {
    String apiURL =
        "https://api.firmanindonesia.com/firman/v1/public/halo_firman/garansi/" +
            widget.barcode;
    var headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer fHLBqZDzIiXN9bEAIxbCFOWnqiTWXLjMFAdgiA"
    };
    http.Response apiResult =
        await http.get(Uri.parse(apiURL), headers: headers);
    if (apiResult.statusCode == 200) {
      return garansiFromJson(apiResult.body);
    } else {
      print('tidak ada data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: FutureBuilder<Garansi>(
              future: getGaransiDetails(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                Garansi garansi = snapshot.data;
                return garansi == null
                    ? snapshot.connectionState == ConnectionState.waiting
                        ? Center(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Center(
                            child: Text("Data tidak ditemukan"),
                          )
                    : (garansi.data[0].noGaransi == null || garansi == null)
                        ? Center(
                            child: Text("Data tidak ditemukan"),
                          )
                        : BuildGaransi(
                            garansi: garansi,
                            barcode: widget.barcode,
                          );
              })),
    );
  }
}

class BuildGaransi extends StatefulWidget {
  const BuildGaransi({Key key, @required this.garansi, this.barcode})
      : super(key: key);

  final Garansi garansi;
  final barcode;

  @override
  State<BuildGaransi> createState() => _BuildGaransiState();
}

class _BuildGaransiState extends State<BuildGaransi> {
  int estimasiHarga = 0;
  double initialBottomSheet = 0.7;
  double minBottomSheet = 0.5;
  double maxBottomSheet = 0.95;

  final firestoreInstance2 =
      FirebaseFirestore.instanceFor(app: Firebase.app("SecondaryApp"));
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: ListView.builder(
          itemCount: widget.garansi.data.length,
          itemBuilder: (context, i) {
            var tglService =
                num.parse(widget.garansi.data[i].barang.data[i].garansiService);
            DateTime tglAktivasi = DateTime.parse(widget
                .garansi.data[i].cekGaransi.data[i].tglAktivasi
                .toString());
            var newDateService = new DateTime(tglAktivasi.year,
                tglAktivasi.month + tglService, tglAktivasi.day);
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  AppBarWidget(
                    title: "Scan Result",
                    back: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  BuildDetailGaransiImage(garansi: widget.garansi, i: i),
                  SizedBox(
                    height: 30,
                  ),
                  BuildDetailGaransi(garansi: widget.garansi, i: i),
                  BuildMasaGaransi(
                      garansi: widget.garansi,
                      newDateService: newDateService,
                      i: i),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: firestoreInstance2
                                .collection('IPR')
                                .where('draft', isEqualTo: true)
                                .where('createdBy', isEqualTo: 'Z05')
                                .snapshots(),
                            builder: (context, snapshotDraft) {
                              return snapshotDraft.data == null
                                  ? Container()
                                  : snapshotDraft.data.docs.length == 1
                                      ? ButtonIcon(
                                          large: true,
                                          circleIcon: false,
                                          onTap: () {
                                            Get.toNamed(Routes.IPR, arguments: [
                                              snapshotDraft.data.docs[0]
                                                  ['noIpr'],
                                              widget.barcode
                                            ]);
                                          },
                                          text: "Buat IPR",
                                          buttonColor: Colors.blue,
                                          icon: Icons.home)
                                      : FutureBuilder<AutoNumber>(
                                          future: IPRService().autoNumber(),
                                          builder: (context, sn) {
                                            return ButtonIcon(
                                                large: true,
                                                circleIcon: false,
                                                onTap: () => Get.toNamed(
                                                        Routes.IPR,
                                                        arguments: [
                                                          sn.data.noIpr,
                                                          widget.barcode
                                                        ]),
                                                text: "Buat IPR",
                                                buttonColor: Colors.blue,
                                                icon: Icons.home);
                                          });
                            }),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class BuildMasaGaransi extends StatelessWidget {
  const BuildMasaGaransi(
      {Key key,
      @required this.garansi,
      @required this.newDateService,
      @required this.i})
      : super(key: key);

  final Garansi garansi;
  final DateTime newDateService;
  final i;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: kPrimaryColor, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Masa garansi",
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Service',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Divider(
                color: Colors.white,
              ),
              IntrinsicHeight(
                  child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Text(
                        'Service',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        garansi.data[i].barang.data[i].garansiService +
                            ' Bulan',
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    thickness: 0.5,
                    color: Colors.white,
                  ),
                  Column(
                    children: [
                      Text('Sampai Dengan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        newDateService.toString(),
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.blueGrey, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Masa garansi",
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Sparepart',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Divider(
                color: Colors.white,
              ),
              IntrinsicHeight(
                  child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Text(
                        'Sparepart',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        garansi.data[i].barang.data[i].garansiSp == '0'
                            ? 'Tidak Di Cover'
                            : garansi.data[i].barang.data[i].garansiSp,
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    thickness: 0.5,
                    color: Colors.white,
                  ),
                  Column(
                    children: [
                      Text('Sampai Dengan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        garansi.data[i].barang.data[i].garansiSp == '0'
                            ? 'Tidak Di Cover'
                            : garansi.data[i].barang.data[i].garansiSp,
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              )),
            ],
          ),
        )
      ],
    );
  }
}

class BuildDetailGaransi extends StatelessWidget {
  const BuildDetailGaransi({
    Key key,
    @required this.garansi,
    @required this.i,
  }) : super(key: key);

  final Garansi garansi;
  final i;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
          child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: [
              Text(
                'No Garansi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                garansi.data[i].noGaransi,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 2,
          ),
          Column(
            children: [
              Text('Pendaftar', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                garansi.data[i].cekGaransi.data[i].detailCustomerFios.data[0]
                    .namaUserCust,
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 2,
          ),
          Column(
            children: [
              Text('Tgl Aktivasi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                garansi.data[i].cekGaransi.data[i].tglAktivasi.toString(),
                style: TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      )),
    );
  }
}

class BuildDetailGaransiImage extends StatelessWidget {
  const BuildDetailGaransiImage({
    Key key,
    @required this.garansi,
    @required this.i,
  }) : super(key: key);

  final Garansi garansi;
  final i;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          color: Color(0xFFEEEEEE),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          width: double.infinity,
          height: 120,
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
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 200,
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            garansi.data[i].barcode,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.0),
                            maxLines: 2,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                      text: garansi.data[i].barcode))
                                  .whenComplete(() {
                                Fluttertoast.showToast(
                                    msg: "Copy ke clipboard");
                              });
                            },
                            child: Icon(
                              Icons.copy,
                              size: 13,
                            ),
                          )
                        ],
                      ),
                      Text(
                        garansi.data[i].barang.data[i].namaBarang,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.bold),
                        maxLines: 2,
                      ),
                    ],
                  )),
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.teal, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  garansi.data[i].barang.data[i].kategori,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        Positioned(
          right: 30,
          top: 5,
          child: Image.network(
            "https://fios.firmanindonesia.com/asset/produk_real/" +
                garansi.data[i].barang.data[i].kdBarang +
                "/" +
                garansi.data[i].barang.data[i].brosurFios.data[i].gambar,
            width: 120,
          ),
        ),
      ],
    );
  }
}
