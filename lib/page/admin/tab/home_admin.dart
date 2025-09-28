import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/model/user_model.dart';

import 'package:suggest/page/admin/list/place_list.dart';
import 'package:suggest/page/admin/user/user_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  final UserModel my_account;

  HomeAdmin({Key? key, required this.my_account}) : super(key: key);
  @override
  _HomeAdmin createState() => _HomeAdmin();
}

class _HomeAdmin extends State<HomeAdmin> {
  // ประกาศตัวแปรก่อนเข้าหน้า UI
  final _formKey = GlobalKey<FormState>();
  late String email = '',
      tel = '',
      password = '',
      username = '',
      user_id = '',
      SumRequest = '';
  late SharedPreferences prefs;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id')!;
      print(prefs.getString('photo'));
    });
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            SizedBox(
              height: 70,
            ),
            Align(
              child: Text(
                'แอดมิน',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserList(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/man.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      const Text(
                        'ข้อมูลสมาชิก              ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaceList(my_account: widget.my_account),
                              ),
                            ),
                            child: Image.asset(
                              'assets/fitness.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      const Text(
                        textAlign: TextAlign.center,
                        'สถานที่ออกกำลังกายทั้งหมด',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }

  logoutMethod(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: Text("คุณต้องการออกจากระบบ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              // ปิด popup
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                // เคลียร์ SharedPreferences และไปหน้า LoginPage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //       builder: (BuildContext context) => FirstPage(),
                //     ),
                //     (route) => false);
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
