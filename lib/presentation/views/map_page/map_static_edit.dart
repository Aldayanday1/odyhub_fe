import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class StaticMapEdit extends StatefulWidget {
  final LatLng location;
  final Function(LatLng, String) onLocationChanged;

  const StaticMapEdit({
    Key? key,
    required this.location,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  _StaticMapEditState createState() => _StaticMapEditState();
}

class _StaticMapEditState extends State<StaticMapEdit> {
  late MapController _mapController;
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = widget.location;
  }

  @override
  void didUpdateWidget(covariant StaticMapEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _moveCamera(widget.location);
      _currentLocation = widget.location;
    }
  }

  void _moveCamera(LatLng location) {
    _mapController.move(location, 17.0);
  }

  void _onMapTap(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String fullAddress =
          "${place.subLocality}, ${place.locality}, ${place.country}";
      widget.onLocationChanged(position, fullAddress);
      // Guard against calling setState after dispose
      if (!mounted) return;
      setState(() {
        _currentLocation = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 17.0,
          onTap: (tapPosition, position) {
            _onMapTap(position);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=V0XXz8MKZxtS8PLWk8Jm',
            userAgentPackageName: 'com.example.sistem_pengaduan',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
