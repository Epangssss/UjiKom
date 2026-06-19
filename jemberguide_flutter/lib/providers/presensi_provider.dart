import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/presensi.dart';
import '../database/database_helper.dart';

class PresensiProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<Presensi> _historiPresensi = [];
  List<Presensi> get historiPresensi => _historiPresensi;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadHistori(String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      _historiPresensi = await _dbHelper.getPresensiByUser(username);
    } catch (e) {
      _errorMessage = "Gagal memuat histori presensi: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> catatPresensi(String username) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 1. Cek Izin Lokasi
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif. Harap aktifkan GPS Anda.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen. Harap ubah di pengaturan aplikasi.');
      }

      // 2. Dapatkan Lokasi
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 3. Dapatkan Alamat (Reverse Geocoding dengan Geoapify)
      String address = "Alamat tidak ditemukan";
      try {
        final apiKey = 'd1f1fe16f7aa4021bd3d22c8e7e2111c';
        final url = Uri.parse(
            'https://api.geoapify.com/v1/geocode/reverse?lat=${position.latitude}&lon=${position.longitude}&apiKey=$apiKey');
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['features'] != null && data['features'].isNotEmpty) {
            final formattedAddress = data['features'][0]['properties']['formatted'];
            if (formattedAddress != null) {
              address = formattedAddress;
            } else {
              address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
            }
          } else {
            address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
          }
        } else {
           address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
        }
      } catch (e) {
        debugPrint("Geoapify Geocoding error: $e");
        address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      }

      // 4. Waktu dan Status
      DateTime now = DateTime.now();
      String date = DateFormat('yyyy-MM-dd').format(now);
      String time = DateFormat('HH:mm:ss').format(now);
      
      // Logika Sederhana: Tepat waktu jika sebelum jam 08:00
      String status = "Tepat Waktu";
      if (now.hour >= 8) {
        status = "Terlambat";
      }

      // 5. Simpan ke Database
      final presensi = Presensi(
        username: username,
        date: date,
        time: time,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        status: status,
      );

      await _dbHelper.insertPresensi(presensi);
      _successMessage = "Presensi berhasil dicatat pada $time";
      
      // Reload histori
      await loadHistori(username);

    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
