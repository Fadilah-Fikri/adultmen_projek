import 'package:adultmen_uas/models/fragrance.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'package:adultmen_uas/widget/fragrance_card.dart'; // <-- Pastikan import ini ada
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_screen.dart';

// 1. Mengubah menjadi StatefulWidget
class ProductDetailPage extends StatefulWidget {
  final Fragrance fragrance;

  const ProductDetailPage({super.key, required this.fragrance});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // 2. Menyiapkan state untuk menyimpan produk terkait dan status loading
  late Future<List<Fragrance>> _relatedProductsFuture;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data saat halaman pertama kali dibuka
    _relatedProductsFuture = _fetchRelatedProducts();
  }

  // 3. Fungsi untuk mengambil produk dari kategori yang sama
  // Di dalam file product_detail_page.dart -> class _ProductDetailPageState

Future<List<Fragrance>> _fetchRelatedProducts() async {
  try {
    // Langkah 1: Coba cari 7 produk lain di KATEGORI YANG SAMA
    var response = await Supabase.instance.client
        .from('fragrances')
        .select()
        .eq('category', widget.fragrance.category)
        .neq('id', widget.fragrance.id)
        .limit(7); // <-- Batasi 7 produk

    // Langkah 2: JIKA TIDAK ADA, cari 7 produk lain secara acak
    if (response.isEmpty) {
      debugPrint("Tidak ada produk terkait di kategori yang sama. Mencari produk lain...");
      response = await Supabase.instance.client
          .from('fragrances')
          .select()
          .neq('id', widget.fragrance.id) // Tetap kecualikan produk saat ini
          .limit(7); // <-- Batasi 7 produk juga
    }

    return response.map((item) => Fragrance.fromJson(item)).toList();
    
  } catch (e) {
    debugPrint("Error fetching related products: $e");
    return []; // Kembalikan list kosong jika terjadi error
  }
}

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(widget.fragrance.price);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fragrance.name),
         actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN DETAIL PRODUK UTAMA ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sisi Kiri: Gambar
                  Expanded(
                    flex: 2,
                    child: Hero(
                      tag: 'fragrance-image-${widget.fragrance.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(widget.fragrance.imageUrl,
                            fit: BoxFit.contain, height: 400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Sisi Kanan: Info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.fragrance.category.toUpperCase(),
                            style: GoogleFonts.montserrat(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(widget.fragrance.name,
                            style: GoogleFonts.lora(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(formattedPrice,
                            style: GoogleFonts.montserrat(
                                fontSize: 28, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 24),
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        const Text('Deskripsi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.fragrance.desc,
                            style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20)),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .addToCart(widget.fragrance);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${widget.fragrance.name} ditambahkan ke keranjang!'),
                                    behavior: SnackBarBehavior.floating),
                              );
                            },
                            child: const Text('Tambah ke Keranjang',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- 4. BAGIAN PRODUK LAINNYA ---
            _buildRelatedProductsSection(),

          ],
        ),
      ),
    );
  }

  // Widget baru untuk membangun bagian "Produk Lainnya"
  Widget _buildRelatedProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anda Mungkin Juga Suka',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250, // Beri tinggi tetap untuk list horizontal
            child: FutureBuilder<List<Fragrance>>(
              future: _relatedProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada produk terkait.'));
                }
                final relatedProducts = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final f = relatedProducts[index];
                    return Container(
                      width: 160, // Beri lebar tetap untuk setiap kartu
                      margin: const EdgeInsets.only(right: 16),
                      // Menggunakan kembali FragranceCard yang sudah ada
                      child: FragranceCard(
                        id: f.id,
                        name: f.name,
                        desc: f.desc,
                        imageUrl: f.imageUrl,
                        category: f.category,
                        price: f.price,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}