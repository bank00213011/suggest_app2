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
import 'package:suggest/model/board.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';

class BoardEdit extends StatefulWidget {
  final Board board;
  final UserModel my_account;

  BoardEdit({Key? key, required this.board, required this.my_account})
      : super(key: key);
  @override
  _BoardEdit createState() => _BoardEdit();
}

class _BoardEdit extends State<BoardEdit> {
  //ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? photo;
  String title = '', body = '';

  final picker = ImagePicker();
  List photoList = [];
  List photoListDelete = [];

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
    title = widget.board.title;
    body = widget.board.body;
    photoList = widget.board.photo;

    titleController.addListener(() => setState(() {}));
    bodyController.addListener(() => setState(() {}));

    titleController.text = title;
    bodyController.text = body;
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
                      photoList.add(pickedFile.path);
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
                      photoList.add(pickedFile.path);
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
          title: const Text('แก้ไขกระทู้'),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    buildPhoto(),
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

  Widget buildPhoto() => photoList.isEmpty
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
                          child: e.toString().substring(0, 1) == '/'
                              ? Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: FileImage(File(e)),
                                          fit: BoxFit.cover)),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(e),
                                          fit: BoxFit.cover)),
                                ))),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black,
                      child: GestureDetector(
                          onTap: () => setState(() {
                                if (photoList.length <= 1) {
                                  Utils.showToast(context,
                                      'ไม่สามารถลบรูปทั้งหมดได้', Colors.red);
                                  return;
                                } else {
                                  photoList.removeAt(photoList.indexOf(e));
                                  photoListDelete.add(e);
                                }
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
      label: 'แก้ไขกระทู้', onPressed: () => save_data(), color: Colors.blue);

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

    print(widget.board.board_id);
    print(title);

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    List<String> ImageUrl = [];
    for (String _image in photoList) {
      if (_image.toString().substring(0, 1) == '/') {
        ImageUrl.add(await FireStorageApi.uploadPhoto(File(_image), 'Board'));
      } else {
        ImageUrl.add(_image);
      }
    }

    for (String delete in photoListDelete) {
      FireStorageApi.removePhoto(delete);
    }

    await FirebaseFirestore.instance
        .collection('suggest_board')
        .doc(widget.board.board_id)
        .update({
      'body': body,
      'catagory': "fitness",
      'title': title,
      'photo': ImageUrl,
    });

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.updateData('/board/board_edit.php', {
          'board_id': widget.board.board_id,
          'body': body,
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'catagory': "fitness",
          'title': title,
          'photo': ImageUrl.join(','),
          'user_id': widget.board.user_id
        });
      }
    }

    EasyLoading.dismiss();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => MainUser(
                my_account: widget.my_account,
                from: 'board',
              )),
      (Route<dynamic> route) => false,
    );
  }
}
