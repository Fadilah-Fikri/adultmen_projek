import 'package:flutter/material.dart';
import 'package:adultmen_uas/services/favorite_service.dart';
import 'package:adultmen_uas/widget/fragrance_card.dart';
import 'package:adultmen_uas/models/fragrance.dart'; // Untuk mengakses model Fragrance

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final ValueNotifier<List<Fragrance>> _favoritesNotifier;

  @override
  void initState() {
    super.initState();
    _favoritesNotifier = FavoriteService.favoritesNotifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Fragrance>>(
        valueListenable: _favoritesNotifier,
        builder: (context, favoriteList, child) {
          if (favoriteList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No Favorites Yet',
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap the heart on any product to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteList.length,
            itemBuilder: (context, index) {
              final f = favoriteList[index];
              return FragranceCard(
                id: f.id,
                name: f.name,
                desc: f.desc,
                imageUrl: f.imageUrl,
                category: f.category, // <-- INI ADALAH PERUBAHAN YANG DIMAKSUD
              );
            },
          );
        },
      ),
    );
  }
}