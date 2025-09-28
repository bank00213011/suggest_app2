import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:suggest/api/firestorage_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/widget/button_widget.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:suggest/widget/textformbody_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/utils.dart';

class BoardAdd extends StatefulWidget {
  final UserModel my_account;

  BoardAdd({Key? key, required this.my_account}) : super(key: key);
  @override
  _BoardAdd createState() => _BoardAdd();
}

class _BoardAdd extends State<BoardAdd> {
  //ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? header, body;

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  final picker = ImagePicker();
  String imagePath = '';
  List photoList = [];

  @override
  void initState() {
    super.initState();
    titleController.addListener(() => setState(() {}));
    bodyController.addListener(() => setState(() {}));

    titleController.text = '';
    bodyController.text = '';
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();

    super.dispose();
  }

  void selectImages() async {
    if (photoList.length > 10) {
      Utils.showToast(context, "เลือกรูปได้ไม่เกิน 10 รูป", Colors.red);
      return;
    }

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              '⭐ กรุณาเลือกรายการ',
              style: TextStyle(fontSize: 18),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 40,
                      maxHeight: 600,
                      maxWidth: 600);
                  if (pickedFile != null) {
                    setState(() {
                      photoList.add(File(pickedFile.path));
                    });
                  }
                },
                child: const Text(
                  'ถ่ายรูป',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 40,
                      maxHeight: 600,
                      maxWidth: 600);
                  if (pickedFile != null) {
                    setState(() {
                      photoList.add(File(pickedFile.path));
                    });
                  }
                },
                child: const Text(
                  'เลือกรูป',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        });
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('เพิ่มข่าวสาร'),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    buildImageAsset(),
                    const SizedBox(height: 5),
                    buildTitle(),
                    const SizedBox(height: 5),
                    buildBody(),
                    // const SizedBox(height: 5),
                    // buildCategory(),
                    const SizedBox(height: 10),
                    buildButton(),
                  ],
                ),
              )),
        ));
  }

  Widget buildImageAsset() => photoList.isEmpty
      ? GestureDetector(
          onTap: selectImages,
          child: Container(
            margin: const EdgeInsets.all(5),
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              dashPattern: const [10, 4],
              strokeCap: StrokeCap.round,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_open,
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "เลือกรูปภาพ",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))
      : SizedBox(
          height: setGridSize(photoList.length),
          child: ReorderableGridView.count(
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 4,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final element = photoList.removeAt(oldIndex);
                photoList.insert(newIndex, element);
              });
            },
            footer: [
              GestureDetector(
                  onTap: selectImages,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: const [10, 4],
                      strokeCap: StrokeCap.round,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 30,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "เพิ่มรูป",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
            children: photoList.map((e) {
              return Stack(
                key: ValueKey(e),
                children: [
                  Card(
                      child: Center(
                          child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(e), fit: BoxFit.cover)),
                  ))),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black,
                      child: GestureDetector(
                          onTap: () => setState(() {
                                photoList.removeAt(photoList.indexOf(e));
                              }),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          )),
                    ),
                  ),
                ],
              );
            }).toList(),
          ));

  Widget buildTitle() => TextFormWidget(
        text: 'ชื่อหัวเรื่อง',
        readOnly: false,
        controller: titleController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildBody() => TextFormBodyWidget(
        text: 'รายละเอียด',
        readOnly: false,
        controller: bodyController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildButton() => ButtonWidget(
      label: 'เพิ่มกระทู้', onPressed: () => save_data(), color: Colors.blue);

  setGridSize(int length) {
    if (length < 4) {
      return 100.0;
    } else if (length == 4 || length <= 7) {
      return 200.0;
    } else {
      return 300.0;
    }
  }

  void save_data() async {
    FocusScope.of(context).unfocus();
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อก่อน', Colors.red);
      return;
    }

    if (body.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รายละเอียดก่อน', Colors.red);
      return;
    }

    print(imagePath);

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    var id = DateTime.now().millisecondsSinceEpoch.toString();
    List<String> ImageUrl = [];
    await Future.wait(photoList.map((_image) async =>
            ImageUrl.add(await FireStorageApi.uploadPhoto(_image, 'Board'))))
        .whenComplete(() => print('Upload Success'));

    final docBoard =
        FirebaseFirestore.instance.collection('suggest_board').doc(id);
    await docBoard.set({
      'board_id': id,
      'body': body,
      'dateTime': DateTime.now(),
      'category': "fitness",
      'title': title,
      'photo': ImageUrl,
      'user_id': widget.my_account.user_id
    });
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.postData('/board/', {
          'board_id': id,
          'body': body,
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'category': "fitness",
          'title': title,
          'photo': ImageUrl.join(','),
          'user_id': widget.my_account.user_id
        });
      }
    }

    Navigator.of(context).pop(false);
    EasyLoading.dismiss();
  }
}
