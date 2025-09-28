import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_add.dart';
import 'package:suggest/widget/place_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatedList extends StatelessWidget {
  final String category;
  final UserModel my_account;

  RatedList({Key? key, required this.category, required this.my_account})
      : super(key: key);

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
        title: Text('$categoryทั้งหมด'),
      )),
      body: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('รายการจัดอันดับ$category',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: StreamBuilder<List<Place>>(
                  stream: FirebaseFirestore.instance
                      .collection('suggest_place')
                      .where('category', isEqualTo: category)
                      .orderBy('rating', descending: true)
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
                                        place: place, my_account: my_account);
                                  },
                                );
                        }
                    }
                  },
                ),
              )
            ],
          )),

      // floatingActionButton: my_account.type != 'user'
      //     ? FloatingActionButton(
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(20),
      //         ),
      //         backgroundColor: Colors.white,
      //         onPressed: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => PlaceAdd(my_account: my_account)),
      //         ),
      //         child: const Icon(
      //           Icons.add,
      //           color: Colors.black,
      //         ),
      //       )
      //     : null
    );
  }

  goBack(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}
