import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'package:adultmen_uas/models/cart_item.dart';
import 'order_success_page.dart';
import 'addresses_page.dart';
import 'package:intl/intl.dart';

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
  Map<String, dynamic>? _selectedAddress;
  bool _isLoadingAddress = true;
  bool _isProcessingPayment = false; // State untuk loading tombol bayar

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'BCA Virtual Account', 'icon': Icons.account_balance_wallet},
    {'name': 'GoPay', 'icon': Icons.phone_android_sharp},
    {'name': 'OVO', 'icon': Icons.phone_android_sharp},
    {'name': 'Indomaret', 'icon': Icons.store},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPrimaryAddress();
  }

  Future<void> _fetchPrimaryAddress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_primary', true)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _selectedAddress = response;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressPage(isSelectionMode: true),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }
  
  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // --- INI ADALAH FUNGSI PEMBAYARAN YANG BENAR ---
  Future<void> _processPayment() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih alamat pengiriman!'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isProcessingPayment = true);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // Langkah 1: Simpan data ke tabel 'orders'
      final orderData = {
        'user_id': userId,
        'total_price': widget.totalPrice + 15000, // Harga total + ongkir
        'shipping_address': _selectedAddress!,
        'payment_method': _selectedPaymentMethod!,
        'status': 'Pesanan Diproses', // Status sudah diubah
      };

      final newOrder = await supabase.from('orders').insert(orderData).select().single();
      final orderId = newOrder['id'];

      // Langkah 2: Siapkan dan simpan data ke tabel 'order_items'
      final orderItems = widget.cartItems.map((cartItem) {
        return {
          'order_id': orderId,
          'fragrance_id': cartItem.fragrance.id,
          'quantity': cartItem.quantity,
          'price': cartItem.fragrance.price,
        };
      }).toList();

      await supabase.from('order_items').insert(orderItems);

      // Langkah 3: Jika berhasil, kosongkan keranjang dan navigasi
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double shippingFee = 15000;
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
            _buildShippingAddressSection(),
            const SizedBox(height: 24),
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
                      setState(() { _selectedPaymentMethod = value; });
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text(_formatPrice(widget.totalPrice)),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Biaya Pengiriman', style: TextStyle(color: Colors.grey)),
              Text(_formatPrice(shippingFee)),
            ]),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_formatPrice(grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessingPayment || _selectedAddress == null || _selectedPaymentMethod == null 
                  ? null 
                  : _processPayment, // Panggil fungsi _processPayment yang benar
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: _isProcessingPayment
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black))
                  : const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_isLoadingAddress)
          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
        else if (_selectedAddress == null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_location_alt_outlined, color: Colors.red),
              title: const Text('Pilih atau Tambah Alamat'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectAddress,
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text(
                _selectedAddress!['recipient_name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_selectedAddress!['full_address']}, ${_selectedAddress!['city']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: TextButton(onPressed: _selectAddress, child: const Text('Ubah')),
            ),
          ),
      ],
    );
  }
}