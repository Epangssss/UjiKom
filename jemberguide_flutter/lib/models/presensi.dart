class Presensi {
  final int? id;
  final String username;
  final String date;
  final String time;
  final double latitude;
  final double longitude;
  final String address;
  final String status; // e.g., 'Tepat Waktu', 'Terlambat'

  Presensi({
    this.id,
    required this.username,
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'date': date,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
    };
  }

  factory Presensi.fromMap(Map<String, dynamic> map) {
    return Presensi(
      id: map['id'] as int?,
      username: map['username'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
      status: map['status'] as String,
    );
  }

  Presensi copyWith({
    int? id,
    String? username,
    String? date,
    String? time,
    double? latitude,
    double? longitude,
    String? address,
    String? status,
  }) {
    return Presensi(
      id: id ?? this.id,
      username: username ?? this.username,
      date: date ?? this.date,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
}
