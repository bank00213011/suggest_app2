import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

List<Map> _tumbonJson = [
  {"id": '1', "name": "ทะเลชุบศร"},
  {"id": '2', "name": "ท่าหิน"},
];

class PlaceAdd extends StatefulWidget {
  final UserModel my_account;

  PlaceAdd({Key? key, required this.my_account}) : super(key: key);
  @override
  _PlaceAdd createState() => _PlaceAdd();
}

class _PlaceAdd extends State<PlaceAdd> {
  //ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? name, detail, day, tumbon, address, _tumbon;

  final nameController = TextEditingController();
  final detailController = TextEditingController();
  final dayController = TextEditingController();
  final addressController = TextEditingController();

  final picker = ImagePicker();

  //CroppedFile? croppedFile;
  List photoList = [];

  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  double? latitude, longitude;
  LatLng? _initialPosition;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
    markers.clear();

    nameController.addListener(() => setState(() {}));
    detailController.addListener(() => setState(() {}));
    dayController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));

    nameController.text = '';
    detailController.text = '';
    dayController.text = '';
    addressController.text = '';
  }

  @override
  void dispose() {
    detailController.dispose();
    dayController.dispose();
    addressController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void selectImages() async {
    // var res = await Utils.pickImages(context);
    // setState(() {
    //   photoList = res;
    // });

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
                    // croppedFile = await ImageCropper().cropImage(
                    //   sourcePath: pickedFile.path,
                    //   uiSettings: [
                    //     AndroidUiSettings(
                    //       toolbarTitle: "ตัดรูปภาพ",
                    //       toolbarColor: Colors.green[700],
                    //       toolbarWidgetColor: Colors.white,
                    //       activeControlsWidgetColor: Colors.green[700],
                    //       initAspectRatio: CropAspectRatioPreset.original,
                    //       lockAspectRatio: false,
                    //     ),
                    //     IOSUiSettings(
                    //       title: "ตัดรูปภาพ",
                    //     ),
                    //   ],
                    // );
                    // if (croppedFile != null) {
                    setState(() {
                      photoList.add(File(pickedFile.path));
                    });
                    // }
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
                    // croppedFile = await ImageCropper().cropImage(
                    //   sourcePath: pickedFile.path,
                    //   uiSettings: [
                    //     AndroidUiSettings(
                    //       toolbarTitle: "ตัดรูปภาพ",
                    //       toolbarColor: Colors.green[700],
                    //       toolbarWidgetColor: Colors.white,
                    //       activeControlsWidgetColor: Colors.green[700],
                    //       initAspectRatio: CropAspectRatioPreset.original,
                    //       lockAspectRatio: false,
                    //     ),
                    //     IOSUiSettings(
                    //       title: "ตัดรูปภาพ",
                    //     ),
                    //   ],
                    // );
                    // if (croppedFile != null) {
                    setState(() {
                      photoList.add(File(pickedFile!.path));
                    });
                    // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มสถานที่'),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildGoogleMap(),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  buildPhoto(),

                  const SizedBox(height: 10),
                  buildName(),
                  const SizedBox(height: 5),
                  buildAddress(),
                  const SizedBox(height: 5),
                  buildDay(),
                  const SizedBox(height: 5),
                  buildDetail(),
                  // const SizedBox(height: 10),
                  // buildTumbon(),
                  //const SizedBox(height: 5),
                  // buildCategory(),
                  const SizedBox(height: 10),
                  buildButton(),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget buildGoogleMap() => SizedBox(
      height: 200,
      child: GoogleMap(
        zoomGesturesEnabled: true,
        onTap: (LatLng latLng) {
          markers.clear();

          latitude = latLng.latitude;
          longitude = latLng.longitude;

          print('${latitude.toString()}  ${longitude.toString()}');
          setState(() {
            markers.add(Marker(
              markerId: const MarkerId('id'),
              position: LatLng(latitude!, longitude!), //position of marker
              infoWindow: InfoWindow(
                title: "จุดพิกัด",
              ),
              icon: BitmapDescriptor.defaultMarker, //Icon for Marker
            ));
          });
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.7244416, 100.3529099),
          zoom: 5.0,
        ),
        markers: markers,
        mapType: MapType.normal, //map type
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ));

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

  // Widget buildImageAsset() => Column(
  //       children: [
  //         imagePath != ''
  //             ? Stack(
  //                 children: [
  //                   Container(
  //                     width: double.infinity,
  //                     height: 150,
  //                     padding: EdgeInsets.symmetric(horizontal: 15),
  //                     child: Image.file(
  //                       File(imagePath),
  //                       height: 150,
  //                     ),
  //                   ),
  //                   Positioned(
  //                     top: 0,
  //                     right: 8.0,
  //                     child: CircleAvatar(
  //                       radius: 10,
  //                       backgroundColor: Colors.black,
  //                       child: GestureDetector(
  //                           onTap: () => setState(() {
  //                                 imagePath = '';
  //                               }),
  //                           child: Icon(
  //                             Icons.close,
  //                             color: Colors.white,
  //                             size: 12,
  //                           )),
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : GestureDetector(
  //                 onTap: () => chooseGallery(context),
  //                 child: Container(
  //                   margin: const EdgeInsets.all(5),
  //                   child: DottedBorder(
  //                     borderType: BorderType.RRect,
  //                     radius: const Radius.circular(10),
  //                     dashPattern: const [10, 4],
  //                     strokeCap: StrokeCap.round,
  //                     child: Container(
  //                       width: double.infinity,
  //                       height: 100,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const Icon(
  //                             Icons.folder_open,
  //                             size: 40,
  //                           ),
  //                           const SizedBox(height: 15),
  //                           Text(
  //                             'เลือกรูป',
  //                             style: TextStyle(
  //                               fontSize: 15,
  //                               color: Colors.grey.shade400,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 )),
  //       ],
  //     );

  Widget buildName() => TextFormWidget(
        text: 'ชื่อสถานที่',
        readOnly: false,
        controller: nameController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildDetail() => TextFormBodyWidget(
        text: 'รายละเอียด',
        readOnly: false,
        controller: detailController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildDay() => TextFormWidget(
        text: 'วันเวลาเปิดปิด',
        readOnly: false,
        controller: dayController,
        type: TextInputType.text,
        inputFormat: [],
      );

  // แสดงช่องกรอกจำนวน
  Widget buildAddress() => TextFormWidget(
        text: 'ที่อยู่',
        readOnly: false,
        controller: addressController,
        type: TextInputType.text,
        inputFormat: [],
      );

  // Widget buildCategory() => Container(
  //     width: double.infinity,
  //     height: 50,
  //     decoration: BoxDecoration(
  //         border: Border.all(width: 2, color: const Color(0x6B57636C)),
  //         borderRadius: BorderRadius.circular(12)),
  //     child: DropdownButtonHideUnderline(
  //       child: ButtonTheme(
  //         alignedDropdown: true,
  //         child: DropdownButton<String>(
  //           isDense: true,
  //           isExpanded: true,
  //           hint: Text('กรุณาเลือกหมวดหมู่'),
  //           value: _category,
  //           onChanged: (String? newValue) {
  //             setState(() {
  //               _category = newValue.toString().trim();
  //             });
  //           },
  //           items: ["ร้านอาหาร", "สถานที่ท่องเที่ยว", "ที่พัก"]
  //               .map((e) => DropdownMenuItem(
  //                     child: Container(
  //                       alignment: Alignment.center,
  //                       child: Row(
  //                         children: [Text(e)],
  //                       ),
  //                     ),
  //                     value: e,
  //                   ))
  //               .toList(),
  //         ),
  //       ),
  //     ));

  setGridSize(int length) {
    if (length < 4) {
      return 100.0;
    } else if (length == 4 || length <= 7) {
      return 200.0;
    } else {
      return 300.0;
    }
  }

  Widget buildButton() => ButtonWidget(
      label: 'เพิ่มสถานที่', onPressed: () => save_data(), color: Colors.blue);

  // ฟังก์ชัน save_data
  void save_data() async {
    FocusScope.of(context).unfocus();
    final name = nameController.text.trim();
    final detail = detailController.text.trim();
    final day = dayController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อก่อน', Colors.red);
      return;
    }

    if (detail.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รายละเอียด', Colors.red);
      return;
    }

    if (day.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่วันเวลาเปิดปิด', Colors.red);
      return;
    }

    if (address.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ที่อยู่', Colors.red);
      return;
    }

    if (latitude == null || longitude == null) {
      Utils.showToast(context, 'กรุณาเลือกพิกัดก่อน', Colors.red);
      return;
    }

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    List<String> ImageUrl = [];
    await Future.wait(photoList.map((_image) async =>
            ImageUrl.add(await FireStorageApi.uploadPhoto(_image, 'Place'))))
        .whenComplete(() => print('Upload Success'));

    GeoPoint location = GeoPoint(latitude!, longitude!);

    String id = DateTime.now().millisecondsSinceEpoch.toString();

    final docPlace =
        FirebaseFirestore.instance.collection('suggest_place').doc(id);
    await docPlace.set({
      'address': address,
      'category': "fitness",
      'dateTime': DateTime.now(),
      'day': day,
      'detail': detail,
      'location': location,
      'name': name,
      'photo': ImageUrl,
      'place_id': id,
      'rating': 0,
      'user_id': widget.my_account.user_id
    }).whenComplete(() => null);

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.postData('/place/', {
          'address': address,
          'category': "fitness",
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'day': day,
          'detail': detail,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'name': name,
          'photo': ImageUrl.toString(),
          'place_id': id,
          'rating': 0,
          'user_id': widget.my_account.user_id
        });
      }
    }

    Navigator.of(context).pop(false);
    EasyLoading.dismiss();
  }
}
