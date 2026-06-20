import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/jember_provider.dart';

class AddEditWisataScreen extends StatefulWidget {
  const AddEditWisataScreen({super.key});

  @override
  State<AddEditWisataScreen> createState() => _AddEditWisataScreenState();
}

class _AddEditWisataScreenState extends State<AddEditWisataScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  TextEditingController? _autoCompleteController;
  final _descriptionController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _ratingController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final List<TextEditingController> _imageUrlControllers = [TextEditingController()];

  final MapController _mapController = MapController();
  LatLng? _pickedLocation;

  final List<String> categories = [
    'Pantai',
    'Air Terjun',
    'Taman',
    'Kolam Renang',
    'Alam',
    'Gunung/Bukit'
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
        
        _imageUrlControllers.clear();
        if (spot.imageUrls.isEmpty) {
          _imageUrlControllers.add(TextEditingController());
        } else {
          for (var url in spot.imageUrls) {
            _imageUrlControllers.add(TextEditingController(text: url));
          }
        }
        
        _pickedLocation = LatLng(spot.latitude, spot.longitude);
        
        if (categories.contains(spot.category)) {
          _selectedCategory = spot.category;
        } else if (spot.category.isNotEmpty) {
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
    for (var c in _imageUrlControllers) {
      c.dispose();
    }
    super.dispose();
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
      if (_imageUrlControllers.isEmpty) {
        _imageUrlControllers.add(TextEditingController(text: imageUrl));
      } else {
        _imageUrlControllers.first.text = imageUrl;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL Gambar API Otomatis telah disiapkan!'),
        backgroundColor: Color(0xFFE57E22),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _getAddressFromGeoapify(LatLng point) async {
    final apiKey = 'd1f1fe16f7aa4021bd3d22c8e7e2111c';
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/reverse?lat=${point.latitude}&lon=${point.longitude}&apiKey=$apiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final address = data['features'][0]['properties']['formatted'];
          if (address != null) {
            if (!mounted) return;
            setState(() {
              _addressController.text = address;
              if (_autoCompleteController != null) {
                _autoCompleteController!.text = address;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alamat berhasil dideteksi otomatis!'),
                backgroundColor: Color(0xFF8F4C38),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Geoapify Reverse Geocoding Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JemberProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                initialValue: _selectedCategory,
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

              // Alamat Lengkap (Autocomplete)
              Autocomplete<Map<String, dynamic>>(
                initialValue: TextEditingValue(text: _addressController.text),
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.length < 3) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  final apiKey = 'd1f1fe16f7aa4021bd3d22c8e7e2111c';
                  // Memaksa kata 'Jember' dalam pencarian agar API fokus ke Jember
                  final searchQuery = textEditingValue.text.toLowerCase().contains('jember')
                      ? textEditingValue.text
                      : '${textEditingValue.text} Jember';
                  
                  // Menggunakan filter seluruh Indonesia + bias lokasi ke tengah Jember agar tidak ada tempat di Jember yang terpotong
                  final url = Uri.parse('https://api.geoapify.com/v1/geocode/autocomplete?text=${Uri.encodeComponent(searchQuery)}&apiKey=$apiKey&lang=id&limit=10&filter=countrycode:id&bias=proximity:113.6995,-8.1724');
                  try {
                    final response = await http.get(url);
                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      final features = data['features'] as List;
                      final rawOptions = features.map((f) => f['properties'] as Map<String, dynamic>).toList();
                      
                      // Filter ketat hasil di sisi aplikasi: Harus ada kaitan dengan Jember
                      final filteredOptions = rawOptions.where((opt) {
                        final formatted = (opt['formatted'] ?? '').toString().toLowerCase();
                        final county = (opt['county'] ?? '').toString().toLowerCase();
                        final city = (opt['city'] ?? '').toString().toLowerCase();
                        final stateDistrict = (opt['state_district'] ?? '').toString().toLowerCase();
                        final name = (opt['name'] ?? '').toString().toLowerCase();
                        
                        return formatted.contains('jember') || 
                               county.contains('jember') || 
                               city.contains('jember') ||
                               stateDistrict.contains('jember') ||
                               name.contains('jember');
                      }).toList();

                      return filteredOptions;
                    }
                  } catch (e) {
                    debugPrint('Autocomplete Error: $e');
                  }
                  return const Iterable<Map<String, dynamic>>.empty();
                },
                displayStringForOption: (Map<String, dynamic> option) => option['formatted'] ?? '',
                onSelected: (Map<String, dynamic> selection) {
                  final formatted = selection['formatted'] ?? '';
                  _addressController.text = formatted;
                  if (_autoCompleteController != null) {
                     _autoCompleteController!.text = formatted;
                  }
                  if (selection['lat'] != null && selection['lon'] != null) {
                    final lat = (selection['lat'] as num).toDouble();
                    final lon = (selection['lon'] as num).toDouble();
                    setState(() {
                      _latitudeController.text = lat.toString();
                      _longitudeController.text = lon.toString();
                      _pickedLocation = LatLng(lat, lon);
                      _mapController.move(_pickedLocation!, 14.0);
                    });
                  }
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  if (_autoCompleteController != textEditingController) {
                    _autoCompleteController = textEditingController;
                  }
                  return TextField(
                    key: const Key('form_address_input'),
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: (val) {
                      _addressController.text = val;
                    },
                    decoration: InputDecoration(
                      labelText: 'Cari Alamat Lengkap (Ketik untuk mencari) *',
                      prefixIcon: const Icon(Icons.location_searching),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Color(0xFF8F4C38), width: 2),
                      ),
                    ),
                  );
                },
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
                      onChanged: (val) {
                        final lat = double.tryParse(val);
                        final lng = double.tryParse(_longitudeController.text);
                        if (lat != null && lng != null) {
                          setState(() {
                            _pickedLocation = LatLng(lat, lng);
                            _mapController.move(_pickedLocation!, _mapController.camera.zoom);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Latitude',
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
                      onChanged: (val) {
                        final lng = double.tryParse(val);
                        final lat = double.tryParse(_latitudeController.text);
                        if (lat != null && lng != null) {
                          setState(() {
                            _pickedLocation = LatLng(lat, lng);
                            _mapController.move(_pickedLocation!, _mapController.camera.zoom);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Longitude',
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

              // Interactive Leaflet Map Picker
              const Text(
                'Pilih Lokasi di Peta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pickedLocation ?? const LatLng(-8.1724, 113.6995), // Default to Jember
                    initialZoom: 11.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _pickedLocation = point;
                        _latitudeController.text = point.latitude.toString();
                        _longitudeController.text = point.longitude.toString();
                      });
                      _getAddressFromGeoapify(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.jemberguide_flutter',
                    ),
                    if (_pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickedLocation!,
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
              const SizedBox(height: 14),

              // Rating Input
              TextField(
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
              const SizedBox(height: 14),

              // Image URLs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar URL Gambar Wisata',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _generateApiImage,
                    icon: const Icon(Icons.auto_awesome, color: Color(0xFFE57E22)),
                    label: const Text('Auto-Generate'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_imageUrlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlControllers[index],
                          decoration: InputDecoration(
                            labelText: 'URL Gambar ${index + 1}',
                            prefixIcon: const Icon(Icons.image),
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
                      if (_imageUrlControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _imageUrlControllers[index].dispose();
                              _imageUrlControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _imageUrlControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Tambah URL Gambar Lainnya'),
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
                    final imageUrl = _imageUrlControllers
                        .map((c) => c.text.trim())
                        .where((text) => text.isNotEmpty)
                        .join('|');

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
