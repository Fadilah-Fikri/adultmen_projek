import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'checkout_page.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList(); // Mengambil daftar item dari Map

    final formattedTotalPrice = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(cart.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Anda (${cart.itemCount})'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Keranjang Anda masih kosong.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final formattedItemPrice = NumberFormat.currency(
                        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                    .format(item.fragrance.price);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Image.network(item.fragrance.imageUrl, width: 50, fit: BoxFit.cover),
                    title: Text(item.fragrance.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(formattedItemPrice, style: TextStyle(color: Theme.of(context).primaryColor)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cart.updateQuantity(item.fragrance.id, item.quantity - 1),
                        ),
                        Text(item.quantity.toString(), style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => cart.updateQuantity(item.fragrance.id, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Harga:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(formattedTotalPrice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              cartItems: cartItems,
                              totalPrice: cart.totalPrice,
                            ),
                          ),
                        );
                      },
                      child: const Text('Lanjutkan ke Checkout'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}