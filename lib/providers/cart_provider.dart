// lib/providers/cart_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/models/fragrance.dart';

class CartProvider with ChangeNotifier {
  final List<Fragrance> _items = [];
  bool _isCartLoaded = false;

  List<Fragrance> get items => _items;
  int get itemCount => _items.length;

  CartProvider() {
    loadCartFromLocal();
  }

  Future<void> loadCartFromLocal() async {
  if (_isCartLoaded) return;

  final prefs = await SharedPreferences.getInstance();
  final String? cartString = prefs.getString('cart_items');
  
  if (cartString == null) {
    _isCartLoaded = true;
    return;
  }

  final List<dynamic> productIds = jsonDecode(cartString);
  if (productIds.isEmpty) {
    _isCartLoaded = true;
    return;
  }

  try {
    // --- ALTERNATIF DIMULAI DI SINI ---
    // 1. Buat filter string dari list productIds
    // Hasilnya akan seperti: "id.eq.uuid1,id.eq.uuid2,id.eq.uuid3"
    final orFilter = productIds.map((id) => 'id.eq.$id').join(',');

    // 2. Gunakan filter string tersebut di dalam metode .or()
    final response = await Supabase.instance.client
        .from('fragrances')
        .select()
        .or(orFilter); // Gunakan .or() sebagai pengganti .in_()
    // --- AKHIR ALTERNATIF ---

    _items.clear();
    _items.addAll(response.map((item) => Fragrance.fromJson(item)).toList());
    
    _isCartLoaded = true;
    notifyListeners();
  } catch (e) {
    debugPrint("Error memuat keranjang dari Supabase: $e");
  }
}
  Future<void> _saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    
    // --- PERBAIKAN UTAMA DI SINI ---
    // Variabel 'items' diubah menjadi 'item' dan nama List diubah menjadi 'productIds'
    final List<String> productIds = _items.map((item) => item.id).toList();
    await prefs.setString('cart_items', jsonEncode(productIds));
  }

  void addToCart(Fragrance fragrance) {
    if (!_items.any((item) => item.id == fragrance.id)) {
      _items.add(fragrance);
      _saveCartToLocal();
      notifyListeners();
    }
  }

  void removeFromCart(Fragrance fragrance) {
    _items.removeWhere((item) => item.id == fragrance.id);
    _saveCartToLocal();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCartToLocal();
    notifyListeners();
  }
}