import 'package:flutter/foundation.dart';
import 'package:adultmen_uas/models/fragrance.dart';
import 'package:adultmen_uas/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.fragrance.price * cartItem.quantity;
    });
    return total;
  }

  void addToCart(Fragrance fragrance) {
    if (_items.containsKey(fragrance.id)) {
      // Jika sudah ada, tambah kuantitasnya
      _items.update(
        fragrance.id,
        (existingItem) => CartItem(
          id: existingItem.id,
          fragrance: existingItem.fragrance,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Jika belum ada, tambahkan item baru
      _items.putIfAbsent(
        fragrance.id,
        () => CartItem(
          id: DateTime.now().toString(), // ID unik untuk item keranjang
          fragrance: fragrance,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Beri tahu widget bahwa ada perubahan
  }

  void removeFromCart(String fragranceId) {
    _items.remove(fragranceId);
    notifyListeners();
  }
  
  void updateQuantity(String fragranceId, int newQuantity) {
    if (!_items.containsKey(fragranceId)) return;

    if (newQuantity <= 0) {
      removeFromCart(fragranceId);
    } else {
       _items.update(
        fragranceId,
        (existingItem) => CartItem(
          id: existingItem.id,
          fragrance: existingItem.fragrance,
          quantity: newQuantity,
        ),
      );
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}