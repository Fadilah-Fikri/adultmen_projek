import 'package:adultmen_uas/models/fragrance.dart';

class CartItem {
  final String id; // ID unik untuk setiap entri di keranjang
  final int quantity;
  final Fragrance fragrance;

  CartItem({
    required this.id,
    required this.quantity,
    required this.fragrance,
  });

  // --- METHOD copyWith YANG DIMINTA ---
  // Method ini membuat salinan objek CartItem dengan nilai yang bisa diubah.
  CartItem copyWith({
    String? id,
    int? quantity,
    Fragrance? fragrance,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      fragrance: fragrance ?? this.fragrance,
    );
  }
  // ------------------------------------

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      quantity: json['quantity'] as int,
      // 'fragrances' adalah nama tabel yang kita join dari Supabase
      fragrance: Fragrance.fromJson(json['fragrances']), 
    );
  }
}