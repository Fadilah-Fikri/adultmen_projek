import 'package:adultmen_uas/screen/admin/add_edit_product_screen.dart';
import 'package:adultmen_uas/screen/home_screen.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditProductScreen()),
              ).then((result) {
                if (result == true) {
                  // Cukup panggil setState kosong untuk memicu build ulang FutureBuilder
                  setState(() {});
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<Fragrance>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
                child: Text('Belum ada produk. Silakan tambahkan.'));
          }

          return PaginatedDataTable2(
            columns: const [
              DataColumn(label: Text('Gambar')),
              DataColumn(label: Text('Nama Produk')),
              DataColumn(label: Text('Harga'), numeric: true),
              DataColumn(label: Text('Stok'), numeric: true),
              DataColumn(label: Text('Aksi')),
            ],
            source: _ProductDataSource(products, context, () {
              setState(() {}); // Panggil setState untuk refresh
            }),
            rowsPerPage: 10,
            columnSpacing: 20,
            horizontalMargin: 20,
            minWidth: 800,
          );
        },
      ),
    );
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
}

// Data Source untuk tabel data
class _ProductDataSource extends DataTableSource {
  final List<Fragrance> _products;
  final BuildContext _context;
  final VoidCallback _onDataChanged;

  _ProductDataSource(this._products, this._context, this._onDataChanged);

  Future<void> _deleteProduct(String productId) async {
    try {
      await Supabase.instance.client
          .from('fragrances')
          .delete()
          .eq('id', productId);

      ScaffoldMessenger.of(_context).showSnackBar(const SnackBar(
        content: Text('Produk berhasil dihapus'),
        backgroundColor: Colors.green,
      ));
      _onDataChanged(); // Panggil callback untuk refresh UI
    } catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
        content: Text('Gagal menghapus produk: $e'),
        backgroundColor: Theme.of(_context).colorScheme.error,
      ));
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _products.length) return null;
    final product = _products[index];
    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child:
              CircleAvatar(backgroundImage: NetworkImage(product.imageUrl)),
        )),
        DataCell(Text(product.name)),
        DataCell(Text('Rp ${product.price.toStringAsFixed(0)}')),
        DataCell(Text('N/A')), // Placeholder untuk stok
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                      _context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddEditProductScreen(productId: product.id))).then((result) {
                    if (result == true) _onDataChanged();
                  });
                }),
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: _context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: Text(
                            'Anda yakin ingin menghapus produk "${product.name}"?'),
                        actions: [
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              _deleteProduct(product.id);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _products.length;

  @override
  int get selectedRowCount => 0;
}