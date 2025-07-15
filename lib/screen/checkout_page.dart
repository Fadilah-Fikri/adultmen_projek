import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'package:adultmen_uas/models/cart_item.dart';
import 'order_success_page.dart'; // Halaman yang akan kita buat selanjutnya

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedPaymentMethod;

  // Daftar metode pembayaran (simulasi)
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'BCA Virtual Account', 'icon': Icons.account_balance_wallet},
    {'name': 'GoPay', 'icon': Icons.phone_android_sharp},
    {'name': 'OVO', 'icon': Icons.phone_android_sharp},
    {'name': 'Indomaret', 'icon': Icons.store},
  ];
  
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  void _processPayment() {
    // Di aplikasi nyata, di sini akan ada integrasi dengan payment gateway
    // Untuk saat ini, kita langsung arahkan ke halaman sukses
    
    // 1. Kosongkan keranjang setelah "pembayaran"
    Provider.of<CartProvider>(context, listen: false).clearCart();
    
    // 2. Navigasi ke halaman sukses dan hapus semua halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderSuccessPage(),
      ),
      (route) => false, // Hapus semua rute sebelumnya dari stack
    );
  }

  @override
  Widget build(BuildContext context) {
    const double shippingFee = 15000; // Contoh biaya pengiriman
    final double grandTotal = widget.totalPrice + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Alamat Pengiriman
            const Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('John Doe'),
                subtitle: const Text('Jl. Merdeka No. 17, Surakarta, Jawa Tengah, 57144\n(+62) 812-3456-7890'),
                trailing: TextButton(onPressed: () {}, child: const Text('Ubah')),
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Ringkasan Pesanan
            const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    leading: Image.network(item.fragrance.imageUrl, width: 50),
                    title: Text(item.fragrance.name),
                    subtitle: Text('${item.quantity} x ${_formatPrice(item.fragrance.price)}'),
                    trailing: Text(_formatPrice(item.fragrance.price * item.quantity)),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 3. Pilihan Metode Pembayaran
            const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _paymentMethods.map((method) {
                  return RadioListTile<String>(
                    title: Text(method['name']),
                    secondary: Icon(method['icon']),
                    value: method['name'],
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                Text(_formatPrice(widget.totalPrice)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Biaya Pengiriman', style: TextStyle(color: Colors.grey)),
                Text(_formatPrice(shippingFee)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  _formatPrice(grandTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedPaymentMethod == null ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}