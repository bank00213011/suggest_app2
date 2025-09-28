import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceField {
  static const dateTime = 'dateTime';
}

class Place {
  // ignore: non_constant_identifier_names
  String address;
  String category;
  String day;
  String detail;
  GeoPoint location;
  String name;
  List photo;
  String place_id;
  double rating;
  String user_id;

  Place({
    required this.address,
    required this.category,
    required this.day,
    required this.detail,
    required this.location,
    required this.name,
    required this.photo,
    required this.place_id,
    required this.rating,
    required this.user_id,
  });

  static Place fromJson(Map<String, dynamic> json) => Place(
        address: json['address'],
        category: json['category'],
        day: json['day'],
        detail: json['detail'],
        location: json['location'],
        name: json['name'],
        photo: json['photo'],
        place_id: json['place_id'],
        rating: double.parse(json['rating'].toString()),
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'category': category,
        'day': day,
        'detail': detail,
        'location': location,
        'name': name,
        'photo': photo,
        'place_id': place_id,
        'rating': rating.toString(),
        'user_id': user_id,
      };
}
