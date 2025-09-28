import 'package:flutter/material.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/user/user_detail.dart';
import 'package:suggest/page/admin/user/user_edit.dart';
import 'package:suggest/widget/cached_image_user.dart';

class UserWidget extends StatelessWidget {
  final UserModel user;

  const UserWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: CachedImageUser(
                  radius: 60,
                  photo: user.photo,
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Text(user.type == "user" ? "ผู้ใช้" : "admin"),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => UserDetail(user: user)),
                  ),
              onLongPress: () => addEditStaff(context, user)),
          const Divider()
        ],
      );
}

Future addEditStaff(BuildContext context, UserModel user) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('⭐ แจ้งเตือน'),
        content: const Text('คุณต้องการแก้ไขข้อมูลผู้ใช้ ใช่หรือไม่?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ไม่ใช่'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserEdit(
                          user: user,
                        )),
              );
            },
            child: const Text('ใช่'),
          ),
        ],
      );
    },
  );
}
