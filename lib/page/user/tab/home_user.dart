import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/model/user_model.dart';

import 'package:suggest/page/admin/list/place_list.dart';
import 'package:suggest/page/admin/list/rated_list.dart';
import 'package:suggest/page/admin/user/user_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/page/first_page.dart';

class HomeUser extends StatefulWidget {
  final UserModel my_account;

  HomeUser({Key? key, required this.my_account}) : super(key: key);
  @override
  _HomeUser createState() => _HomeUser();
}

class _HomeUser extends State<HomeUser> {
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
    //loadRequestAmount();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id')!;
      print(prefs.getString('photo'));
    });
  }

  Future loadRequestAmount() async {
    final ref = await FirebaseFirestore.instance
        .collection('suggest_request')
        .where('approve', isEqualTo: 'wait')
        .get();

    if (ref.size == 0) {
      setState(() {
        SumRequest = '';
      });
    } else {
      setState(() {
        SumRequest = ref.size.toString();
      });
    }
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Align(
              child: Text(
                'ผู้ใช้ทั่วไป',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 150,
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
                              'assets/travel.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      const Text(
                        'สถานที่ทั้งหมด',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 150,
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
                                builder: (context) => RatedList(
                                    category: 'ร้านอาหาร',
                                    my_account: widget.my_account),
                              ),
                            ),
                            child: Image.asset(
                              'assets/food.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      Text(
                        'ร้านอาหารยอดนิยม',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                builder: (context) => RatedList(
                                    category: 'สถานที่ท่องเที่ยว',
                                    my_account: widget.my_account),
                              ),
                            ),
                            child: Image.asset(
                              'assets/location.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      const Text(
                        'สถานที่ท่องเที่ยวยอดนิยม',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 22),
                    child: SizedBox(
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
                                    builder: (context) => RatedList(
                                        category: 'ที่พัก',
                                        my_account: widget.my_account),
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/hotel.png',
                                  width: 100,
                                  height: 100,
                                ),
                              )),
                          const Text(
                            'ที่พักยอดนิยม',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
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
