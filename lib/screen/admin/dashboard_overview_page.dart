import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({Key? key}) : super(key: key);

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  int _productCount = 0;
  int _userCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    if (!_isLoading) setState(() => _isLoading = true);
    try {
      // Mengambil jumlah produk
      final productCount = await Supabase.instance.client
          .from('fragrances')
          .count(CountOption.exact);

      // Mengambil jumlah pengguna
      final userCount = await Supabase.instance.client
          .from('profiles')
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _fetchDashboardStats,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardStats,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Kartu Statistik
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(context,
                          title: 'Total Produk',
                          value: _productCount.toString(),
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.blue),
                      _buildStatCard(context,
                          title: 'Total Pengguna',
                          value: _userCount.toString(),
                          icon: Icons.group_outlined,
                          color: Colors.green),
                      _buildStatCard(context,
                          title: 'Total Penjualan',
                          value: 'Rp 0',
                          icon: Icons.monetization_on_outlined,
                          color: Colors.orange,
                          isPlaceholder: true,
                          placeholderText: 'Fitur pesanan belum dibuat'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Kartu Grafik
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Grafik Penjualan (Contoh)",
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 20,
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [
                                      BarChartRodData(
                                          toY: 8,
                                          color: Colors.lightBlue,
                                          width: 20)
                                    ]),
                                    BarChartGroupData(x: 1, barRods: [
                                      BarChartRodData(
                                          toY: 10,
                                          color: Colors.lightBlue,
                                          width: 20)
                                    ]),
                                    BarChartGroupData(x: 2, barRods: [
                                      BarChartRodData(
                                          toY: 14,
                                          color: Colors.lightBlue,
                                          width: 20)
                                    ]),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      bool isPlaceholder = false,
      String? placeholderText}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            if (isPlaceholder)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(placeholderText!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              )
          ],
        ),
      ),
    );
  }
}