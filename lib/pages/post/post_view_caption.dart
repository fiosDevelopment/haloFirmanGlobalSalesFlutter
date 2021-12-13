import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core.dart';

class PostViewCaption extends StatefulWidget {
  @override
  _PostViewCaptionState createState() => _PostViewCaptionState();
}

class _PostViewCaptionState extends State<PostViewCaption> {
  String image = Get.arguments;

  TextEditingController captionController = TextEditingController();

  handleSubmit(BuildContext context) async {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false);
    String urlImage = await ProfileService().savePostingToServer(image);
    AuthControllerss().readPreference('uid').then((uid) {
      ProfileService()
          .tambahPosting(urlImage, uid, captionController.text)
          .whenComplete(() {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            onConfirmBtnTap: () => Get.offAllNamed('/'),
            text: 'Berhasil posting',
            barrierDismissible: false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          'Caption',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => handleSubmit(context),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(File(image)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  "https://randomuser.me/api/portraits/men/74.jpg"),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Tulis caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
