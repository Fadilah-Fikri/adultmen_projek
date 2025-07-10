// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:adultmen_uas/models/fragrance.dart'; // Sesuaikan path ke model Anda

class CartProvider with ChangeNotifier {
  final List<Fragrance> _items = [];

  // Getter untuk mengakses isi keranjang dari luar
  List<Fragrance> get items => _items;

  // Getter untuk mendapatkan jumlah item di keranjang
  int get itemCount => _items.length;

  // Method untuk menambahkan produk ke keranjang
  void addToCart(Fragrance fragrance) {
    _items.add(fragrance);
    // Beri tahu widget yang mendengarkan bahwa ada perubahan
    notifyListeners(); 
  }

  // Method untuk menghapus produk dari keranjang
  void removeFromCart(Fragrance fragrance) {
    _items.remove(fragrance);
    notifyListeners();
  }

  // Method untuk membersihkan keranjang
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}