import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/wisata.dart';
import '../database/database_helper.dart';

class JemberProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Auth State
  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _authError;
  String? get authError => _authError;

  bool _registrationSuccess = false;
  bool get registrationSuccess => _registrationSuccess;

  // Wisata State
  List<Wisata> _allWisata = [];
  List<Wisata> get allWisata => _allWisata;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Wisata> _searchResults = [];
  List<Wisata> get searchResults => _searchResults;

  List<String> get uniqueCategories {
    final categories = _allWisata.map((w) => w.category).toSet().toList();
    categories.sort();
    return ['Semua', ...categories];
  }

  // CRUD State
  String? _crudMessage;
  String? get crudMessage => _crudMessage;

  void clearAuthStates() {
    _authError = null;
    _registrationSuccess = false;
    notifyListeners();
  }

  void clearCrudStates() {
    _crudMessage = null;
    notifyListeners();
  }

  // --- Authentication Actions ---
  Future<void> login(String username, String password) async {
    _authError = null;
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _authError = "Username dan Password tidak boleh kosong";
      notifyListeners();
      return;
    }

    final user = await _dbHelper.getUser(username);
    if (user == null) {
      _authError = "Username tidak ditemukan";
    } else if (user.password != password) {
      _authError = "Password salah";
    } else {
      _currentUser = user;
      _authError = null;
    }
    notifyListeners();
  }

  Future<void> signUp(String username, String password, String fullName, String email, String phone, String address) async {
    _authError = null;
    _registrationSuccess = false;
    
    if (username.trim().isEmpty || password.trim().isEmpty || fullName.trim().isEmpty || email.trim().isEmpty || phone.trim().isEmpty) {
      _authError = "Semua kolom wajib diisi, kecuali alamat";
      notifyListeners();
      return;
    }

    final existingUser = await _dbHelper.getUser(username);
    if (existingUser != null) {
      _authError = "Username sudah digunakan";
      notifyListeners();
      return;
    }

    final newUser = User(
      username: username,
      password: password,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
    );

    await _dbHelper.insertUser(newUser);
    _registrationSuccess = true;
    notifyListeners();
  }

  void logOut() {
    _currentUser = null;
    clearAuthStates();
  }

  Future<void> updateProfile(String fullName, String email, String phone, String address) async {
    if (_currentUser == null) return;

    final updatedUser = User(
      username: _currentUser!.username,
      password: _currentUser!.password,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
    );

    await _dbHelper.updateUser(updatedUser);
    _currentUser = updatedUser;
    _crudMessage = "Profil berhasil diperbarui!";
    notifyListeners();
  }

  // --- Wisata CRUD Actions ---
  Future<void> loadAllWisata() async {
    _allWisata = await _dbHelper.getAllWisata();
    _updateSearchResults();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _updateSearchResults();
    notifyListeners();
  }

  void _updateSearchResults() {
    if (_searchQuery.isEmpty) {
      _searchResults = List.from(_allWisata);
    } else {
      _searchResults = _allWisata.where((wisata) {
        return wisata.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> addWisata({
    required String name,
    required String category,
    required String address,
    required String description,
    required String ticketPrice,
    required String openingHours,
    required double rating,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    if (name.trim().isEmpty || address.trim().isEmpty || description.trim().isEmpty) {
      _crudMessage = "Kolom nama, alamat, dan deskripsi wajib diisi!";
      notifyListeners();
      return;
    }

    String validatedImageUrl = imageUrl;
    if (imageUrl.trim().isEmpty) {
      switch (category.toLowerCase()) {
        case "pantai":
          validatedImageUrl = "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80";
          break;
        case "air terjun":
          validatedImageUrl = "https://images.unsplash.com/photo-1432406186267-5c2c140a5a6e?auto=format&fit=crop&w=800&q=80";
          break;
        case "taman":
          validatedImageUrl = "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80";
          break;
        case "alam":
          validatedImageUrl = "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80";
          break;
        case "edukasi":
          validatedImageUrl = "https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=800&q=80";
          break;
        default:
          validatedImageUrl = "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80";
      }
    }

    final newSpot = Wisata(
      name: name,
      category: category,
      address: address,
      description: description,
      ticketPrice: ticketPrice.trim().isEmpty ? "Gratis" : ticketPrice,
      openingHours: openingHours.trim().isEmpty ? "24 Jam" : openingHours,
      rating: rating <= 0 ? 4.5 : rating,
      latitude: latitude,
      longitude: longitude,
      imageUrl: validatedImageUrl,
    );

    await _dbHelper.insertWisata(newSpot);
    _crudMessage = "Destinasi wisata berhasil ditambahkan!";
    await loadAllWisata();
  }

  Future<void> updateWisata({
    required int id,
    required String name,
    required String category,
    required String address,
    required String description,
    required String ticketPrice,
    required String openingHours,
    required double rating,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    if (name.trim().isEmpty || address.trim().isEmpty || description.trim().isEmpty) {
      _crudMessage = "Kolom nama, alamat, dan deskripsi wajib diisi!";
      notifyListeners();
      return;
    }

    final existingSpot = await _dbHelper.getWisataById(id);
    if (existingSpot == null) {
      _crudMessage = "Destinasi tidak ditemukan!";
      notifyListeners();
      return;
    }

    final updatedSpot = existingSpot.copyWith(
      name: name,
      category: category,
      address: address,
      description: description,
      ticketPrice: ticketPrice.trim().isEmpty ? "Gratis" : ticketPrice,
      openingHours: openingHours.trim().isEmpty ? "24 Jam" : openingHours,
      rating: rating <= 0 ? 4.5 : rating,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl.trim().isEmpty ? existingSpot.imageUrl : imageUrl,
    );

    await _dbHelper.updateWisata(updatedSpot);
    _crudMessage = "Destinasi wisata berhasil diubah!";
    await loadAllWisata();
  }

  Future<void> deleteWisata(int id) async {
    await _dbHelper.deleteWisata(id);
    _crudMessage = "Destinasi wisata berhasil dihapus!";
    await loadAllWisata();
  }
}
