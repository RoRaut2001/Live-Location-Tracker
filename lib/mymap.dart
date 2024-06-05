import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String user_id;
  MyMap(this.user_id);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _mapInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('location').doc(widget.user_id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          double latitude = data['latitude'];
          double longitude = data['longitude'];

          if (_mapInitialized) {
            _updateMap(latitude, longitude);
          }

          return GoogleMap(
            mapType: MapType.normal,
            markers: {
              Marker(
                position: LatLng(latitude, longitude),
                markerId: MarkerId('currentLocation'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: 'Current Location'),
              ),
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 14.47,
            ),
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              setState(() {
                _mapInitialized = true;
              });
              _updateMap(latitude, longitude);
            },
          );
        },
      ),
    );
  }

  Future<void> _updateMap(double latitude, double longitude) async {
    await _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.47,
      ),
    ));
  }
}
