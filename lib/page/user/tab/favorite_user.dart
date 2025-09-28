// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/model/favorite.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/widget/favorite_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteUser extends StatelessWidget {
  UserModel my_account;
  FavoriteUser({Key? key, required this.my_account}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  late String email = '', tel = '', password = '';
  String user_id = '', keyword = '';
  SharedPreferences? prefs;

  @override // แสดง UI
  Widget build(BuildContext context) {
    print(my_account.user_id);
    return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              child: Text(
                'รายการถูกใจ',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              alignment: Alignment.center,
            ),
            const SizedBox(
              height: 30,
            ),
            StreamBuilder<List<Favorite>>(
              stream: FirebaseFirestore.instance
                  .collection('suggest_favorite')
                  .where('user_id', isEqualTo: my_account.user_id)
                  .orderBy(FavoriteField.dateTime, descending: true)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Favorite.fromJson(doc.data()))
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
                      final favorites = snapshot.data;

                      return favorites!.isEmpty
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
                          : GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 180,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 5),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final favorite = favorites[index];

                                return FavoriteWidget(
                                    favorite: favorite, my_account: my_account);
                              },
                            );
                    }
                }
              },
            ),
          ],
        ));
  }
}
