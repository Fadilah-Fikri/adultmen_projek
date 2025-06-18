import 'package:flutter/material.dart';
import '../widget/fragrance_card.dart';

class Fragrance {
  final String name;
  final String desc;
  final String imageUrl;

  Fragrance({required this.name, required this.desc, required this.imageUrl});
}

class HomeScreen extends StatelessWidget {
  final featured = [
    Fragrance(name: 'Canale di Blue', desc: 'An intense & sophisticated aroma', imageUrl: 'assets/images/canale_di_blue.jpg'),
    Fragrance(name: 'Louis Ombre', desc: 'A mysterious & private series', imageUrl: 'assets/images/louis_ombre.jpg'),
    Fragrance(name: 'Proud of You', desc: 'An absolutely captivating scent', imageUrl: 'assets/images/proud_of_you.jpg'),
  ];

  final newArrivals = [
    Fragrance(name: 'Hint Zencha', desc: 'The essence of zen in a bottle', imageUrl: 'assets/images/hint_zencha.jpg'),
    Fragrance(name: 'Hint Noble', desc: 'An elegant & noble fragrance', imageUrl: 'assets/images/hint_noble.jpg'),
    Fragrance(name: 'Cosmar', desc: 'Fresh & invigorating', imageUrl: 'assets/images/cosmar.jpg'), // Ganti nama file jika perlu
    Fragrance(name: 'Sauvage', desc: 'Natural & earthy', imageUrl: 'assets/images/sauvage.jpg'), // Ganti nama file jika perlu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: true,
            title: Text('Semerbak Harum'), // JUDUL BARU
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
          ),
          _buildSectionTitle(context, "Featured Fragrances"),
          SliverToBoxAdapter(
            child: Container(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  final f = featured[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    child: FragranceCard(name: f.name, desc: f.desc, imageUrl: f.imageUrl),
                  );
                },
              ),
            ),
          ),
          _buildSectionTitle(context, "New Arrivals"),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final f = newArrivals[index];
                  return FragranceCard(name: f.name, desc: f.desc, imageUrl: f.imageUrl);
                },
                childCount: newArrivals.length,
              ),
            ),
          ),
          _buildSectionTitle(context, "Promotions"),
          SliverToBoxAdapter(
            child: _buildPromotionCard(context),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
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
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Color(0xFFC8B6A6), Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Limited Time Offer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text("Get 20% Off All Fragrances!\nUse code FRAGRANCE20 at checkout.", style: TextStyle(color: Colors.white.withOpacity(0.9))),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).primaryColor),
            onPressed: () {},
            child: Text("Shop Now"),
          )
        ],
      ),
    );
  }
}