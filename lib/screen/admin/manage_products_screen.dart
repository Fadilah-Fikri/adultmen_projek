import 'package:flutter/material.dart';
import 'package:adultmen_uas/screen/home_screen.dart'; // Kita pakai ulang model 'Fragrance'
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  // Gunakan Future untuk mengambil data produk
  late Future<List<Fragrance>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  // Method untuk mengambil semua produk dari Supabase
  Future<List<Fragrance>> _fetchProducts() async {
    try {
      final data = await Supabase.instance.client
          .from('fragrances')
          .select()
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      return List<Map<String, dynamic>>.from(data)
          .map((item) => Fragrance.fromJson(item))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching products: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      return [];
    }
  }

  // Method untuk menghapus produk
  Future<void> _deleteProduct(String productId) async {
    try {
      await Supabase.instance.client
          .from('fragrances')
          .delete()
          .eq('id', productId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ));
        // Refresh daftar produk setelah menghapus
        setState(() {
          _productsFuture = _fetchProducts();
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
      ),
      // Tombol untuk menambah produk baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigasi ke halaman Add/Edit Product dalam mode 'Tambah'
          print('Navigate to Add Product Screen');
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Fragrance>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada produk. Silakan tambahkan.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.imageUrl),
                    onBackgroundImageError: (_, __) {}, // Handle image error
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        onPressed: () {
                          // TODO: Navigasi ke halaman Add/Edit Product dalam mode 'Edit'
                          print('Edit product with ID: ${product.id}');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () {
                          // Tampilkan dialog konfirmasi sebelum menghapus
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: Text('Anda yakin ingin menghapus produk "${product.name}"?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Batal'),
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      _deleteProduct(product.id);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}