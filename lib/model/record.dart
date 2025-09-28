// import 'package:cloud_firestore/cloud_firestore.dart';

// class RecordField {
//   static final String createdAt = 'createdAt';
// }

// class Record {
//   final Timestamp dateTime;
//   final String place_id;
//   final String record_id;
//   final String user_id;

//   const Record({
//     required this.dateTime,
//     required this.place_id,
//     required this.record_id,
//     required this.user_id,
//   });

//   static Record fromJson(Map<String, dynamic> json) => Record(
//         place_id: json['place_id'],
//         record_id: json['record_id'],
//         user_id: json['user_id'],
//         dateTime: json['dateTime'],
//       );

//   Map<String, dynamic> toJson() => {
//         'place_id': place_id,
//         'record_id': record_id,
//         'user_id': user_id,
//         'dateTime': dateTime,
//       };
// }
