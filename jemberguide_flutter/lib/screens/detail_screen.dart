import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/jember_provider.dart';
import '../widgets/wisata_image_carousel.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spotId = ModalRoute.of(context)!.settings.arguments as int;
    final provider = Provider.of<JemberProvider>(context);

    // Find the wisata spot. If not found, show error.
    final spotIndex = provider.allWisata.indexWhere((w) => w.id == spotId);
    if (spotIndex == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Wisata'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Destinasi tidak ditemukan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final spot = provider.allWisata[spotIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          spot.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit Button
          IconButton(
            key: const Key('edit_spot_topbar_button'),
            icon: const Icon(Icons.edit),
            color: const Color(0xFF8F4C38), // PrimaryGreen
            onPressed: () {
              Navigator.pushNamed(context, '/add_edit_wisata', arguments: spot.id);
            },
          ),
          // Delete Button
          IconButton(
            key: const Key('delete_spot_topbar_button'),
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Destinasi'),
                  content: Text(
                    'Apakah Anda yakin ingin menghapus destinasi ${spot.name}? Tindakan ini tidak dapat dibatalkan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // close dialog
                        await provider.deleteWisata(spot.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.crudMessage ?? 'Destinasi wisata berhasil dihapus!',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          provider.clearCrudStates();
                          Navigator.pop(context); // go back to HomeScreen
                        }
                      },
                      child: Text(
                        'Hapus',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with category and rating overlay
            Stack(
              children: [
                WisataImageCarousel(
                  imageUrls: spot.imageUrls,
                  height: 280,
                ),
                // Category Pill Overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Color(0xFFE57E22), // SecondaryAmber
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          spot.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rating Pill Overlay
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF1C40F), // GoldRating
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          spot.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201A19),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF8F4C38), // PrimaryGreen
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          spot.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF201A19).withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Divider(color: Colors.black.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),

                  // Badges (Ticket Price and Jam Operasional)
                  Row(
                    children: [
                      Expanded(
                        child: _DetailItemBadge(
                          icon: Icons.confirmation_number,
                          title: 'Tiket Masuk',
                          value: spot.ticketPrice,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DetailItemBadge(
                          icon: Icons.schedule,
                          title: 'Jam Operasional',
                          value: spot.openingHours,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Deskripsi Wisata',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201A19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spot.description,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF201A19).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Embedded Leaflet Map
                  const Text(
                    'Peta Lokasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201A19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(spot.latitude, spot.longitude),
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.jemberguide_flutter',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(spot.latitude, spot.longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Route button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      key: const Key('route_button'),
                      onPressed: () async {
                        try {
                          final lat = spot.latitude;
                          final lng = spot.longitude;
                          
                          final googleNavUri = Uri.parse('google.navigation:q=$lat,$lng');
                          final googleMapsAppUri = Uri.parse('comgooglemaps://?daddr=$lat,$lng');
                          final appleMapsUri = Uri.parse('maps://?q=$lat,$lng');
                          final webUri = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                          );

                          if (await canLaunchUrl(googleNavUri)) {
                            await launchUrl(googleNavUri);
                          } else if (await canLaunchUrl(googleMapsAppUri)) {
                            await launchUrl(googleMapsAppUri);
                          } else if (await canLaunchUrl(appleMapsUri)) {
                            await launchUrl(appleMapsUri);
                          } else {
                            await launchUrl(webUri, mode: LaunchMode.externalApplication);
                          }
                        } catch (e) {
                          final webUri = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${spot.latitude},${spot.longitude}',
                          );
                          await launchUrl(webUri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text(
                        'Buka Rute Navigasi Eksternal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE57E22), // SecondaryAmber
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItemBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItemBadge({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF8F4C38),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
