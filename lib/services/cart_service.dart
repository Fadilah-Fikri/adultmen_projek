import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/models/cart_item.dart';
import 'package:adultmen_uas/models/fragrance.dart';

class CartService {
  static final ValueNotifier<List<CartItem>> _cartNotifier = ValueNotifier([]);
  static ValueNotifier<List<CartItem>> get cartNotifier => _cartNotifier;
  static List<CartItem> get cartItems => _cartNotifier.value;

  static Future<void> loadCart() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('cart_items')
        .select('*, fragrances(*)') // Ambil data cart_items & data parfum terkait
        .eq('user_id', user.id)
        .order('created_at', ascending: true);
    
    _cartNotifier.value = response.map((item) => CartItem.fromJson(item)).toList();
  }

  static Future<void> addToCart(Fragrance fragrance, {int quantity = 1}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final existingItemIndex = cartItems.indexWhere((item) => item.fragrance.id == fragrance.id);

    if (existingItemIndex != -1) {
      final existingItem = cartItems[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      await updateQuantity(existingItem.id, newQuantity);
    } else {
      await Supabase.instance.client
          .from('cart_items')
          .insert({
            'user_id': user.id,
            'fragrance_id': fragrance.id,
            'quantity': quantity
          });
    }
    await loadCart();
  }

  static Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await Supabase.instance.client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId);
    }
    await loadCart();
  }

  static Future<void> removeFromCart(String cartItemId) async {
    await Supabase.instance.client
        .from('cart_items')
        .delete()
        .eq('id', cartItemId);
    await loadCart();
  }
  
  static void clearCart() {
    _cartNotifier.value = [];
  }
}