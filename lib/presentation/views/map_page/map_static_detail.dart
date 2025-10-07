import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sistem_pengaduan/config/api_config.dart';

class StaticMap extends StatefulWidget {
  final LatLng location;
  final VoidCallback? onMapReady;

  const StaticMap({Key? key, required this.location, this.onMapReady})
      : super(key: key);

  @override
  _StaticMapState createState() => _StaticMapState();
}

class _StaticMapState extends State<StaticMap> {
  late MapController _mapController;
  LatLng? _currentLocation;
  List<LatLng> _polylinePoints = [];
  bool _mapReady = false;
  StreamSubscription<dynamic>? _mapEventSub;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermission();
    // Listen for first map event to consider the map ready
    // some flutter_map versions expose mapEventStream on the controller
    try {
      _mapEventSub = _mapController.mapEventStream.listen((event) {
        if (!_mapReady) {
          _mapReady = true;
          if (widget.onMapReady != null) widget.onMapReady!();
          // we can cancel the subscription after first event
          _mapEventSub?.cancel();
        }
      });
    } catch (e) {
      // if mapEventStream isn't available on this flutter_map version,
      // fallback: call onMapReady after a short delay
      Future.delayed(const Duration(milliseconds: 400)).then((_) {
        if (!_mapReady) {
          _mapReady = true;
          // Ensure the state is still mounted before invoking callbacks
          if (mounted) {
            if (widget.onMapReady != null) widget.onMapReady!();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _mapEventSub?.cancel();
    super.dispose();
  }

  // ----------------- PERMISSION CHECK -----------------

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Permission not granted');
        return;
      }
    }
    _getCurrentLocation();
  }

  // ----------------- GET LOKASI SAAT INI -----------------

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Service not enabled');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    // Guard against calling setState after dispose
    if (!mounted) return;
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // ----------------- GARIS POLYLINE -----------------

  void _drawRoute() {
    if (_currentLocation != null) {
      print('Current Location: $_currentLocation');
      print('Destination Location: ${widget.location}');

      // Guard against calling setState after dispose
      if (!mounted) return;
      setState(() {
        _polylinePoints = [_currentLocation!, widget.location];
      });
      _moveCameraToFitRoute();
    } else {
      print('Current location is null');
    }
  }

  // ---------- VIEW ANTAR MARKER MAPS & LOKASI KITA ----------

  void _moveCameraToFitRoute() {
    if (_currentLocation != null) {
      // Calculate bounds
      double minLat = _currentLocation!.latitude < widget.location.latitude
          ? _currentLocation!.latitude
          : widget.location.latitude;
      double maxLat = _currentLocation!.latitude > widget.location.latitude
          ? _currentLocation!.latitude
          : widget.location.latitude;
      double minLng = _currentLocation!.longitude < widget.location.longitude
          ? _currentLocation!.longitude
          : widget.location.longitude;
      double maxLng = _currentLocation!.longitude > widget.location.longitude
          ? _currentLocation!.longitude
          : widget.location.longitude;

      LatLngBounds bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.all(40),
        ),
      );
    }
  }

  void _moveCamera(LatLng location) {
    _mapController.move(location, 17.0);
  }

  void _centerMapToMarker() {
    _moveCamera(widget.location);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.location,
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConfig.getMapTilerUrl(),
                userAgentPackageName: 'com.example.sistem_pengaduan',
              ),
              if (_polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.location,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.my_location,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 5.0,
          left: 7.0,
          child: Opacity(
            opacity: 0.7,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: null,
                  onPressed: _drawRoute,
                  child: Icon(Icons.directions),
                  backgroundColor: Colors.white,
                  mini: true,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: _centerMapToMarker,
                  child: Icon(Icons.location_pin),
                  backgroundColor: Colors.white,
                  mini: true,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
