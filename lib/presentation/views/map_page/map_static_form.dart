import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StaticMapForm extends StatefulWidget {
  final LatLng location;

  const StaticMapForm({Key? key, required this.location}) : super(key: key);

  @override
  _StaticMapState createState() => _StaticMapState();
}

class _StaticMapState extends State<StaticMapForm> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant StaticMapForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _moveCamera(widget.location);
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
          borderRadius: BorderRadius.circular(11),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.location,
              initialZoom: 17.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
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
                    point: widget.location,
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
        ),
      ],
    );
  }
}
