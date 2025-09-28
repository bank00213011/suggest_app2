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
import 'package:suggest/page/board/board_edit.dart';
import 'package:suggest/widget/favorite_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardUser extends StatefulWidget {
  UserModel my_account;
  BoardUser({Key? key, required this.my_account}) : super(key: key);
  @override
  _BoardUser createState() => _BoardUser();
}

class _BoardUser extends State<BoardUser> {
  final _formKey = GlobalKey<FormState>();
  late String email = '', tel = '', password = '';
  String user_id = '', keyword = '';
  SharedPreferences? prefs;

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                      .orderBy(BoardField.dateTime, descending: true)
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
                              itemCount: boards.length,
                              itemBuilder: (context, index) {
                                final board = boards[index];

                                return boardWidget(
                                    context: context,
                                    board: board,
                                    my_account: widget.my_account);
                              },
                            );
                    }
                }
              },
            ),
          ],
        ));
  }

  Widget boardWidget(
          {required BuildContext context,
          required Board board,
          required UserModel my_account}) =>
      SizedBox(
          width: 260,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                  onTap: () async => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BoardDetail(
                                board: board, my_account: my_account)),
                      ),
                  onLongPress: () => my_account.user_id != board.user_id
                      ? print('object')
                      : editDeleteMethod(context, board, my_account),
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
                              Text(
                                board.title,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "หมวดหมู่ : ${board.category}",
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(),
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('suggest_user')
                                    .doc(board.user_id)
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasData) {
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

editDeleteMethod(
    BuildContext context, Board board, UserModel my_account) async {
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          BoardEdit(board: board, my_account: my_account),
                    ));
              },
              child: const Text(
                'แก้ไขข่าวสาร',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SimpleDialogOption(
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
                    await MySQLApi.deleteData(
                        '/board/', {'board_id': board.board_id});
                  }
                }
              },
              child: const Text(
                'ลบข่าวสาร',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      });
}
