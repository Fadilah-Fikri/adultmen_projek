import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/models/fragrance.dart'; // Sesuaikan path jika perlu

class ProductDetailPage extends StatefulWidget {
  final String fragranceId;

  const ProductDetailPage({
    super.key,
    required this.fragranceId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Fragrance?> _fragranceFuture;

  @override
  void initState() {
    super.initState();
    // Memuat detail parfum berdasarkan ID yang diterima
    _fragranceFuture = _fetchFragranceDetails();
  }

  // Fungsi untuk mengambil satu data parfum dari Supabase
  Future<Fragrance?> _fetchFragranceDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('fragrances')
          .select()
          .eq('id', widget.fragranceId)
          .single(); // .single() untuk mengambil satu baris data

      return Fragrance.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching product detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail produk: $e')),
        );
      }
      return null;
    }
  }

  // Fungsi untuk format harga
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]}.'
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<Fragrance?>(
        future: _fragranceFuture,
        builder: (context, snapshot) {
          // 1. Saat sedang loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Jika ada error atau data tidak ditemukan
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan.'));
          }

          // 3. Jika data berhasil dimuat
          final fragrance = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gunakan Hero untuk animasi transisi gambar yang halus
                Hero(
                  tag: 'fragrance-image-${fragrance.id}',
                  child: Image.network(
                    fragrance.imageUrl,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 350, child: Icon(Icons.error)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fragrance.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatPrice(fragrance.price),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fragrance.desc,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Tombol di bagian bawah halaman
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFFD4AF37), // Warna gold
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Aksi untuk "Tambah ke Keranjang"
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Segera hadir: Fitur Keranjang')),
            );
          },
          child: const Text(
            'Tambah ke Keranjang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}