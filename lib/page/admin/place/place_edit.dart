import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:suggest/api/firestorage_api.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/favorite.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suggest/widget/button_widget.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class PlaceEdit extends StatefulWidget {
  final Place place;
  final UserModel my_account;

  const PlaceEdit(
      {Key? key, required this.place, required UserModel this.my_account})
      : super(key: key);
  @override
  _PlaceEdit createState() => _PlaceEdit();
}

class _PlaceEdit extends State<PlaceEdit> {
  //ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? place_id, name, detail, day, tumbon, address, photo;

  final nameController = TextEditingController();
  final detailController = TextEditingController();
  final dayController = TextEditingController();
  final addressController = TextEditingController();

  final picker = ImagePicker();
  //CroppedFile? croppedFile;
  List photoList = [];
  List photoListDelete = [];

  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  double? latitude, longitude;
  LatLng? _initialPosition;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
    place_id = widget.place.place_id;
    name = widget.place.name;
    detail = widget.place.detail;
    day = widget.place.day;
    address = widget.place.address;
    photoList = widget.place.photo;
    latitude = widget.place.location.latitude;
    longitude = widget.place.location.longitude;

    setState(() {
      markers.add(Marker(
        markerId: const MarkerId('id'),
        position: LatLng(widget.place.location.latitude,
            widget.place.location.longitude), //position of marker
        infoWindow: const InfoWindow(
          title: 'จุดพิกัด',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    });
    nameController.addListener(() => setState(() {}));
    detailController.addListener(() => setState(() {}));
    dayController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));

    nameController.text = name!;
    detailController.text = detail!;
    dayController.text = day!;
    addressController.text = address!;
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
                      photoList.add(pickedFile.path);
                    });
                    //  }
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
                      photoList.add(pickedFile.path);
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

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขสถานที่'),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            //  buildGoogleMap(),
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
                  // const SizedBox(height: 5),
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
              infoWindow: const InfoWindow(
                title: 'จุดพิกัด',
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

  // แสดงช่องกรอกรายการ
  Widget buildName() => TextFormWidget(
        text: 'ชื่อสถานที่',
        readOnly: false,
        controller: nameController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildDetail() => TextFormWidget(
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

// แสดง dropdown
  // Widget buildTumbon() => Container(
  //       width: double.infinity,
  //       height: 50,
  //       decoration: BoxDecoration(
  //           border: Border.all(width: 1, color: Colors.grey),
  //           borderRadius: BorderRadius.circular(0)),
  //       child: DropdownButtonHideUnderline(
  //         child: ButtonTheme(
  //           alignedDropdown: true,
  //           child: DropdownButton<String>(
  //             isDense: true,
  //             hint: const Text('กรุณาเลือกตำบล'),
  //             value: _tumbon,
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 _tumbon = newValue.toString().trim();
  //                 print(_tumbon);
  //               });
  //             },
  //             items: _tumbonJson.map((Map map) {
  //               return DropdownMenuItem<String>(
  //                 value: map["name"].toString(),
  //                 child: Row(
  //                   children: <Widget>[
  //                     Container(
  //                         margin: EdgeInsets.only(left: 10),
  //                         child: Text(map["name"])),
  //                   ],
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       ),
  //     );
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
      label: 'แก้ไขสถานที่', onPressed: () => save_data(), color: Colors.blue);

  // SizedBox(
  //       width: double.infinity,
  //       child: ElevatedButton(
  //         style: ButtonStyle(
  //           backgroundColor: MaterialStateProperty.all(Colors.blue),
  //         ),
  //         onPressed: () => save_data(),
  //         child: const Text('แก้ไขสถานที่',
  //             style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //                 letterSpacing: 0.5)),
  //       ),
  //     );

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
    for (String _image in photoList) {
      if (_image.toString().substring(0, 1) == '/') {
        ImageUrl.add(await FireStorageApi.uploadPhoto(File(_image), 'Place'));
      } else {
        ImageUrl.add(_image);
      }
    }

    for (String delete in photoListDelete) {
      FireStorageApi.removePhoto(delete);
    }

    GeoPoint location = GeoPoint(latitude!, longitude!);

    await FirebaseFirestore.instance
        .collection('suggest_place')
        .doc(widget.place.place_id)
        .update({
      'address': address,
      'category': "fitness",
      'day': day,
      'detail': detail,
      'location': location,
      'name': name,
      'photo': ImageUrl,
      'user_id': widget.my_account.user_id
    });

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.updateData('/place/', {
          'place_id': widget.place.place_id,
          'address': address,
          'category': "fitness",
          'day': day,
          'detail': detail,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'name': name,
          'photo': ImageUrl.toString(),
          'rating': widget.place.rating,
          'user_id': widget.my_account.user_id
        });
      }
    }

    EasyLoading.dismiss();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => widget.my_account.type == "user"
              ? MainUser(
                  my_account: widget.my_account,
                  from: 'home',
                )
              : MainAdmin(
                  my_account: widget.my_account,
                  from: 'home',
                )),
      (Route<dynamic> route) => false,
    );
  }
}
