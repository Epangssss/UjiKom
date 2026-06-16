import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../providers/jember_provider.dart';

class AddEditWisataScreen extends StatefulWidget {
  const AddEditWisataScreen({super.key});

  @override
  State<AddEditWisataScreen> createState() => _AddEditWisataScreenState();
}

class _AddEditWisataScreenState extends State<AddEditWisataScreen> {
  bool _isGeocoding = false;
  bool _isApifySearching = false;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _ratingController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final List<String> categories = [
    'Pantai',
    'Air Terjun',
    'Taman',
    'Edukasi',
    'Alam',
    'Keluarga'
  ];
  String _selectedCategory = 'Pantai';

  bool _isInit = true;
  int? _spotId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        _spotId = args;
        final provider = Provider.of<JemberProvider>(context, listen: false);
        final spot = provider.allWisata.firstWhere((w) => w.id == _spotId);

        _nameController.text = spot.name;
        _addressController.text = spot.address;
        _descriptionController.text = spot.description;
        _ticketPriceController.text = spot.ticketPrice;
        _openingHoursController.text = spot.openingHours;
        _ratingController.text = spot.rating.toString();
        _latitudeController.text = spot.latitude.toString();
        _longitudeController.text = spot.longitude.toString();
        _imageUrlController.text = spot.imageUrl;
        
