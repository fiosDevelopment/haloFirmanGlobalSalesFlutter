import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core.dart';

class MeetingUbahTanggalView extends StatefulWidget {
  @override
  _MeetingUbahTanggalViewState createState() => _MeetingUbahTanggalViewState();
}

class _MeetingUbahTanggalViewState extends State<MeetingUbahTanggalView> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  ListMeeting controller = Get.arguments;

  _validateInputs() {
    setState(() {
      _isLoading = true;
    });
    String date = selectedDate.day.toString() +
        ' ' +
        selectedDate.month.toString() +
        ' ' +
        selectedDate.year.toString();
    String time =
        selectedTime.hour.toString() + ':' + selectedTime.minute.toString();

    String dateTime = date + " " + time;
    DateFormat dft = new DateFormat("d M yyyy HH:mm");
    DateTime d = dft.parseUtc(dateTime);
    if (_dateController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Tanggal tidak boleh kosong");
      setState(() {
        _isLoading = false;
      });
    } else if (_timeController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Jam tidak boleh kosong");
      setState(() {
        _isLoading = false;
      });
    } else {
      MeetingService()
          .ubahJadwalMeeting(d.millisecondsSinceEpoch, controller.meetingid)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
          _dateController.text = '';
          _timeController.text = '';
        });
        Get.back();
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2019, 8),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: kPrimaryColor,
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        var date =
            "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
        _dateController.text = date;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: kPrimaryColor,
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        var time = "${picked.hour} : ${picked.minute}";
        _timeController.text = time;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
        child: Container(
            height: double.infinity,
            child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    AppBarWidget(
                      title: "Ubah Tanggal",
                      back: true,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: 10, left: 15, right: 15, top: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Form(
                        child: formUI(context),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }

  Widget formUI(BuildContext context) {
    return new Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Tanggal",
              ),
              validator: (value) {
                if (value.isEmpty) return "Please enter a date for your task";
                return null;
              },
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: "Jam",
              ),
              validator: (value) {
                if (value.isEmpty) return "Please enter a date";
                return null;
              },
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
                ? new Text('Ubah')
                : CircularProgressIndicator(),
          ),
        )
      ],
    );
  }
}
