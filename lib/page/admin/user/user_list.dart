import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/model/category.dart';
import 'package:flutter/material.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/user/user_add.dart';
import 'package:suggest/widget/user_widget.dart';

class UserList extends StatefulWidget {
  @override
  _UserList createState() => _UserList();
}

class FruitsList {
  String name;
  int index;
  FruitsList({required this.name, required this.index});
}

class _UserList extends State<UserList> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String? keyword = '';

  // Group Value for Radio Button.
  int id = 1;

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมาชิกทั้งหมด')),
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Card(
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                            hintText: 'กรุณาใส่คำค้นหา...'),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                            print(keyword);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )),
          Expanded(
              child: StreamBuilder<List<UserModel>>(
            stream: keyword == ''
                ? FirebaseFirestore.instance
                    .collection('suggest_user')
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => UserModel.fromJson(doc.data()))
                        .toList())
                : FirebaseFirestore.instance
                    .collection('suggest_user')
                    .orderBy('name')
                    .startAt([keyword])
                    .endAt([keyword! + '\uf8ff'])
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => UserModel.fromJson(doc.data()))
                        .toList()),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'ไม่มีข้อมูล',
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                  } else {
                    final users = snapshot.data;

                    return users!.isEmpty
                        ? const Center(
                            child: Text(
                              'ไม่มีข้อมูล',
                              style: TextStyle(fontSize: 24),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];

                              return user.type != 'admin'
                                  ? UserWidget(user: user)
                                  : Container();
                            },
                          );
                  }
              }
            },
          ))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //   ),
      //   backgroundColor: Colors.white,
      //   onPressed: () => Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => UserAdd(),
      //     ),
      //   ),
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.black,
      //   ),
      // ),
    );
  }
}
