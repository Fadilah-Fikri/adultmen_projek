// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendapatkan data & rebuild saat ada perubahan
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Keranjang Anda (${cart.itemCount})'),
          ),
          body: cart.items.isEmpty
              ? const Center(
                  child: Text(
                    'Keranjang Anda masih kosong.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      leading: Image.network(item.imageUrl, width: 50, fit: BoxFit.cover),
                      title: Text(item.name),
                      subtitle: Text('Rp ${item.price ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          // Panggil method untuk menghapus item
                          cart.removeFromCart(item);
                        },
                      ),
                    );
                  },
                ),
          bottomNavigationBar: cart.items.isEmpty ? null : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Logika untuk checkout
              },
              child: const Text('Lanjutkan ke Checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
            ),
          ),
        );
      },
    );
  }
}