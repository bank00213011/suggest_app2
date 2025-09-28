import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_add.dart';
import 'package:suggest/widget/place_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceList extends StatefulWidget {
  final UserModel my_account;

  PlaceList({Key? key, required this.my_account}) : super(key: key);
  @override
  _PlaceList createState() => _PlaceList();
}

class _PlaceList extends State<PlaceList> {
  // ประกาศตัวแปร
  String? keyword = '', type = '';

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
  }

  // void popupMethod() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('⭐ กรองข้อมูล'),
  //           content: Column(mainAxisSize: MainAxisSize.min, children: [
  //             RadioListTile(
  //               groupValue: Category,
  //               title: const Text('ร้านอาหาร'),
  //               value: 'ร้านอาหาร',
  //               onChanged: (String? val) {
  //                 setState(() {
  //                   Category = val!;
  //                   print(Category);
  //                   Navigator.of(context).pop(false);
  //                 });
  //               },
  //             ),
  //             RadioListTile(
  //               groupValue: Category,
  //               title: const Text('สถานที่ท่องเที่ยว'),
  //               value: 'สถานที่ท่องเที่ยว',
  //               onChanged: (String? val) {
  //                 setState(() {
  //                   Category = val;
  //                   print(Category);
  //                   Navigator.of(context).pop(false);
  //                 });
  //               },
  //             ),
  //             RadioListTile(
  //               groupValue: Category,
  //               title: const Text('ไม่กรอง'),
  //               value: '',
  //               onChanged: (String? val) {
  //                 setState(() {
  //                   Category = '';
  //                   print(Category);
  //                   Navigator.of(context).pop(false);
  //                 });
  //               },
  //             ),
  //           ]),
  //         );
  //       });
  // }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (AppBar(
          title: const Text('สถานที่ออกกำลังกาย'),
        )),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Card(
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                            hintText: 'กรุณาใส่คำค้นหา'),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                          });
                        },
                      ),
                    ),
                    // Stack(
                    //   children: [
                    //     IconButton(
                    //         onPressed: popupMethod,
                    //         icon: const Icon(Icons.filter_list)),
                    //     Category != ''
                    //         ? Positioned(
                    //             bottom: 15,
                    //             right: 15,
                    //             child: Container(
                    //               width: 5,
                    //               height: 5,
                    //               color: Colors.green,
                    //             ))
                    //         : Container()
                    //   ],
                    // )
                  ],
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder<List<Place>>(
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
                      return const Center(
                        child: Text(
                          'เกิดข้อผิดพลาด',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                    } else {
                      final places = snapshot.data;

                      return places!.isEmpty
                          ? const Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                final place = places[index];

                                return PlaceWidget(
                                    place: place,
                                    my_account: widget.my_account);
                              },
                            );
                    }
                }
              },
            ))
          ],
        ),
        floatingActionButton: widget.my_account.type != 'ผู้ใช้ทั่วไป'
            ? FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlaceAdd(my_account: widget.my_account)),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              )
            : null);
  }

  goBack(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}
