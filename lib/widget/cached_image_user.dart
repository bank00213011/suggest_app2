import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CachedImageUser extends StatelessWidget {
  final double radius;
  final String photo;

  CachedImageUser({Key? key, required this.radius, required this.photo});

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: photo,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: radius, backgroundImage: NetworkImage(photo)),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => CircleAvatar(
            radius: radius, backgroundImage: AssetImage('assets/user.png')),
      );
}
