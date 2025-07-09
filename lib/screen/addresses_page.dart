import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_edit_address_page.dart'; // Halaman form yang akan kita buat selanjutnya

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late Future<List<Map<String, dynamic>>> _addressesFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _addressesFuture = _fetchAddresses();
  }

  Future<List<Map<String, dynamic>>> _fetchAddresses() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memuat alamat: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return [];
    }
  }

  void _refreshAddresses() {
    setState(() {
      _addressesFuture = _fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya'),
        backgroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final addresses = snapshot.data!;
          if (addresses.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki alamat.\nSilakan tambahkan alamat baru.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressCard(address);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditAddressPage()),
          );
          if (result == true) {
            _refreshAddresses();
          }
        },
        label: const Text('Tambah Alamat'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address['is_primary'] == true ? const Color(0xFFD4AF37) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address['label'] ?? 'Alamat',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (address['is_primary'] == true)
                  const Chip(
                    label: Text('Utama'),
                    backgroundColor: Color(0xFFD4AF37),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              address['recipient_name'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(address['phone_number']),
            const SizedBox(height: 4),
            Text(address['full_address']),
            Text('${address['city']}, ${address['postal_code']}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditAddressPage(address: address),
                      ),
                    );
                    if (result == true) {
                      _refreshAddresses();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAddress(address['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('addresses').delete().eq('id', addressId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat berhasil dihapus'), backgroundColor: Colors.green),
        );
        _refreshAddresses();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus alamat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}