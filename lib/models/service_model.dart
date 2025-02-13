class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String description;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrl,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: double.parse((map['price'] ?? 0).toString()),
      duration: int.parse((map['duration'] ?? 0).toString()),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
} 