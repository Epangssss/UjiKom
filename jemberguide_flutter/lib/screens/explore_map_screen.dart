import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _tourismMarkers = [];
  bool _isLoading = true;

  // Center of Jember
  final LatLng _jemberCenter = const LatLng(-8.1724, 113.6995);

  @override
  void initState() {
    super.initState();
    _fetchOverpassData();
  }

  Future<void> _fetchOverpassData() async {
    setState(() {
      _isLoading = true;
    });

    // Overpass QL to fetch tourism nodes within 15km of Jember Center
    final String query = '''
    [out:json][timeout:25];
    node["tourism"](around:15000,-8.1724,113.6995);
    out;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    
    try {
      final response = await http.post(
        url,
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        final markers = elements.where((e) => e['tags'] != null && e['tags']['name'] != null).map((e) {
          final lat = e['lat'];
          final lon = e['lon'];
          final tags = e['tags'];
          final name = tags['name'] ?? 'Wisata Tanpa Nama';
          final tourismType = tags['tourism'] ?? 'Tempat Wisata';

          return Marker(
            point: LatLng(lat, lon),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPlaceDetails(name, tourismType, lat, lon),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFE57E22),
                size: 36,
              ),
            ),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _tourismMarkers = markers;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data from Overpass API');
      }
    } catch (e) {
      debugPrint('Overpass API Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat titik wisata dari server.')),
        );
      }
    }
  }

  void _showPlaceDetails(String name, String type, double lat, double lon) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF201A19),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8F4C38).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8F4C38),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Close bottom sheet
                    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text(
                    'Rute ke Google Maps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57E22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Wisata Live (OSM)'),
        backgroundColor: const Color(0xFF8F4C38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOverpassData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _jemberCenter,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.jemberguide_flutter',
              ),
              MarkerLayer(
                markers: _tourismMarkers,
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8F4C38)),
                    SizedBox(height: 16),
                    Text(
                      'Menarik data dari Overpass API...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
