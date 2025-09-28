import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';

import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';

import 'package:suggest/utils.dart';
import 'package:suggest/widget/place_widget.dart';

class PlaceListUser extends StatefulWidget {
  final UserModel my_account;

  PlaceListUser({Key? key, required this.my_account}) : super(key: key);
  @override
  _PlaceListUser createState() => _PlaceListUser();
}

class _PlaceListUser extends State<PlaceListUser> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String? keyword = '';

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  'สถานที่ออกกำลังกาย',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                )),
          ),
          Card(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'กรุณาใส่คำค้นหา...',
                border: InputBorder.none,
              ),
              onChanged: (val) {
                setState(() {
                  keyword = val;
                  print(keyword);
                });
              },
            ),
          ),
          StreamBuilder<List<Place>>(
            stream: keyword == ''
                ? FirebaseFirestore.instance
                    .collection('suggest_place')
                    .where('category', isEqualTo: "fitness")
                    .orderBy('name')
                    .startAt([keyword])
                    .endAt(['${keyword!}\uf8ff'])
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => Place.fromJson(doc.data()))
                        .toList())
                : FirebaseFirestore.instance
                    .collection('suggest_place')
                    .orderBy('name')
                    .startAt([keyword])
                    .endAt(['${keyword!}\uf8ff'])
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => Place.fromJson(doc.data()))
                        .toList()),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return SizedBox(
                      height:
                          MediaQuery.of(context).size.height - kToolbarHeight,
                      child: Center(
                        child: Text(
                          'เกิดข้อผิดพลาด',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  } else {
                    final places = snapshot.data;

                    return places!.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height -
                                kToolbarHeight,
                            child: Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: places.length,
                            itemBuilder: (context, index) {
                              final place = places[index];

                              return PlaceWidget(
                                  place: place, my_account: widget.my_account);
                            },
                          );
                  }
              }
            },
          )
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //   ),
      //   backgroundColor: Colors.green,
      //   onPressed: () => Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => PlaceAdd(),
      //     ),
      //   ),
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Widget buildPlaceList(Place place) => Container(
      color: Colors.white,
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              place.name,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.navigate_next,
              ),
              // กดแล้วไปหน้า ExpenseDetail
              onPressed: () => print('object'))
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => PlaceDetail(place: place))))
        ],
      ));
}

Widget buildText(String text) => Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );

void doNothing(BuildContext context) {
  print('object');
}

Future AddEditPlace(BuildContext context, Place place) async {
  return await showDialog(
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
              onPressed: () {
                Navigator.of(context).pop(false);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => PlaceEdit(
                //             place: place,
                //           )),
                // );
              },
              child: const Text(
                'แก้ไขจุดแจ้งเตือน',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop(false);

                FirebaseFirestore.instance
                    .collection('suggest_place')
                    .doc(place.place_id)
                    .delete();

                if (Platform.isAndroid) {
                  final deviceInfo = DeviceInfoPlugin();
                  final androidInfo = await deviceInfo.androidInfo;

                  final isEmulator = androidInfo.isPhysicalDevice == false;
                  if (isEmulator) {
                    await MySQLApi.deleteData(
                        '/place/', {'place_id': place.place_id});
                  }
                }
                Utils.showToast(context, 'ลบจุดแจ้งเตือนสำเร็จ', Colors.green);
              },
              child: const Text(
                'ลบจุดแจ้งเตือน',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      });
}
