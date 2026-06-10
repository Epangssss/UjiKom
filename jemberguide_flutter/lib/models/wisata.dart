class Wisata {
  final int? id;
  final String name;
  final String category;
  final String address;
  final String description;
  final String openingHours;
  final String ticketPrice;
  final double rating;
  final double latitude;
  final double longitude;
  final String imageUrl;

  Wisata({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.description,
    required this.openingHours,
    required this.ticketPrice,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory Wisata.fromMap(Map<String, dynamic> map) {
    return Wisata(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      address: map['address'],
      description: map['description'],
      openingHours: map['openingHours'],
      ticketPrice: map['ticketPrice'],
      rating: map['rating'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'description': description,
      'openingHours': openingHours,
      'ticketPrice': ticketPrice,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }

  Wisata copyWith({
    int? id,
    String? name,
    String? category,
    String? address,
    String? description,
    String? openingHours,
    String? ticketPrice,
    double? rating,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) {
    return Wisata(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      description: description ?? this.description,
      openingHours: openingHours ?? this.openingHours,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
