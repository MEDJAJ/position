import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:position/model/city.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.city});
  final City city;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? currentLocation; 

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
  bool granted = await _ensurePermission();
  if (granted) {
    _getCurrentLocation();
  }
}
  Future<bool> _ensurePermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  // أول مرة أو بعد رفض مؤقّت
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // المستخدم رفض نهائياً (deniedForever)
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رجاء فعّل إذن الموقع من إعدادات التطبيق'),
      ),
    );
    return false;
  }

  return permission == LocationPermission.always ||
         permission == LocationPermission.whileInUse;
}


  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('خطأ فالحصول على الموقع: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Marker currentMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: currentLocation!,
      infoWindow: const InfoWindow(title: 'مكاني الحالي'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    final Marker cityMarker = Marker(
      markerId: const MarkerId('city'),
      position: LatLng(widget.city.lat, widget.city.lng),
      infoWindow: InfoWindow(title: widget.city.name),
    );

    final markers = {currentMarker, cityMarker};

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [currentLocation!, LatLng(widget.city.lat, widget.city.lng)],
      color: Colors.red,
      width: 5,
    );

    return Scaffold(
      appBar: AppBar(title: Text('خريطة ${widget.city.name}')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 10,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
        polylines: {polyline},
      ),
    );
  }
}
