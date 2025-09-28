// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:lopburi/api/cloudfirestore_api.dart';
// import 'package:lopburi/model/favorite.dart';
// import 'package:lopburi/model/group_month.dart';

// class GroupMonthWidget extends StatelessWidget {
//   final GroupMonth groupMonth;

//   const GroupMonthWidget({
//     Key? key,
//     required this.groupMonth,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//       onTap: () => print('object'),
//       child: Card(
//         // borderRadius: BorderRadius.circular(30),
//         child: Container(
//           color: Colors.white,
//           margin: const EdgeInsets.all(3),
//           padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       groupMonth.month,
//                       style: const TextStyle(
//                         fontSize: 18,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           'ยืม ${groupMonth.borrow.toString()}',
//                           style: const TextStyle(
//                               fontSize: 18, color: Colors.green),
//                         ),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Text(
//                           'คืน ${groupMonth.return_book.toString()}',
//                           style:
//                               const TextStyle(fontSize: 18, color: Colors.red),
//                         ),
//                         const Icon(Icons.navigate_next)
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ));
// }
