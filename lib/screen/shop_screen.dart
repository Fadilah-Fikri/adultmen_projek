// lib/screens/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/models/fragrance.dart';
import 'package:adultmen_uas/widget/fragrance_card.dart';
import 'product_detail_page.dart';

// --- 1. TAMBAHKAN IMPORT UNTUK PROVIDER & CART ---
import 'package:provider/provider.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'cart_screen.dart';


class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  List<Fragrance> _allFragrances = [];
  List<Fragrance> _filteredFragrances = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAllFragrances();
    _searchController.addListener(_filterFragrances);
  }
  
  Future<void> _fetchAllFragrances() async {
    try {
      final data = await Supabase.instance.client.from('fragrances').select();
      final fragrances = List<Map<String, dynamic>>.from(data)
          .map((item) => Fragrance.fromJson(item))
          .toList();
      
      if (mounted) {
        setState(() {
          _allFragrances = fragrances;
          _filteredFragrances = fragrances;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat produk: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  void _filterFragrances() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFragrances = _allFragrances.where((fragrance) {
        final fragranceName = fragrance.name.toLowerCase();
        return fragranceName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        centerTitle: true,
        // --- 2. TAMBAHKAN TOMBOL KERANJANG DI SINI ---
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama parfum...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _buildProductGrid(),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_filteredFragrances.isEmpty) {
      return const Center(
        child: Text(
          'Produk tidak ditemukan.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // Saya sesuaikan kembali agar layout terlihat bagus dengan tombol
        crossAxisCount: 4, 
        crossAxisSpacing:8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.87, // Disesuaikan untuk memberi ruang pada tombol
      ),
      itemCount: _filteredFragrances.length,
      itemBuilder: (context, index) {
        final fragrance = _filteredFragrances[index];
        // --- 3. MODIFIKASI ITEMBUILDER UNTUK MENAMBAHKAN TOMBOL ---
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(fragrance: fragrance),
                    ),
                  );
                },
                child: FragranceCard(
                  id: fragrance.id,
                  name: fragrance.name,
                  desc: fragrance.desc,
                  imageUrl: fragrance.imageUrl,
                  price: fragrance.price,
                  category: fragrance.category,

                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Panggil method addToCart dari CartProvider
                  Provider.of<CartProvider>(context, listen: false).addToCart(fragrance);
                  
                  // Tampilkan notifikasi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${fragrance.name} ditambahkan ke keranjang!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}