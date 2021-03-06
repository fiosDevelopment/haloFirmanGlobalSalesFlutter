import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/core.dart';
import 'package:halo_firman_sales/models/file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'dart:io';

import 'package:storage_path/storage_path.dart';

class PostView extends StatefulWidget {
  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  List<FileModel> files;
  final ImagePicker _picker = ImagePicker();
  FileModel selectedModel;
  String image;

  @override
  void initState() {
    super.initState();
    getImagesPath();
  }

  getImagesPath() async {
    var imagePath = await StoragePath.imagesPath;
    var images = jsonDecode(imagePath) as List;
    files = images.map<FileModel>((e) => FileModel.fromJson(e)).toList();
    if (files != null && files.length > 0)
      setState(() {
        selectedModel = files[0];
        image = files[0].files[0];
      });
  }

  Future handleTakePhoto() async {
    final file =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    Get.toNamed(Routes.POST_CATION, arguments: file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => Get.back(), child: Icon(Icons.clear)),
                      SizedBox(width: 10),
                      DropdownButtonHideUnderline(
                          child: DropdownButton<FileModel>(
                        items: getItems(),
                        onChanged: (FileModel d) {
                          assert(d.files.length > 0);
                          image = d.files[0];
                          setState(() {
                            selectedModel = d;
                          });
                        },
                        value: selectedModel,
                      ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(LineIcons.camera),
                          onPressed: () => handleTakePhoto()),
                      IconButton(
                        onPressed: () =>
                            Get.toNamed(Routes.POST_CATION, arguments: image),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Divider(),
            Container(
                height: MediaQuery.of(context).size.height * 0.43,
                child: image != null
                    ? Image.file(File(image),
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width)
                    : Container()),
            Divider(),
            selectedModel == null && selectedModel.files.length < 1
                ? Container()
                : Container(
                    height: MediaQuery.of(context).size.height * 0.38,
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4),
                        itemBuilder: (_, i) {
                          var file = selectedModel.files[i];
                          return GestureDetector(
                            child: Image.file(
                              File(file),
                              fit: BoxFit.cover,
                            ),
                            onTap: () {
                              setState(() {
                                image = file;
                              });
                            },
                          );
                        },
                        itemCount: selectedModel.files.length),
                  )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> getItems() {
    return files
            .map((e) => DropdownMenuItem(
                  child: Text(
                    e.folder,
                    style: TextStyle(color: Colors.black),
                  ),
                  value: e,
                ))
            .toList() ??
        [];
  }
}
