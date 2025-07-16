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

  // ✅ 1) نحتـافظو بالمجمّعات خارج build
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /* ────────── الموقع ────────── */

  Future<void> _initLocation() async {
    if (await _ensurePermission()) _getCurrentLocation();
  }

  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فعّل إذن الموقع من الإعدادات')),
        );
      }
      return false;
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);

      // ✅ 2) أول ما نحصلو على الموقع كنسجلو الماركـرز والبوليلين
      _createMarkersAndPolyline();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('خطأ فالحصول على الموقع: $e');
    }
  }

  /* ────────── إنشاء الماركـرز والبوليلين ────────── */

  void _createMarkersAndPolyline() {
    if (currentLocation == null) return;

    // Marker ديال الموقع الحالي
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLocation!,
        infoWindow: const InfoWindow(title: 'مكاني الحالي'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Marker ديال المدينة المختارة
    _markers.add(
      Marker(
        markerId: const MarkerId('city'),
        position: LatLng(widget.city.lat, widget.city.lng),
        infoWindow: InfoWindow(title: widget.city.name),
      ),
    );

    // Polyline بين النقطتين
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [currentLocation!, LatLng(widget.city.lat, widget.city.lng)],
        color: Colors.red,
        width: 5,
      ),
    );
  }

  /* ────────── واجهة المستخدم ────────── */

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('خريطة ${widget.city.name}')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 10,
        ),
        onMapCreated: (controller) => _controller.complete(controller),
        // ✅ 3) هنا كنمرّرو المجمّعات المحسوبة
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
