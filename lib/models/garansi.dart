// To parse this JSON data, do
//
//     final garansi = garansiFromJson(jsonString);

import 'dart:convert';

Garansi garansiFromJson(String str) => Garansi.fromJson(json.decode(str));

String garansiToJson(Garansi data) => json.encode(data.toJson());

class Garansi {
  Garansi({
    this.data,
  });

  List<GaransiDatum> data;

  factory Garansi.fromJson(Map<String, dynamic> json) => Garansi(
        data: List<GaransiDatum>.from(
            json["data"].map((x) => GaransiDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class GaransiDatum {
  GaransiDatum({
    this.barcode,
    this.noGaransi,
    this.cekGaransi,
    this.barang,
  });

  String barcode;
  String noGaransi;
  CekGaransi cekGaransi;
  Barang barang;

  factory GaransiDatum.fromJson(Map<String, dynamic> json) => GaransiDatum(
        barcode: json["barcode"],
        noGaransi: json["no_garansi"],
        cekGaransi: CekGaransi.fromJson(json["CekGaransi"]),
        barang: Barang.fromJson(json["Barang"]),
      );

  Map<String, dynamic> toJson() => {
        "barcode": barcode,
        "no_garansi": noGaransi,
        "CekGaransi": cekGaransi.toJson(),
        "Barang": barang.toJson(),
      };
}

class Barang {
  Barang({
    this.data,
  });

  List<BarangDatum> data;

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        data: List<BarangDatum>.from(
            json["data"].map((x) => BarangDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class BarangDatum {
  BarangDatum({
    this.kdBarang,
    this.namaBarang,
    this.kategori,
    this.garansiService,
    this.garansiSp,
    this.brosurFios,
  });

  String kdBarang;
  String namaBarang;
  String kategori;
  String garansiService;
  String garansiSp;
  BrosurFios brosurFios;

  factory BarangDatum.fromJson(Map<String, dynamic> json) => BarangDatum(
        kdBarang: json["kd_barang"],
        namaBarang: json["nama_barang"],
        kategori: json["kategori"],
        garansiService: json["garansi_service"],
        garansiSp: json["garansi_sp"],
        brosurFios: BrosurFios.fromJson(json["BrosurFIOS"]),
      );

  Map<String, dynamic> toJson() => {
        "kd_barang": kdBarang,
        "nama_barang": namaBarang,
        "kategori": kategori,
        "garansi_service": garansiService,
        "garansi_sp": garansiSp,
        "BrosurFIOS": brosurFios.toJson(),
      };
}

class BrosurFios {
  BrosurFios({
    this.data,
  });

  List<BrosurFiosDatum> data;

  factory BrosurFios.fromJson(Map<String, dynamic> json) => BrosurFios(
        data: List<BrosurFiosDatum>.from(
            json["data"].map((x) => BrosurFiosDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class BrosurFiosDatum {
  BrosurFiosDatum({
    this.kdBarang,
    this.gambar,
  });

  int kdBarang;
  String gambar;

  factory BrosurFiosDatum.fromJson(Map<String, dynamic> json) =>
      BrosurFiosDatum(
        kdBarang: json["kd_barang"],
        gambar: json["gambar"],
      );

  Map<String, dynamic> toJson() => {
        "kd_barang": kdBarang,
        "gambar": gambar,
      };
}

class CekGaransi {
  CekGaransi({
    this.data,
  });

  List<CekGaransiDatum> data;

  factory CekGaransi.fromJson(Map<String, dynamic> json) => CekGaransi(
        data: List<CekGaransiDatum>.from(
            json["data"].map((x) => CekGaransiDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CekGaransiDatum {
  CekGaransiDatum({
    this.namaPemilik,
    this.alamat,
    this.noTelp,
    this.tglAktivasi,
    this.detailCustomerFios,
  });

  String namaPemilik;
  String alamat;
  String noTelp;
  DateTime tglAktivasi;
  DetailCustomerFios detailCustomerFios;

  factory CekGaransiDatum.fromJson(Map<String, dynamic> json) =>
      CekGaransiDatum(
        namaPemilik: json["nama_pemilik"],
        alamat: json["alamat"],
        noTelp: json["no_telp"],
        tglAktivasi: DateTime.parse(json["tgl_aktivasi"]),
        detailCustomerFios:
            DetailCustomerFios.fromJson(json["DetailCustomerFIOS"]),
      );

  Map<String, dynamic> toJson() => {
        "nama_pemilik": namaPemilik,
        "alamat": alamat,
        "no_telp": noTelp,
        "tgl_aktivasi": tglAktivasi.toIso8601String(),
        "DetailCustomerFIOS": detailCustomerFios.toJson(),
      };
}

class DetailCustomerFios {
  DetailCustomerFios({
    this.data,
  });

  List<DetailCustomerFiosDatum> data;

  factory DetailCustomerFios.fromJson(Map<String, dynamic> json) =>
      DetailCustomerFios(
        data: List<DetailCustomerFiosDatum>.from(
            json["data"].map((x) => DetailCustomerFiosDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DetailCustomerFiosDatum {
  DetailCustomerFiosDatum({
    this.namaUserCust,
    this.customerFios,
  });

  String namaUserCust;
  CustomerFios customerFios;

  factory DetailCustomerFiosDatum.fromJson(Map<String, dynamic> json) =>
      DetailCustomerFiosDatum(
        namaUserCust: json["nama_user_cust"],
        customerFios: CustomerFios.fromJson(json["CustomerFIOS"]),
      );

  Map<String, dynamic> toJson() => {
        "nama_user_cust": namaUserCust,
        "CustomerFIOS": customerFios.toJson(),
      };
}

class CustomerFios {
  CustomerFios({
    this.data,
  });

  List<CustomerFiosDatum> data;

  factory CustomerFios.fromJson(Map<String, dynamic> json) => CustomerFios(
        data: List<CustomerFiosDatum>.from(
            json["data"].map((x) => CustomerFiosDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CustomerFiosDatum {
  CustomerFiosDatum({
    this.namaCust,
  });

  String namaCust;

  factory CustomerFiosDatum.fromJson(Map<String, dynamic> json) =>
      CustomerFiosDatum(
        namaCust: json["nama_cust"],
      );

  Map<String, dynamic> toJson() => {
        "nama_cust": namaCust,
      };
}
