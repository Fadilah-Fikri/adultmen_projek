class Fragrance {
  final String id;
  final String name;
  final String desc;
  final String imageUrl;
  final double price;

  Fragrance({
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
    required this.price
  });

  factory Fragrance.fromJson(Map<String, dynamic> json) {
    return Fragrance(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      desc: json['description'] ?? 'No Description',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }
}