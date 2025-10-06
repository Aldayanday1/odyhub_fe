import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/config/api_config.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final LatLng? currentLocation;
  final String? currentAddress;

  const MapScreen({
    Key? key,
    required this.onLocationSelected,
    this.currentLocation,
    this.currentAddress,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  MapController? _mapController;
  LatLng? _lastMapPosition;
  String? _lastAddress;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  // each item: { 'location': Location, 'label': String }
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // Pulse animation for marker
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.currentLocation != null) {
      _lastMapPosition = widget.currentLocation;
      _lastAddress = widget.currentAddress;
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });

    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _lastMapPosition = LatLng(position.latitude, position.longitude);
    });

    if (_lastMapPosition != null && _mapController != null) {
      // Hanya animate ketika controller sudah tersedia
      _mapController!.move(_lastMapPosition!, 16.0);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      // Search multiple variations untuk hasil yang lebih relevan
      final searchQueries = [
        query, // Exact query
        '$query, Indonesia', // With country
        '$query, Yogyakarta', // Common local area
        '$query, Jakarta', // Major city
        '$query, Jawa', // Province level
      ];

      final Map<String, Map<String, dynamic>> uniqueResults = {};

      for (final searchQuery in searchQueries) {
        try {
          List<Location> locations = await locationFromAddress(searchQuery);

          // Process locations and build labels
          for (final loc in locations.take(3)) {
            // Max 3 per query variation
            try {
              final placemarks =
                  await placemarkFromCoordinates(loc.latitude, loc.longitude);

              if (placemarks.isNotEmpty) {
                final p = placemarks.first;

                // Build comprehensive address label
                final parts = [
                  p.street,
                  p.subLocality,
                  p.locality,
                  p.subAdministrativeArea,
                  p.administrativeArea,
                  p.country
                ]
                    .where((s) =>
                        s != null &&
                        s.toString().trim().isNotEmpty &&
                        !_isPlusCodeOrAnomaly(s.toString()))
                    .toList();

                // Remove duplicates while preserving order
                final uniqueParts = <String>[];
                for (final part in parts) {
                  if (!uniqueParts.contains(part)) {
                    uniqueParts.add(part!);
                  }
                }

                final label = uniqueParts.join(', ');

                // Check if label is relevant to query
                if (label.isNotEmpty &&
                    !_isPlusCodeOrAnomaly(label) &&
                    _isRelevantToQuery(label, query)) {
                  // Use label as key to avoid duplicates
                  final key =
                      '${loc.latitude.toStringAsFixed(4)},${loc.longitude.toStringAsFixed(4)}';
                  if (!uniqueResults.containsKey(key)) {
                    uniqueResults[key] = {
                      'location': loc,
                      'label': label,
                      'relevance': _calculateRelevance(label, query),
                    };
                  }
                }
              }
            } catch (e) {
              // Skip this location if reverse geocoding fails
              continue;
            }
          }
        } catch (e) {
          // Skip this search query if it fails
          continue;
        }

        // Break early if we have enough results
        if (uniqueResults.length >= 8) break;
      }

      // Sort by relevance and take top results
      final sortedResults = uniqueResults.values.toList()
        ..sort(
            (a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int));

      setState(() {
        _searchResults = sortedResults.take(8).toList();
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    }
  }

  // Check if result label is relevant to search query
  bool _isRelevantToQuery(String label, String query) {
    final lowerLabel = label.toLowerCase();
    final lowerQuery = query.toLowerCase();

    // Check if any word in query appears in label
    final queryWords = lowerQuery.split(RegExp(r'\s+'));
    return queryWords
        .any((word) => word.length > 2 && lowerLabel.contains(word));
  }

  // Calculate relevance score for sorting
  int _calculateRelevance(String label, String query) {
    final lowerLabel = label.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int score = 0;

    // Exact match at start gets highest score
    if (lowerLabel.startsWith(lowerQuery)) {
      score += 100;
    }

    // Contains exact query
    if (lowerLabel.contains(lowerQuery)) {
      score += 50;
    }

    // Word matches
    final queryWords = lowerQuery.split(RegExp(r'\s+'));
    final labelWords = lowerLabel.split(RegExp(r'[,\s]+'));

    for (final qWord in queryWords) {
      if (qWord.length > 2) {
        for (final lWord in labelWords) {
          if (lWord.startsWith(qWord)) {
            score += 20;
          } else if (lWord.contains(qWord)) {
            score += 10;
          }
        }
      }
    }

    // Shorter addresses are often more specific/relevant
    score -= label.length ~/ 10;

    return score;
  }

  // Helper to detect Plus Codes and anomalies
  bool _isPlusCodeOrAnomaly(String text) {
    // Plus Codes pattern: contains + with alphanumeric (e.g., "886V+5X6")
    // Also filter out patterns with mixed numbers and uppercase letters
    final plusCodePattern =
        RegExp(r'[A-Z0-9]{4}\+[A-Z0-9]{2,3}', caseSensitive: true);
    final anomalyPattern =
        RegExp(r'[0-9]+[A-Z]+\+|[A-Z]+[0-9]+\+', caseSensitive: true);

    return plusCodePattern.hasMatch(text) || anomalyPattern.hasMatch(text);
  }

  void _selectSearchResult(Map<String, dynamic> item) async {
    final Location location = item['location'] as Location;
    LatLng position = LatLng(location.latitude, location.longitude);
    setState(() {
      _lastMapPosition = position;
      _searchResults = [];
      _searchController.clear();
      _lastAddress = item['label'] as String?;
    });

    _mapController?.move(position, 16.0);
    _updateSelectedLocation(position);
  }

  @override
  Widget build(BuildContext context) {
    _mapController ??= MapController();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _lastMapPosition ??
                  const LatLng(-7.7956, 110.3695), // Yogyakarta, Indonesia
              initialZoom: 16.0,
              onTap: (tapPosition, position) {
                setState(() {
                  _lastMapPosition = position;
                });
                _updateSelectedLocation(position);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConfig.getMapTilerUrl(),
                userAgentPackageName: 'com.example.sistem_pengaduan',
              ),
              if (_lastMapPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _lastMapPosition!,
                      width: 80,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Pulse circle background
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  width: 50 * _pulseAnimation.value,
                                  height: 50 * _pulseAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF6366F1).withOpacity(
                                      0.2 * (2 - _pulseAnimation.value),
                                    ),
                                  ),
                                ),
                              ),
                              // Main marker with white circle wrapper
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Small triangle pointer
                                  CustomPaint(
                                    size: const Size(16, 8),
                                    painter: _MarkerPointerPainter(),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top header with back button, search, and GPS - Full screen
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchLocation,
                            decoration: InputDecoration(
                              hintText: 'Cari lokasi...',
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _getCurrentLocation,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                size: 20,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search results dropdown
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final label = item['label'] as String? ?? '';
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectSearchResult(item),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: const Color(0xFF6366F1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Bottom sheet with address and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              // Remove SafeArea to avoid adding top inset; preserve bottom inset manually
              child: Builder(builder: (context) {
                final bottomInset = MediaQuery.of(context).viewPadding.bottom;
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle placed flush at the very top edge of the white sheet
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lokasi Terpilih',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _lastAddress ??
                                      'Tap pada peta untuk memilih lokasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF2D3748),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _lastMapPosition != null && _lastAddress != null
                                  ? () {
                                      widget.onLocationSelected(
                                          _lastMapPosition!, _lastAddress!);
                                      Navigator.pop(
                                        context,
                                        {
                                          'location': _lastMapPosition,
                                          'address': _lastAddress,
                                        },
                                      );
                                    }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            disabledBackgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Konfirmasi Lokasi',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSelectedLocation(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String fullAddress =
          "${place.subLocality}, ${place.locality}, ${place.country}.";
      setState(() {
        _lastAddress = fullAddress;
        _lastMapPosition = position; // Update posisi terakhir peta
      });
    }
  }
}

// Custom painter for marker pointer (small triangle at bottom)
class _MarkerPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(size.width / 2, size.height); // Bottom center point
    path.lineTo(size.width * 0.3, 0); // Top left
    path.lineTo(size.width * 0.7, 0); // Top right
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
