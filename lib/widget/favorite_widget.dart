import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/model/favorite.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_detail.dart';
import 'package:suggest/widget/heart_animation_widget.dart';

class FavoriteWidget extends StatefulWidget {
  final Favorite favorite;
  final UserModel my_account;

  FavoriteWidget({Key? key, required this.favorite, required this.my_account});

  @override
  _FavoriteWidget createState() => _FavoriteWidget();
}

class _FavoriteWidget extends State<FavoriteWidget> {
  bool isLiked = true;

  @override
  Widget build(BuildContext context) {
    final icon = isLiked ? Icons.favorite : Icons.favorite_outline;
    final color = isLiked ? Colors.red : Colors.white;
    return GestureDetector(
        onTap: () async {
          bool like = await CloudFirestoreApi.checkLikePlace(
              widget.favorite.place_id, widget.my_account.user_id);

          Place? place =
              await CloudFirestoreApi.getPlaceFromId(widget.favorite.place_id);

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PlaceDetail(
                    place: place!, like: like, my_account: widget.my_account)),
          );
        },
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('suggest_place')
              .doc(widget.favorite.place_id)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError ||
                (snapshot.hasData && !snapshot.data!.exists)) {
              return const Text("");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      data['photo'][0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                  Positioned(
                    bottom: 45,
                    left: 5,
                    right: 5,
                    child: Text(
                      data['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Positioned(
                      top: 3,
                      right: 3,
                      child: HeartAnimationWidget(
                        alwaysAnimate: true,
                        isAnimating: isLiked,
                        child: IconButton(
                            onPressed: () => setState(() {
                                  CloudFirestoreApi.addFavoritePlace(
                                      data['place_id'],
                                      widget.my_account.user_id,
                                      'delete');
                                }),
                            icon: Icon(
                              icon,
                              color: color,
                              size: 28,
                            )),
                      ))
                ],
              );
            }

            return const Text("");
          },
        ));
  }
}
