// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:suggest/api/firestorage_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/board.dart';
import 'package:suggest/model/favorite.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/board/board_detail.dart';
import 'package:suggest/widget/favorite_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardAdmin extends StatefulWidget {
  UserModel my_account;
  BoardAdmin({Key? key, required this.my_account}) : super(key: key);

  @override
  _BoardAdmin createState() => _BoardAdmin();
}

class _BoardAdmin extends State<BoardAdmin> {
  final _formKey = GlobalKey<FormState>();
  late String email = '', tel = '', password = '';
  String user_id = '', keyword = '';
  SharedPreferences? prefs;

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
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
                ],
              ),
            ),
            StreamBuilder<List<Board>>(
              stream: keyword == ''
                  ? FirebaseFirestore.instance
                      .collection('suggest_board')
                      .orderBy(FavoriteField.dateTime, descending: true)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => Board.fromJson(doc.data()))
                          .toList())
                  : FirebaseFirestore.instance
                      .collection('suggest_board')
                      .orderBy('title')
                      .startAt([keyword])
                      .endAt(['$keyword\uf8ff'])
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => Board.fromJson(doc.data()))
                          .toList()),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.only(top: 250),
                        child: Text(
                          'เกิดข้อผิดพลาด',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                    } else {
                      final boards = snapshot.data;

                      return boards!.isEmpty
                          ? Container(
                              margin: EdgeInsets.only(top: 250),
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: boards.length,
                              itemBuilder: (context, index) {
                                final board = boards[index];

                                return boardWidget(
                                    context, board, widget.my_account);
                              },
                            );
                    }
                }
              },
            ),
          ],
        ));
  }

  Widget boardWidget(BuildContext context, Board board, UserModel my_account) =>
      SizedBox(
          width: 260,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BoardDetail(
                                board: board, my_account: my_account)),
                      ),
                  onLongPress: () => deleteMethod(context, board),
                  child: Card(
                    child: Column(
                      children: [
                        CachedNetworkImage(
                            imageUrl: board.photo[0],
                            imageBuilder: (context, imageProvider) =>
                                Image.network(
                                  board.photo[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                                  'assets/no_image.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      board.title,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('suggest_user')
                                    .doc(board.user_id)
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError &&
                                      (snapshot.hasData &&
                                          !snapshot.data!.exists)) {
                                    return const Text("");
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic> data = snapshot.data!
                                        .data() as Map<String, dynamic>;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('by ${data['name']}'),
                                      ],
                                    );
                                  }
                                  return const Text("");
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))));
}

deleteMethod(BuildContext context, Board board) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('⭐ แจ้งเตือน'),
        content: const Text("คุณต้องการลบบอร์ดนี้ ใช่หรือไม่?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ไม่ใช่'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await FirebaseFirestore.instance
                  .collection('suggest_board')
                  .doc(board.board_id)
                  .delete()
                  .whenComplete(() async {
                for (final photoUrl in board.photo) {
                  await FireStorageApi.removePhoto(photoUrl);
                }
              });

              if (Platform.isAndroid) {
                final deviceInfo = DeviceInfoPlugin();
                final androidInfo = await deviceInfo.androidInfo;

                final isEmulator = androidInfo.isPhysicalDevice == false;
                if (isEmulator) {
                  await MySQLApi.deleteData('/board/', {
                    'board_id': board.board_id,
                  });
                }
              }
            },
            child: const Text('ใช่'),
          ),
        ],
      );
    },
  );
}
