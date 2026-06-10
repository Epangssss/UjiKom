import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jember_provider.dart';

class AddEditWisataScreen extends StatefulWidget {
  const AddEditWisataScreen({super.key});

  @override
  State<AddEditWisataScreen> createState() => _AddEditWisataScreenState();
}

class _AddEditWisataScreenState extends State<AddEditWisataScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.5');
  final _latitudeController = TextEditingController(text: '0.0');
  final _longitudeController = TextEditingController(text: '0.0');
  final _imageUrlController = TextEditingController();
  final _newCategoryController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  final String _addNewCategoryText = '+ Tambah Kategori Baru';
  
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
        
        _categories = provider.uniqueCategories.where((c) => c != 'Semua').toList();
        if (!_categories.contains(_addNewCategoryText)) {
          _categories.add(_addNewCategoryText);
        }

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
        
        if (_categories.contains(spot.category)) {
          _selectedCategory = spot.category;
        } else {
          _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
        }
      } else {
        final provider = Provider.of<JemberProvider>(context, listen: false);
        _categories = provider.uniqueCategories.where((c) => c != 'Semua').toList();
        if (!_categories.contains(_addNewCategoryText)) {
          _categories.add(_addNewCategoryText);
        }
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JemberProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_spotId == null ? 'Tambah Wisata' : 'Edit Wisata'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Wisata', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c, 
                    child: Text(
                      c, 
                      style: TextStyle(
                        fontWeight: c == _addNewCategoryText ? FontWeight.bold : FontWeight.normal,
                        color: c == _addNewCategoryText ? Theme.of(context).colorScheme.primary : Colors.black87,
                      )
                    )
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              if (_selectedCategory == _addNewCategoryText) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori Baru', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_box),
                  ),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openingHoursController,
                      decoration: const InputDecoration(labelText: 'Jam Buka', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ticketPriceController,
                      decoration: const InputDecoration(labelText: 'Harga Tiket', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating (1.0 - 5.0)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar', border: OutlineInputBorder()),
              ),
              if (provider.crudMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  provider.crudMessage!,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final finalCategory = _selectedCategory == _addNewCategoryText 
                        ? _newCategoryController.text.trim() 
                        : _selectedCategory ?? '';
                        
                    if (_spotId == null) {
                      await provider.addWisata(
                        name: _nameController.text,
                        category: finalCategory,
                        address: _addressController.text,
                        description: _descriptionController.text,
                        ticketPrice: _ticketPriceController.text,
                        openingHours: _openingHoursController.text,
                        rating: double.tryParse(_ratingController.text) ?? 4.5,
                        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
                        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
                        imageUrl: _imageUrlController.text,
                      );
                    } else {
                      await provider.updateWisata(
                        id: _spotId!,
                        name: _nameController.text,
                        category: finalCategory,
                        address: _addressController.text,
                        description: _descriptionController.text,
                        ticketPrice: _ticketPriceController.text,
                        openingHours: _openingHoursController.text,
                        rating: double.tryParse(_ratingController.text) ?? 4.5,
                        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
                        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
                        imageUrl: _imageUrlController.text,
                      );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.crudMessage ?? 'Berhasil')),
                      );
                      provider.clearCrudStates();
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SIMPAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
