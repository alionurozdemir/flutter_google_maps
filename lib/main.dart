import 'package:flutter/material.dart';
import 'package:flutter_google_maps/directions_model.dart';
import 'package:flutter_google_maps/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(37.773972, -122.431297), zoom: 11.5);

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  @override
  void dispose() {
    // TODO: implement dispose
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Google Maps",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: [
            if (_origin != null)
              TextButton(
                onPressed: () {
                  _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: _origin!.position, zoom: 14.5, tilt: 50.0)));
                },
                child: Text(
                  "Origin",
                ),
                style: TextButton.styleFrom(primary: Colors.green),
              ),
            if (_destination != null)
              TextButton(
                onPressed: () {
                  _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: _destination!.position, zoom: 14.5, tilt: 50.0)));
                },
                child: Text(
                  "Dest",
                ),
                style: TextButton.styleFrom(primary: Colors.green),
              ),
          ]),
      body: Stack(
        children: [
          GoogleMap(
            polylines: {
              if (_info != null)
                Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points:
                        _info!.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList())
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: ((controller) => _googleMapController = controller),
            markers: {if (_origin != null) _origin!, if (_destination != null) _destination!},
            onLongPress: _addMarker,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(_info != null
            ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition)),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: pos);
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);
      });
    }

    final directions =
        await DirectionsRepository().getDirections(origin: _origin!.position, destination: pos);
    setState(() {
      _info = directions;
    });
  }
}
