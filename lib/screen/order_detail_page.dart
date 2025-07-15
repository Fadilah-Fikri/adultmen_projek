import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<List<Map<String, dynamic>>> _orderItemsFuture;

  @override
  void initState() {
    super.initState();
    _orderItemsFuture = _fetchOrderItems();
  }

  // Mengambil item-item yang ada di dalam satu pesanan
  Future<List<Map<String, dynamic>>> _fetchOrderItems() async {
    final response = await Supabase.instance.client
        .from('order_items')
        .select('quantity, price, fragrances(*)') // Ambil data item & gabungkan dengan data dari tabel 'fragrances'
        .eq('order_id', widget.order['id']);
    return List<Map<String, dynamic>>.from(response);
  }
  
  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final orderDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.parse(widget.order['created_at']));
    final shippingAddress = widget.order['shipping_address'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.order['id'].substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Info Umum Pesanan
            _buildInfoSection(
              title: 'Informasi Pesanan',
              details: {
                'Tanggal': orderDate,
                'Status': widget.order['status'],
                'Total': _formatPrice(double.parse(widget.order['total_price'].toString())),
                'Metode Pembayaran': widget.order['payment_method'],
              },
            ),
            const SizedBox(height: 24),

            // Bagian Alamat Pengiriman
            _buildInfoSection(
              title: 'Alamat Pengiriman',
              details: {
                'Penerima': shippingAddress['recipient_name'],
                'Telepon': shippingAddress['phone_number'],
                'Alamat': '${shippingAddress['full_address']}, ${shippingAddress['city']}, ${shippingAddress['postal_code']}',
              },
            ),
            const SizedBox(height: 24),

            // Bagian Daftar Produk
            const Text('Daftar Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _orderItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak dapat memuat item pesanan.');
                }
                final items = snapshot.data!;
                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final fragrance = item['fragrances'];
                      return ListTile(
                        leading: Image.network(fragrance['image_url'], width: 50, fit: BoxFit.cover),
                        title: Text(fragrance['name']),
                        subtitle: Text('${item['quantity']} x ${_formatPrice(double.parse(item['price'].toString()))}'),
                        trailing: Text(_formatPrice(double.parse(item['price'].toString()) * item['quantity'])),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan section info
  Widget _buildInfoSection({required String title, required Map<String, String> details}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: details.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(color: Colors.grey)),
                      Flexible(
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}