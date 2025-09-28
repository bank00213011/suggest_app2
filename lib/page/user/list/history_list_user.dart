// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lopburi/model/history.dart';
// import 'package:lopburi/model/category.dart';
// import 'package:flutter/material.dart';
// import 'package:lopburi/page/full_image.dart';
// import 'package:lopburi/utils.dart';
// import 'package:lopburi/widget/history_book_widget.dart';

// class HistoryListUser extends StatefulWidget {
//   final String user_id;

//   // รับค่ามาจากหน้าก่อน
//   HistoryListUser({Key? key, required this.user_id}) : super(key: key);
//   @override
//   _HistoryListUser createState() => _HistoryListUser();
// }

// class _HistoryListUser extends State<HistoryListUser> {
//   @override // แสดง UI
//   Widget build(BuildContext context) {
//     final today = Utils.getDateThai();
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('ประวัติการยืมคืน'),
//         ),
//         body: ListView(
//           children: [
//             StreamBuilder<List<History>>(
//               stream: FirebaseFirestore.instance
//                   .collection('suggest_history')
//                   .where("user_id", isEqualTo: widget.user_id)
//                   .orderBy(HistoryField.dateTime, descending: true)
//                   .snapshots()
//                   .map((snapshot) => snapshot.docs
//                       .map((doc) => History.fromJson(doc.data()))
//                       .toList()),
//               builder: (context, snapshot) {
//                 switch (snapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return const Center(child: CircularProgressIndicator());
//                   default:
//                     if (snapshot.hasError) {
//                       return const Center(
//                         child: Text(
//                           'ไม่มีข้อมูล',
//                           style: TextStyle(fontSize: 24),
//                         ),
//                       );
//                     } else {
//                       final historys = snapshot.data;

//                       return historys!.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'ไม่มีข้อมูล',
//                                 style: TextStyle(fontSize: 24),
//                               ),
//                             )
//                           : ListView.builder(
    //  physics: const BouncingScrollPhysics(),
    //                           shrinkWrap: true,
//                               itemCount: historys.length,
//                               itemBuilder: (context, index) {
//                                 final history = historys[index];

//                                 return HistorybookWidget(
//                                     history: history, today: today);
//                               },
//                             );
//                     }
//                 }
//               },
//             ),
//           ],
//         ));
//   }
// }
