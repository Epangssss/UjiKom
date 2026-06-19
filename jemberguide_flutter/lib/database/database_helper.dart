import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/wisata.dart';
import '../models/presensi.dart';
import 'web_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // In-memory data for Web fallback
  final List<User> _webUsers = [];
  final List<Wisata> _webWisata = [];
  final List<Presensi> _webPresensi = [];
  final Map<String, String> _webSettings = {};
  int _webWisataIdCounter = 1;
  bool _webSeeded = false;
  bool _webDataLoaded = false;

  void _loadWebData() {
    if (_webDataLoaded) return;
    _webDataLoaded = true;

    final usersJson = WebStorage.get('web_users');
    if (usersJson != null) {
      try {
        final List decoded = json.decode(usersJson);
        _webUsers.clear();
        _webUsers.addAll(decoded.map((item) => User.fromMap(item)));
      } catch (e) {
        debugPrint('Error loading web users: $e');
      }
    }

    final settingsJson = WebStorage.get('web_settings');
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(settingsJson);
        _webSettings.clear();
        decoded.forEach((k, v) {
          _webSettings[k] = v.toString();
        });
      } catch (e) {
        debugPrint('Error loading web settings: $e');
      }
    }

    final counterStr = WebStorage.get('web_wisata_counter');
    if (counterStr != null) {
      _webWisataIdCounter = int.tryParse(counterStr) ?? 1;
    }

    final wisataJson = WebStorage.get('web_wisata');
    if (wisataJson != null) {
      try {
        final List decoded = json.decode(wisataJson);
        _webWisata.clear();
        _webWisata.addAll(decoded.map((item) => Wisata.fromMap(item)));
        _webSeeded = true;
      } catch (e) {
        debugPrint('Error loading web wisata: $e');
      }
    }

    final presensiJson = WebStorage.get('web_presensi');
    if (presensiJson != null) {
      try {
        final List decoded = json.decode(presensiJson);
        _webPresensi.clear();
        _webPresensi.addAll(decoded.map((item) => Presensi.fromMap(item)));
      } catch (e) {
        debugPrint('Error loading web presensi: $e');
      }
    }
  }

  void _saveWebData() {
    try {
      WebStorage.save('web_users', json.encode(_webUsers.map((u) => u.toMap()).toList()));
      WebStorage.save('web_wisata', json.encode(_webWisata.map((w) => w.toMap()).toList()));
      WebStorage.save('web_presensi', json.encode(_webPresensi.map((p) => p.toMap()).toList()));
      WebStorage.save('web_settings', json.encode(_webSettings));
      WebStorage.save('web_wisata_counter', _webWisataIdCounter.toString());
    } catch (e) {
      debugPrint('Error saving web data: $e');
    }
  }

  void _seedWebIfNeeded() {
    if (_webSeeded) return;
    _webSeeded = true;
    final initialData = [
      Wisata(
        id: _webWisataIdCounter++,
        name: "Pantai Papuma",
        category: "Pantai",
        address: "Desa Lojejer, Kecamatan Wuluhan, Jember",
        description: "Pantai dengan pasir putih yang sangat indah dan deretan batu karang yang menjulang tinggi di tengah laut. Terkenal dengan pemandangan matahari terbit dan tenggelam yang memukau serta perahu nelayan yang bersandar estetis.",
        openingHours: "24 Jam",
        ticketPrice: "Rp 15.000",
        rating: 4.8,
        latitude: -8.4419,
        longitude: 113.5539,
        imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        id: _webWisataIdCounter++,
        name: "Teluk Love",
        category: "Pantai",
        address: "Kawasan Pantai Payangan, Ambulu, Jember",
        description: "Teluk unik berbentuk hati (Love) yang terbentuk secara alami dari garis tebing dan deburan ombak.",
        openingHours: "05:00 - 18:00",
        ticketPrice: "Rp 10.000",
        rating: 4.6,
        latitude: -8.4352,
        longitude: 113.6190,
        imageUrl: "https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=800&q=80"
      ),
    ];
    _webWisata.addAll(initialData);
    _saveWebData();
  }

  Future<Database> get database async {
    if (kIsWeb) {
      _seedWebIfNeeded();
      // Dummy throw because web won't use this getter
      throw UnsupportedError('Web uses memory storage, not sqflite');
    }
    
    if (_database != null) return _database!;
    _database = await _initDB('jemberguide.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        username TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wisata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        address TEXT NOT NULL,
        description TEXT NOT NULL,
        openingHours TEXT NOT NULL,
        ticketPrice TEXT NOT NULL,
        rating REAL NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE presensi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await _seedInitialWisata(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('''
        CREATE TABLE users (
          username TEXT PRIMARY KEY,
          password TEXT NOT NULL,
          fullName TEXT NOT NULL,
          email TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE presensi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          address TEXT NOT NULL,
          status TEXT NOT NULL
        )
      ''');
    }
  }

  Future _seedInitialWisata(Database db) async {
    final initialData = [
      Wisata(
        name: "Pantai Papuma",
        category: "Pantai",
        address: "Desa Lojejer, Kecamatan Wuluhan, Jember",
        description: "Pantai dengan pasir putih yang sangat indah dan deretan batu karang yang menjulang tinggi di tengah laut. Terkenal dengan pemandangan matahari terbit dan tenggelam yang memukau serta perahu nelayan yang bersandar estetis.",
        openingHours: "24 Jam",
        ticketPrice: "Rp 15.000",
        rating: 4.8,
        latitude: -8.4419,
        longitude: 113.5539,
        imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        name: "Teluk Love",
        category: "Pantai",
        address: "Kawasan Pantai Payangan, Ambulu, Jember",
        description: "Teluk unik berbentuk hati (Love) yang terbentuk secara alami dari garis tebing dan deburan ombak. Pengunjung dapat menaiki Bukit Domba untuk menyaksikan lekukan bentuk hati ini secara sempurna.",
        openingHours: "05:00 - 18:00",
        ticketPrice: "Rp 10.000",
        rating: 4.6,
        latitude: -8.4352,
        longitude: 113.6190,
        imageUrl: "https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        name: "Puncak Rembangan",
        category: "Alam",
        address: "Dusun Rembangan, Kemuning Lor, Arjasa, Jember",
        description: "Destinasi dataran tinggi pegunungan sejuk di lereng Gunung Argopuro. Menyuguhkan pemandangan bentang kota Jember dari ketinggian, perkebunan buah naga, susu sapi segar khas, dan sejuknya kolam renang alami peninggalan Belanda.",
        openingHours: "07:00 - 22:00",
        ticketPrice: "Rp 12.000",
        rating: 4.5,
        latitude: -8.0827,
        longitude: 113.7121,
        imageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        name: "Air Terjun Tancak",
        category: "Air Terjun",
        address: "Desa Suco Pangepok, Jelbuk, Jember",
        description: "Air terjun tertinggi di kabupaten Jember dengan ketinggian mencapai 82 meter yang mengalir deras di lereng perbukitan hijau. Dikelilingi hutan yang asri dan hamparan wangi perkebunan kopi robusta.",
        openingHours: "07:00 - 16:30",
        ticketPrice: "Rp 5.000",
        rating: 4.4,
        latitude: -8.0401,
        longitude: 113.7259,
        imageUrl: "https://images.unsplash.com/photo-1432406186267-5c2c140a5a6e?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        name: "Taman Botani Sukorambi",
        category: "Taman",
        address: "Jl. Mujahir, Sukorambi, Jember",
        description: "Taman botani rekreasi edukatif terlengkap di Jember. Sempurna untuk rekreasi keluarga dengan koleksi ratusan jenis tanaman obat, bunga cantik, kebun buah hewan ternak kecil, kolam renang, dan outbound.",
        openingHours: "08:00 - 16:00",
        ticketPrice: "Rp 20.000",
        rating: 4.5,
        latitude: -8.1565,
        longitude: 113.6655,
        imageUrl: "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80"
      ),
      Wisata(
        name: "Puslit Kopi dan Kakao",
        category: "Edukasi",
        address: "Desa Nogosari, Rambipuji, Jember",
        description: "Satu-satunya Pusat Penelitian Kopi dan Kakao di Indonesia. Memberikan edukasi menarik tentang pembibitan, modernisasi pengolahan kopi dan cokelat, berkeliling menaiki kereta kayu tradisional, serta kafe cokelat premium.",
        openingHours: "08:00 - 15:30",
        ticketPrice: "Rp 15.000",
        rating: 4.7,
        latitude: -8.2435,
        longitude: 113.6111,
        imageUrl: "https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=800&q=80"
      )
    ];

    for (var wisata in initialData) {
      await db.insert('wisata', wisata.toMap());
    }
  }

  // --- User Operations ---
  Future<User?> getUser(String username) async {
    if (kIsWeb) {
      _loadWebData();
      _seedWebIfNeeded();
      try {
        return _webUsers.firstWhere((u) => u.username == username);
      } catch (_) {
        return null;
      }
    }
    
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertUser(User user) async {
    if (kIsWeb) {
      _loadWebData();
      _webUsers.add(user);
      _saveWebData();
      return;
    }
    
    final db = await instance.database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(User user) async {
    if (kIsWeb) {
      _loadWebData();
      final index = _webUsers.indexWhere((u) => u.username == user.username);
      if (index != -1) {
        _webUsers[index] = user;
        _saveWebData();
      }
      return;
    }
    
    final db = await instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'username = ?',
      whereArgs: [user.username],
    );
  }

  // --- Wisata Operations ---
  Future<List<Wisata>> getAllWisata() async {
    if (kIsWeb) {
      _loadWebData();
      _seedWebIfNeeded();
      return List.from(_webWisata);
    }
    
    final db = await instance.database;
    final result = await db.query('wisata');
    return result.map((json) => Wisata.fromMap(json)).toList();
  }

  Future<Wisata?> getWisataById(int id) async {
    if (kIsWeb) {
      _loadWebData();
      try {
        return _webWisata.firstWhere((w) => w.id == id);
      } catch (_) {
        return null;
      }
    }
    
    final db = await instance.database;
    final maps = await db.query(
      'wisata',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Wisata.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Wisata>> searchWisata(String query) async {
    if (kIsWeb) {
      _loadWebData();
      return _webWisata.where((w) => w.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    
    final db = await instance.database;
    final result = await db.query(
      'wisata',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((json) => Wisata.fromMap(json)).toList();
  }

  Future<void> insertWisata(Wisata wisata) async {
    if (kIsWeb) {
      _loadWebData();
      final newWisata = wisata.copyWith(id: _webWisataIdCounter++);
      _webWisata.add(newWisata);
      _saveWebData();
      return;
    }
    
    final db = await instance.database;
    await db.insert('wisata', wisata.toMap());
  }

  Future<void> updateWisata(Wisata wisata) async {
    if (kIsWeb) {
      _loadWebData();
      final index = _webWisata.indexWhere((w) => w.id == wisata.id);
      if (index != -1) {
        _webWisata[index] = wisata;
        _saveWebData();
      }
      return;
    }
    
    final db = await instance.database;
    await db.update(
      'wisata',
      wisata.toMap(),
      where: 'id = ?',
      whereArgs: [wisata.id],
    );
  }

  Future<void> deleteWisata(int id) async {
    if (kIsWeb) {
      _loadWebData();
      _webWisata.removeWhere((w) => w.id == id);
      _saveWebData();
      return;
    }
    
    final db = await instance.database;
    await db.delete(
      'wisata',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Settings / Key-Value helper ---
  Future<void> saveSetting(String key, String value) async {
    if (kIsWeb) {
      _loadWebData();
      _webSettings[key] = value;
      _saveWebData();
      return;
    }
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      _loadWebData();
      return _webSettings[key];
    }
    final db = await instance.database;
    final maps = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> deleteSetting(String key) async {
    if (kIsWeb) {
      _loadWebData();
      _webSettings.remove(key);
      _saveWebData();
      return;
    }
    final db = await instance.database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // --- Presensi Operations ---
  Future<void> insertPresensi(Presensi presensi) async {
    if (kIsWeb) {
      _loadWebData();
      final newPresensi = presensi.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      _webPresensi.add(newPresensi);
      _saveWebData();
      return;
    }
    
    final db = await instance.database;
    await db.insert('presensi', presensi.toMap());
  }

  Future<List<Presensi>> getPresensiByUser(String username) async {
    if (kIsWeb) {
      _loadWebData();
      return _webPresensi.where((p) => p.username == username).toList().reversed.toList();
    }
    
    final db = await instance.database;
    final maps = await db.query(
      'presensi',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC'
    );
    return maps.map((json) => Presensi.fromMap(json)).toList();
  }
}
