import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/direction/directions_model.dart';
import 'package:suggest/direction/directions_repository.dart';

class MapDirection extends StatefulWidget {
  final Place place;
  final UserModel my_account;

  const MapDirection({Key? key, required this.place, required this.my_account})
      : super(key: key);
  @override
  _MapDirection createState() => _MapDirection();
}

class _MapDirection extends State<MapDirection> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(19.027985, 99.8934532),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  Marker? _origin, _destination;
  LatLng? latLngOrigin, latLngDestination;
  Directions? _info;
  String? place_name;

  @override
  void initState() {
    super.initState();

    setState(() {
      place_name = widget.place.name;
    });

    latLngDestination =
        LatLng(widget.place.location.latitude, widget.place.location.longitude);
    getLocation(place_name, latLngDestination);
    //recordUser();
  }

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  void getLocation(place_name, latLngDestination) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      latLngOrigin = LatLng(position.latitude, position.longitude);
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'ตำแหน่งคุณ'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(position.latitude, position.longitude),
      );
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: InfoWindow(title: place_name),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        position:
            LatLng(latLngDestination.latitude, latLngDestination.longitude),
      );

      directionMethod(latLngOrigin, latLngDestination);
    });
  }

  void directionMethod(LatLng? latLngOrigin, LatLng? latLngDestination) async {
    final directions = await DirectionsRepository().getDirections(
        origin: LatLng(latLngOrigin!.latitude, latLngOrigin.longitude),
        destination:
            LatLng(latLngDestination!.latitude, latLngDestination.longitude));
    setState(() => _info = directions);

    _googleMapController!.animateCamera(
      _info != null
          ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
          : CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
  }

  // void recordUser() async {
  //   final docRecord = FirebaseFirestore.instance.collection('suggest_record').doc();
  //   await docRecord.set({
  //     'dateTime': DateTime.now(),
  //     'place_id': widget.pet.pet_id,
  //     'record_id': docRecord.id,
  //     'user_id': widget.my_account.user_id,
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('ตำแหน่งสถานที่'),
          actions: [
            if (_origin != null)
              TextButton(
                onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _origin!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('ORIGIN'),
              ),
            if (_destination != null)
              TextButton(
                onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _destination!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('DEST'),
              )
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              //onTap: _addMarker,
              // onTap: (LatLng latLng) {
              //   print('test' +
              //       latLng.latitude.toString() +
              //       ' ' +
              //       latLng.longitude.toString());
              // },
            ),
            if (_info != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_info!.totalDistance.replaceAll('km', 'กิโลเมตร')} , ${_info!.totalDuration.replaceAll('hours', 'ชั่วโมง').replaceAll('mins', 'นาที')}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 80),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () => _googleMapController!.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_initialCameraPosition),
            ),
            child: const Icon(Icons.center_focus_strong),
          ),
        ));
  }

  //  _addMarker(LatLng pos) async {
  //   if (_origin == null || (_origin != null && _destination != null)) {
  //     // Set origin
  //     setState(() {
  //       _origin = Marker(
  //         markerId: const MarkerId('origin'),
  //         infoWindow: const InfoWindow(title: 'Origin'),
  //         icon: BitmapDescriptor.defaultMarker,
  //         position: pos,
  //       );
  //       // Reset destination
  //       _destination = null;

  //       // Reset info
  //       _info = null;
  //     });
  //   } else {
  //     // Origin is already set
  //     // Set destination
  //     setState(() {
  //       _destination = Marker(
  //         markerId: const MarkerId('destination'),
  //         infoWindow: const InfoWindow(title: 'Destination'),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(
  //             BitmapDescriptor.hueMagenta),
  //         position: pos,
  //       );
  //     });

  //     // Get directions
  //     final directions = await DirectionsRepository()
  //         .getDirections(origin: _origin!.position, destination: pos);
  //     setState(() => _info = directions);
  //   }
  // }
}
