class Fragrance {
  final String id;
  final String name;
  final String desc;
  final String imageUrl;
  final double price;
  final String category; // <-- 1. TAMBAHKAN PROPERTI INI

  Fragrance({
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
    required this.price,
    required this.category, // <-- 2. TAMBAHKAN DI CONSTRUCTOR
  });

  factory Fragrance.fromJson(Map<String, dynamic> json) {
    return Fragrance(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      desc: json['description'] ?? 'No Description',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      // 3. TAMBAHKAN PARSING DARI JSON.
      // Jika kategori null di database, akan diberi nilai 'Uncategorized'
      category: json['category'] ?? 'Uncategorized', 
    );
  }
}