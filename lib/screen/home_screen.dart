import 'package:flutter/material.dart';
import 'package:adultmen_uas/widget/fragrance_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Fragrance {
  final String id;
  final String name;
  final String desc;
  final String imageUrl;
  final double price;

  Fragrance({
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
    required this.price
  });

  factory Fragrance.fromJson(Map<String, dynamic> json) {
    return Fragrance(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      desc: json['description'] ?? 'No Description',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // State untuk "Featured Fragrances" (tetap menggunakan FutureBuilder karena lebih sederhana di dalam SliverToBoxAdapter)
  late final Future<List<Fragrance>> _featuredFragrancesFuture;

  // State untuk "New Arrivals" yang akan kita kelola manual
  List<Fragrance> _newArrivalsList = [];
  bool _newArrivalsLoading = true;
  String? _newArrivalsError;

  @override
  void initState() {
    super.initState();
    _featuredFragrancesFuture = _fetchFragrances(isFeatured: true);
    // Panggil method untuk mengambil data New Arrivals
    _fetchNewArrivals();
  }

  Future<List<Fragrance>> _fetchFragrances({bool isFeatured = false, int? limit}) async {
    try {
      dynamic query = Supabase.instance.client.from('fragrances').select();
      if (isFeatured) query = query.eq('is_featured', true);
      if (limit != null) query = query.limit(limit);
      final data = await query;
      return List<Map<String, dynamic>>.from(data)
          .map((item) => Fragrance.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching fragrances: $e');
      // Melempar error agar bisa ditangkap oleh FutureBuilder
      throw 'Failed to load fragrances: $e';
    }
  }

  // Method khusus untuk New Arrivals yang menggunakan setState
  Future<void> _fetchNewArrivals() async {
    try {
      final arrivals = await _fetchFragrances(limit: 4);
      if (mounted) {
        setState(() {
          _newArrivalsList = arrivals;
          _newArrivalsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _newArrivalsError = e.toString();
          _newArrivalsLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      _buildHomeContent(),
      Center(child: Text('Shop Screen', style: Theme.of(context).textTheme.headlineSmall)),
      Center(child: Text('Favorites Screen', style: Theme.of(context).textTheme.headlineSmall)),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile Screen', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: true,
          snap: false,
          centerTitle: true,
          title: Text('Semerbak Harum'),
          actions: [IconButton(onPressed: null, icon: Icon(Icons.search))],
        ),
        _buildSectionTitle(context, "Featured Fragrances"),
        SliverToBoxAdapter(
          child: Container(
            height: 220,
            child: FutureBuilder<List<Fragrance>>(
              future: _featuredFragrancesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading(true);
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(snapshot.error?.toString() ?? 'No featured items.'));
                }
                final fragrances = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: fragrances.length,
                  itemBuilder: (context, index) {
                    final f = fragrances[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: FragranceCard(
                          id: f.id,
                          name: f.name,
                          desc: f.desc,
                          imageUrl: f.imageUrl),
                    );
                  },
                );
              },
            ),
          ),
        ),
        _buildSectionTitle(context, "New Arrivals"),
        
        // --- BAGIAN YANG DIPERBAIKI ---
        // Kita sekarang menggunakan kondisi if-else untuk membangun sliver yang tepat
        if (_newArrivalsLoading)
          _buildShimmerSliverGrid()
        else if (_newArrivalsError != null)
          SliverToBoxAdapter(
            child: Center(
              heightFactor: 4,
              child: Text('Failed to load new arrivals: $_newArrivalsError'),
            ),
          )
        else if (_newArrivalsList.isEmpty)
           const SliverToBoxAdapter(
            child: Center(
              heightFactor: 4,
              child: Text('No new arrivals available.'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final f = _newArrivalsList[index];
                  return FragranceCard(
                      id: f.id,
                      name: f.name,
                      desc: f.desc,
                      imageUrl: f.imageUrl);
                },
                childCount: _newArrivalsList.length,
              ),
            ),
          ),
        // --- AKHIR BAGIAN YANG DIPERBAIKI ---

        _buildSectionTitle(context, "Promotions"),
        SliverToBoxAdapter(
          child: _buildPromotionCard(context),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  // Method shimmer untuk ListView (Box)
  Widget _buildShimmerLoading(bool isHorizontal) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  // Method shimmer untuk SliverGrid (Sliver)
  Widget _buildShimmerSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250.0,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
              ),
            );
          },
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFC8B6A6),
            Theme.of(context).colorScheme.secondary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Limited Time Offer",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18)),
          const SizedBox(height: 8),
          Text(
              "Get 20% Off All Fragrances!\nUse code FRAGRANCE20 at checkout.",
              style: TextStyle(color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor),
            onPressed: () {},
            child: const Text("Shop Now"),
          )
        ],
      ),
    );
  }
}