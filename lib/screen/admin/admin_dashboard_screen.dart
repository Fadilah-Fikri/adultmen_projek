import 'package:flutter/material.dart';
// Sesuaikan path import jika diperlukan
import 'dashboard_overview_page.dart';
import 'manage_products_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _adminPages = <Widget>[
    const DashboardOverviewPage(),
    const ManageProductsScreen(),
    const Center(child: Text('Kelola Pengguna')),
    const Center(child: Text('Pengaturan')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: const CircleAvatar(
              child: Icon(Icons.admin_panel_settings),
            ),
            
            // --- PERUBAHAN DILAKUKAN DI BAGIAN 'trailing' INI ---
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  // Menggunakan Column untuk menumpuk tombol
                  child: Column( 
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol baru untuk melihat toko
                      IconButton(
                        icon: const Icon(Icons.storefront_outlined),
                        tooltip: 'Lihat Tampilan Toko',
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                      ),
                      const SizedBox(height: 8),
                      // Tombol logout yang sudah ada
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
                    ],
                  ),
                ),
              ),
            ),
            // ---------------------------------------------------

            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Produk'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group),
                label: Text('Pengguna'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _adminPages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}