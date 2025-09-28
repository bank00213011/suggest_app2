import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suggest/api/firestorage_api.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:flutter/material.dart';
import 'package:suggest/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/user/user_edit.dart';
import 'package:suggest/page/full_image.dart';

class UserDetail extends StatefulWidget {
  final UserModel user;

  // รับค่ามาจากหน้าก่อน
  UserDetail({Key? key, required this.user}) : super(key: key);
  @override
  _UserDetail createState() => _UserDetail();
}

class _UserDetail extends State<UserDetail> with WidgetsBindingObserver {
  //  ประกาศตัวแปร

  String? user_id,
      email,
      name,
      password,
      tel,
      type,
      social,
      photo_before,
      dateTime;

  String imagePath = '';
  final picker = ImagePicker();

  @override // รัน initState ก่อน
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    setState(() {
      user_id = widget.user.user_id;
      email = widget.user.email;
      name = widget.user.name;
      password = widget.user.password;
      tel = widget.user.tel;
      type = widget.user.type;
      photo_before = widget.user.photo;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        // ...your code goes here...
        print('resume');
      });
    }
  }

  void load_user(String user_id) async {
    await FirebaseFirestore.instance
        .collection('suggest_user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        setState(() {
          var user_id = result.data()['user_id'];
          email = result.data()['email'];
          name = result.data()['name'];
          password = result.data()['password'];
          tel = result.data()['tel'];
          type = result.data()['type'];
          social = result.data()['social'];
          photo_before = result.data()['photo'];
        });
      });
    });
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลผู้ใช้'),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox(
            height: 20.0,
          ),
          buildPhoto(),
          const SizedBox(
            height: 30.0,
          ),
          buildEmail(),
          const SizedBox(
            height: 10.0,
          ),
          buildUsername(),
          const SizedBox(
            height: 10.0,
          ),
          buildPassword(),
          const SizedBox(
            height: 10,
          ),
          buildTel(),
          const SizedBox(
            height: 10.0,
          ),
          buildType(),
          // const SizedBox(
          //   height: 10.0,
          // ),
          // buildButtonEdit(),
        ],
      ),
    );
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 25.0,
                ),
                onPressed: () async => await FireStorageApi.removePhoto(
                    'https://firebasestorage.googleapis.com/v0/b/farmaccounting-74f30.appspot.com/o/Slip%2F2021-10-06%2021%3A40%3A35.182752.jpg?alt=media&token=bc811314-61b3-4ce8-93ea-c204e64d7594'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => photo_before != ''
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImage(photo: photo_before!),
                    ),
                  )
                : print('object'),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xff476cfb),
              child: ClipOval(
                child: SizedBox(
                    width: 105,
                    height: 105,
                    child: photo_before != ''
                        ? Image.network(
                            '${photo_before}', // this image doesn't exist
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/user.png',
                            fit: BoxFit.cover,
                          )),
              ),
            ),
          ),
          Opacity(
            opacity: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: const Icon(
                  Icons.photo_camera,
                  size: 25.0,
                ),
                onPressed: () async {},
              ),
            ),
          )
        ],
      );

  Widget buildEmail() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              child: Text('อีเมล :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$email',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildUsername() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              child: Text('ชื่อผู้ใช้ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$name',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildPassword() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 65,
              child: Text('รหัสผ่าน :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(Utils.returnPassword(password!.length),
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildTel() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 67,
              child: Text('เบอร์โทร :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text('$tel',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 65,
              child: Text('ประเภท :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(type == 'user' ? 'ผู้ใช้' : 'แอดมิน',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildButtonEdit() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton.icon(
        onPressed: () => goToEditUser(),
        label: const Text('แก้ไขข้อมูล'),
        icon: const Icon(Icons.edit),
      ));

  // ไปหน้า EditUserPage
  void goToEditUser() {
    final user = UserModel(
        user_id: user_id.toString().trim(),
        email: email.toString().trim(),
        name: name.toString().trim(),
        password: password.toString().trim(),
        tel: tel.toString().trim(),
        token: '',
        type: type.toString().trim(),
        social: social.toString(),
        photo: '');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UserEdit(user: user),
      ),
    );
  }
}
