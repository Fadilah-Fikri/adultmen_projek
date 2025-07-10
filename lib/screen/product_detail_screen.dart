// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:adultmen_uas/models/fragrance.dart'; // Sesuaikan path

class ProductDetailScreen extends StatelessWidget {
  final Fragrance fragrance;

  const ProductDetailScreen({super.key, required this.fragrance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fragrance.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Produk
            Hero( // Animasi transisi yang keren
              tag: 'fragrance-image-${fragrance.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  fragrance.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama & Kategori
            Text(
              fragrance.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              fragrance.category,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Harga (Pastikan model Fragrance punya properti price)
            Text(
              'Rp ${fragrance.price ?? 'N/A'}', // Ganti 'price' sesuai nama kolom di Supabase
              style: const TextStyle(fontSize: 22, color: Colors.deepPurple, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Deskripsi
            const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              fragrance.desc,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
      // Tombol Aksi di bagian bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Logika untuk menambah ke keranjang
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${fragrance.name} ditambahkan ke keranjang!')),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ke Keranjang'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Logika untuk langsung ke halaman checkout
                },
                child: const Text('Beli Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}