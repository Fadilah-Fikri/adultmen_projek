import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _productCount = 0;
  int _userCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

 // Ganti keseluruhan method _fetchDashboardStats dengan kode ini

Future<void> _fetchDashboardStats() async {
    // Pastikan status loading di-set di awal jika belum
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // --- CARA BARU UNTUK MENGHITUNG ---
      // Menghitung jumlah produk
      final productCount = await Supabase.instance.client
          .from('fragrances')
          .count(CountOption.exact);
      
      // Menghitung jumlah pengguna
      final userCount = await Supabase.instance.client
          .from('profiles')
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
          // Hasilnya adalah integer langsung, tidak perlu .count lagi
          _productCount = productCount;
          _userCount = userCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching stats: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _fetchDashboardStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardStats,
              child: GridView.count(
                padding: const EdgeInsets.all(16.0),
                crossAxisCount: 2, // 2 kartu per baris
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Produk',
                    value: _productCount.toString(),
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total Pengguna',
                    value: _userCount.toString(),
                    icon: Icons.group_outlined,
                    color: Colors.green,
                  ),
                   _buildStatCard(
                    context,
                    title: 'Total Penjualan',
                    value: 'Rp 0', // Placeholder
                    icon: Icons.monetization_on_outlined,
                    color: Colors.orange,
                    isPlaceholder: true,
                    placeholderText: 'Fitur pesanan belum dibuat'
                  ),
                  _buildNavCard(
                    context,
                    title: 'Kelola Produk',
                    icon: Icons.settings_outlined,
                    onTap: () {
                       Navigator.pushNamed(context, '/manage_products');
                    }
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, bool isPlaceholder = false, String? placeholderText}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: color),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            if (isPlaceholder)
              Text(placeholderText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))
          ],
        ),
      ),
    );
  }

    Widget _buildNavCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}