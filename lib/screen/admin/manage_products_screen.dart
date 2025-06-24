import 'package:flutter/material.dart';
import 'package:adultmen_uas/screen/admin/add_edit_product_screen.dart'; // IMPORT HALAMAN FORM
import 'package:adultmen_uas/screen/home_screen.dart'; //Kita pakai ulang model 'Fragrance'
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  late Future<List<Fragrance>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Fragrance>> _fetchProducts() async {
    try {
      final data = await Supabase.instance.client
          .from('fragrances')
          .select()
          .order('created_at', ascending: false);

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Add/Edit dalam mode 'Tambah' (tanpa productId)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          ).then((result) {
            // Jika halaman form ditutup dan mengembalikan nilai 'true' (artinya ada perubahan),
            // maka kita refresh daftar produk.
            if (result == true) {
              setState(() { _productsFuture = _fetchProducts(); });
            }
          });
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
                    onBackgroundImageError: (_, __) {},
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- TOMBOL EDIT DIPERBARUI ---
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        onPressed: () {
                          // Navigasi ke halaman Add/Edit dalam mode 'Edit' dengan membawa productId
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEditProductScreen(productId: product.id)),
                          ).then((result) {
                            // Refresh daftar produk jika ada perubahan
                            if (result == true) {
                              setState(() { _productsFuture = _fetchProducts(); });
                            }
                          });
                        },
                      ),
                      // --- TOMBOL HAPUS (Sudah Benar) ---
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () {
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