import 'package:adultmen_uas/models/fragrance.dart';

class CartItem {
  final String id; // ID dari item di tabel cart_items
  final int quantity;
  final Fragrance fragrance;

  CartItem({
    required this.id,
    required this.quantity,
    required this.fragrance,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      quantity: json['quantity'] as int,
      // 'fragrances' adalah nama tabel yang kita join dari Supabase
      fragrance: Fragrance.fromJson(json['fragrances']), 
    );
  }
}