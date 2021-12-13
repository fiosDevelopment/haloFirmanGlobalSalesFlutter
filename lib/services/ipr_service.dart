import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class IPRService {
  final firestoreInstance2 =
      FirebaseFirestore.instanceFor(app: Firebase.app("SecondaryApp"));

  Future<AutoNumber> autoNumber() async {
    final response = await http.post(
        Uri.parse(
            'https://fios.firmanindonesia.com/haloFirman/IPR/autoNumber.php'),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "kd_user": 'Z05',
        });
    if (response.statusCode == 200) {
      return AutoNumber.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<IprInput> iprInput(String noIpr, String nik, String kdDiv,
      String kdBarcode, String referensi) async {
    final response = await http.post(
        Uri.parse(
            'https://fios.firmanindonesia.com/haloFirman/IPR/iprInput.php'),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "no_ipr": noIpr,
          "nik": nik,
          "kd_divisi": kdDiv,
          "kd_barcode": kdBarcode,
          "referensi": referensi,
        });

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprInputFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future saveIprToFirebase(noIprConvert, noipr, kelompok, kdBarcode) async {
    await firestoreInstance2.collection('IPR').doc(noIprConvert).set({
      'noIpr': noipr,
      'draft': true,
      'createdBy': 'Z05',
    });

    await firestoreInstance2
        .collection('IPR')
        .doc(noIprConvert)
        .collection('ipr_produk')
        .doc(kelompok)
        .set({
      'kasusDone': 'no',
      'kelompok': kelompok,
    });

    await firestoreInstance2
        .collection('IPR')
        .doc(noIprConvert)
        .collection('ipr_produk')
        .doc(kelompok)
        .collection('barcode')
        .doc(kdBarcode)
        .set({
      'kelompok': kelompok,
      'kdBarcode': kdBarcode,
    });
  }

  Future<List<CariListBarang>> cariListBarang(String jenis) async {
    try {
      http.Response hasil = await http.post(
          Uri.parse(
              "https://fios.firmanindonesia.com/haloFirman/IPR/cariListBarang.php"),
          headers: {
            "Accept": "application/json",
          },
          body: {
            "jenis": jenis,
          });
      if (hasil.statusCode == 200) {
        final data = cariListBarangFromJson(hasil.body);
        return data;
      } else {
        print("error status " + hasil.statusCode.toString());
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print("error catch $e");
      throw Exception('error catch $e');
    }
  }

  Future<IprListBarang> iprListBarang(String noIpr, String kelompok) async {
    try {
      http.Response hasil = await http.post(
          Uri.parse(
              "https://fios.firmanindonesia.com/haloFirman/IPR/iprListBarang.php"),
          headers: {
            "Accept": "application/json",
          },
          body: {
            "no_ipr": noIpr,
            "kelompok": kelompok,
          });
      if (hasil.statusCode == 200) {
        final data = iprListBarangFromJson(hasil.body);
        return data;
      } else {
        print("error status " + hasil.statusCode.toString());
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print('error catch $e');
      throw Exception('Ferror catch $e');
    }
  }

  Future iprTambahKelompok(String noIpr, String kelompok) async {
    String url =
        'https://fios.firmanindonesia.com/haloFirman/IPR/iprKelompok.php';
    final response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json",
    }, body: {
      "no_ipr": noIpr,
      "kelompok": kelompok,
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprDeleteFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future iprTambahUser(String noIpr, String nik, String jenis) async {
    String url =
        'https://fios.firmanindonesia.com/haloFirman/IPR/iprTambahUser.php';
    final response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json",
    }, body: {
      "no_ipr": noIpr,
      "nik": nik,
      "jenis": jenis,
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprDeleteFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<DetailUser> detailUser() async {
    String url =
        'https://fios.firmanindonesia.com/haloFirman/IPR/detailUser.php';
    final response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json",
    }, body: {
      "kd_user": 'Z05',
    });
    if (response.statusCode == 200) {
      return DetailUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List<IprUserList>> iprUserList() async {
    try {
      http.Response hasil = await http.get(
          Uri.parse(
              "https://fios.firmanindonesia.com/haloFirman/IPR/iprUser.php"),
          headers: {
            "Accept": "application/json",
          });
      if (hasil.statusCode == 200) {
        final data = iprUserListFromJson(hasil.body);
        print(data);
        return data;
      } else {
        print("error status " + hasil.statusCode.toString());
        return null;
      }
    } catch (e) {
      print("error catch $e");
      return null;
    }
  }

  Future iprSimpanAll(String noIpr, String nik) async {
    String url =
        'https://fios.firmanindonesia.com/haloFirman/IPR/iprSimpanAll.php';
    final response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json",
    }, body: {
      "no_ipr": noIpr,
      "nik": nik,
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprDeleteFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<IprListPart> iprListPart(String noIpr, String kelompok) async {
    try {
      http.Response hasil = await http.post(
          Uri.parse(
              "https://fios.firmanindonesia.com/haloFirman/IPR/iprListPart.php"),
          headers: {
            "Accept": "application/json",
          },
          body: {
            "no_ipr": noIpr,
            "kelompok": kelompok,
          });
      if (hasil.statusCode == 200) {
        final data = iprListPartFromJson(hasil.body);
        return data;
      } else {
        return Future.error("error status " + hasil.statusCode.toString());
      }
    } catch (e) {
      return Future.error("error catch $e");
    }
  }

  Future iprDeletePart(String kdPart, String noIpr, String kelompok) async {
    String url =
        'https://fios.firmanindonesia.com/haloFirman/IPR/iprHapusPart.php';
    final response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json",
    }, body: {
      "kd_part": kdPart,
      "no_ipr": noIpr,
      "kelompok": kelompok,
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprDeleteFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future iprDelete(
      String kdBarang, String kdBarcode, String noIpr, String kelompok) async {
    final response = await http.post(
        Uri.parse(
            'https://fios.firmanindonesia.com/haloFirman/IPR/iprHapus.php'),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "kd_barang": kdBarang,
          "kd_barcode": kdBarcode,
          "no_ipr": noIpr,
          "kelompok": kelompok,
        });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      final data = iprDeleteFromJson(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List<Map<String, String>>> getSuggestions(
      String query, String jenis, String kategori) async {
    if (query.isEmpty && query.length < 2) {
      print('Input minimal 2 karakter');
      return Future.value([]);
    }
    // var url = Uri.https('fios.firmanindonesia.com/haloFirman/IPR/cariProduk.php', '/sug', {'s': query});
    var url = Uri.parse(
        'https://fios.firmanindonesia.com/haloFirman/IPR/cariProduk.php?jenis=$jenis&kategori=$kategori&search=$query');

    var response = await http.get(url);
    List<Suggestion> suggestions = [];
    if (response.statusCode == 200) {
      Iterable json = convert.jsonDecode(response.body);
      suggestions = List<Suggestion>.from(
          json.map((model) => Suggestion.fromJson(model)));

      print('Number of suggestion: ${suggestions.length}.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return Future.value(suggestions
        .map((e) => {'kdBarang': e.kdBarang, 'namaBarang': e.namaBarang})
        .toList());
  }
}