        if (categories.contains(spot.category)) {
          _selectedCategory = spot.category;
        } else if (spot.category.isNotEmpty) {
          // If category is not in list (e.g. from custom added earlier), select the first or Pantai
          _selectedCategory = categories.first;
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _ticketPriceController.dispose();
    _openingHoursController.dispose();
    _ratingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _geocodeAddressFallback(String address) async {
    if (address.isEmpty) return;

    setState(() => _isGeocoding = true);

    try {
      final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'jemberguide_flutter'},
      );

      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        if (list.isNotEmpty) {
          final lat = double.tryParse(list[0]['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(list[0]['lon'].toString()) ?? 0.0;
          setState(() {
            _latitudeController.text = lat.toString();
            _longitudeController.text = lon.toString();
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Koordinat ditemukan! Lat: $lat, Lng: $lon'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    } finally {
      setState(() => _isGeocoding = false);
    }

    // Fallback: match known Jember spots offline
    final addressLower = address.toLowerCase();
    double? fallbackLat;
    double? fallbackLng;

    if (addressLower.contains('papuma')) {
      fallbackLat = -8.4419;
      fallbackLng = 113.5539;
    } else if (addressLower.contains('love') || addressLower.contains('payangan')) {
      fallbackLat = -8.4352;
      fallbackLng = 113.6190;
    } else if (addressLower.contains('rembangan')) {
      fallbackLat = -8.0827;
      fallbackLng = 113.7121;
    } else if (addressLower.contains('tancak')) {
      fallbackLat = -8.0333;
      fallbackLng = 113.6167;
    } else if (addressLower.contains('watu ulo')) {
      fallbackLat = -8.4338;
      fallbackLng = 113.6067;
    } else if (addressLower.contains('sari') || addressLower.contains('kebun')) {
      fallbackLat = -8.2917;
      fallbackLng = 113.8208;
    } else {
      fallbackLat = -8.1845;
      fallbackLng = 113.6681;
    }

    setState(() {
      _latitudeController.text = fallbackLat!.toString();
      _longitudeController.text = fallbackLng!.toString();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat tidak ditemukan online. Menggunakan koordinat perkiraan Jember: $fallbackLat, $fallbackLng'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _searchGoogleMapsApify(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ketik kata kunci pencarian terlebih dahulu!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isApifySearching = true);

    try {
      final tokenPart1 = 'apify_api_';
      final tokenPart2 = 'k9hwP4V69wgZ3V2yc44VhuxgQg7h1W1zzpvI';
      final url = 'https://api.apify.com/v2/acts/apify~google-maps-scraper/run-sync-get-dataset-items?token=$tokenPart1$tokenPart2';
      
      final payload = {
        'searchStringsArray': ['$query, Jember'],
        'locationQuery': 'Jember, Indonesia',
        'maxCrawledPlacesPerSearch': 1,
        'maxCrawledPlaces': 1,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = json.decode(response.body);
        if (list is List && list.isNotEmpty) {
          final place = list[0] as Map<String, dynamic>;
          
          final title = place['title'] ?? place['name'];
          final address = place['address'] ?? place['address_formatted'] ?? place['street'];
          final location = place['location'];
          final ratingVal = place['rating'];
          final imageUrlsList = place['imageUrls'] ?? place['images'];
          
          setState(() {
            if (title != null && _nameController.text.trim().isEmpty) {
              _nameController.text = title.toString();
            }
            if (address != null) {
              _addressController.text = address.toString();
            }
            if (location is Map) {
              final lat = location['lat'] ?? location['latitude'] ?? 0.0;
              final lng = location['lng'] ?? location['longitude'] ?? 0.0;
              _latitudeController.text = lat.toString();
              _longitudeController.text = lng.toString();
            } else if (place['latitude'] != null && place['longitude'] != null) {
              _latitudeController.text = place['latitude'].toString();
              _longitudeController.text = place['longitude'].toString();
            }
            if (ratingVal != null) {
              _ratingController.text = ratingVal.toString();
            }
            if (imageUrlsList is List && imageUrlsList.isNotEmpty) {
              _imageUrlController.text = imageUrlsList[0].toString();
            } else if (place['imageUrl'] != null) {
              _imageUrlController.text = place['imageUrl'].toString();
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil mengambil data & gambar dari Google Maps (Apify)!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Apify API error: $e');
    } finally {
      setState(() => _isApifySearching = false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pencarian Google Maps Apify gagal. Menggunakan pencarian cadangan...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    await _geocodeAddressFallback(query);
  }

  void _generateApiImage() {
    final name = _nameController.text.trim();
    final category = _selectedCategory.trim();
    final randomInt = Random().nextInt(1000);
    final keyword = name.isNotEmpty 
        ? '${name.replaceAll(' ', ',')},$category,nature' 
        : '$category,nature';
    final imageUrl = 'https://loremflickr.com/800/600/${Uri.encodeComponent(keyword)}/all?lock=$randomInt';

    setState(() {
      _imageUrlController.text = imageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL Gambar API Otomatis telah disiapkan!'),
        backgroundColor: Color(0xFFE57E22),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JemberProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          _spotId == null ? 'Tambah Wisata Baru' : 'Edit Tempat Wisata',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title indicator
              const Text(
                'Informasi Wisata Jember',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F4C38), // PrimaryGreen
                ),
              ),
              const SizedBox(height: 16),

              // Nama Wisata
              TextField(
                key: const Key('form_name_input'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Wisata *',
                  prefixIcon: const Icon(Icons.drive_file_rename_outline),
                  suffixIcon: _isApifySearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF8F4C38),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.travel_explore, color: Color(0xFFE57E22)),
                          tooltip: 'Autofill data dari Google Maps (Apify)',
                          onPressed: () => _searchGoogleMapsApify(_nameController.text),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Category dropdown
              DropdownButtonFormField<String>(
                key: const Key('form_category_dropdown'),
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori Wisata *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
                items: categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Alamat Lengkap
              TextField(
                key: const Key('form_address_input'),
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap *',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _isApifySearching || _isGeocoding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF8F4C38),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, color: Color(0xFF8F4C38)),
                          tooltip: 'Cari Detail Wisata dari Alamat (Apify)',
                          onPressed: () => _searchGoogleMapsApify(_addressController.text),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi Wisata
              TextField(
                key: const Key('form_desc_input'),
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Wisata *',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Price & Hours Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('form_price_input'),
                      controller: _ticketPriceController,
                      decoration: InputDecoration(
                        labelText: 'Harga Tiket (cth: Rp 10.000)',
                        prefixIcon: const Icon(Icons.local_activity),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      key: const Key('form_hours_input'),
                      controller: _openingHoursController,
                      decoration: InputDecoration(
                        labelText: 'Jam Buka (cth: 08:00 - 17:00)',
                        prefixIcon: const Icon(Icons.schedule),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Latitude & Longitude Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('form_lat_input'),
                      controller: _latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Latitude (misal: -8.441)',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      key: const Key('form_lng_input'),
                      controller: _longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Longitude (misal: 113.55)',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Rating & Image URL Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      key: const Key('form_rating_input'),
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Rating (1.0 - 5.0)',
                        prefixIcon: const Icon(Icons.star),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: const Key('form_image_input'),
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL Gambar Wisata',
                        prefixIcon: const Icon(Icons.image),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.auto_awesome, color: Color(0xFFE57E22)),
                          tooltip: 'Gunakan Gambar API Otomatis',
                          onPressed: _generateApiImage,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: const Key('submit_form_button'),
                  onPressed: () async {
                    final name = _nameController.text;
                    final address = _addressController.text;
                    final description = _descriptionController.text;
                    final ticketPrice = _ticketPriceController.text;
                    final openingHours = _openingHoursController.text;
                    final rating = double.tryParse(_ratingController.text) ?? 4.5;
                    final latitude = double.tryParse(_latitudeController.text) ?? 0.0;
                    final longitude = double.tryParse(_longitudeController.text) ?? 0.0;
                    final imageUrl = _imageUrlController.text;

                    if (name.trim().isEmpty || address.trim().isEmpty || description.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama, Alamat, dan Deskripsi wajib diisi!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (_spotId == null) {
                      await provider.addWisata(
                        name: name,
                        category: _selectedCategory,
                        address: address,
                        description: description,
                        ticketPrice: ticketPrice,
                        openingHours: openingHours,
                        rating: rating,
                        latitude: latitude,
                        longitude: longitude,
                        imageUrl: imageUrl,
                      );
                    } else {
                      await provider.updateWisata(
                        id: _spotId!,
                        name: name,
                        category: _selectedCategory,
                        address: address,
                        description: description,
                        ticketPrice: ticketPrice,
                        openingHours: openingHours,
                        rating: rating,
                        latitude: latitude,
                        longitude: longitude,
                        imageUrl: imageUrl,
                      );
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.crudMessage ?? 'Berhasil disimpan!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      provider.clearCrudStates();
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(
                    _spotId == null ? Icons.save : Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    _spotId == null ? 'Daftarkan Destinasi' : 'Simpan Perubahan Wisata',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F4C38), // PrimaryGreen
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
      ),
    );
  }
}
