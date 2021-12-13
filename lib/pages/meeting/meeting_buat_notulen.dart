import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../core.dart';

class BuatNotulenView extends StatefulWidget {
  @override
  State<BuatNotulenView> createState() => _BuatNotulenViewState();
}

class _BuatNotulenViewState extends State<BuatNotulenView> {
  TextEditingController notulenController = TextEditingController();

  ListMeeting controller = Get.arguments;
  bool _isLoading = false;

  _validateInputs() {
    setState(() {
      _isLoading = true;
    });

    if (notulenController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Form tidak boleh kosong");
      setState(() {
        _isLoading = false;
      });
    } else {
      MeetingService()
          .buatNotulenMeeting(notulenController.text, controller.meetingid)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
          notulenController.text = '';
        });
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
          child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBarWidget(
                title: "Buat notulen",
                back: true,
              ),
              Container(
                margin:
                    EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Form(
                  child: formUI(context),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget formUI(BuildContext context) {
    return new Column(
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 20,
            controller: notulenController,
            decoration: InputDecoration(
              hintText: "Tulis notulen...",
              border: InputBorder.none,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: new ElevatedButton(
            onPressed: _isLoading == false ? _validateInputs : () {},
            style: ElevatedButton.styleFrom(
              primary: kPrimaryColor,
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            child: _isLoading == false
                ? new Text('Buat notulen')
                : CircularProgressIndicator(),
          ),
        )
      ],
    );
  }
}
