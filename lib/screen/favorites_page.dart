// lib/screens/favorites_page.dart

import 'package:flutter/material.dart';
// Sesuaikan path ini dengan lokasi file Anda
import 'package:adultmen_uas/services/favorite_service.dart';
import 'package:adultmen_uas/widget/fragrance_card.dart';
import 'package:adultmen_uas/models/fragrance.dart'; // Untuk mengakses model Fragrance

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      // Widget ini akan otomatis rebuild saat daftar favorit berubah
      body: ValueListenableBuilder<List<Fragrance>>(
        valueListenable: FavoriteService.favoritesNotifier,
        builder: (context, favoriteList, child) {
          // Tampilkan pesan jika tidak ada item favorit
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          // Tampilkan daftar favorit dalam bentuk Grid
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0, // Lebar maksimal setiap item
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7, // Rasio tinggi-lebar item
            ),
            itemCount: favoriteList.length,
            itemBuilder: (context, index) {
              final f = favoriteList[index];
              return FragranceCard(
                id: f.id,
                name: f.name,
                desc: f.desc,
                imageUrl: f.imageUrl,
              );
            },
          );
        },
      ),
    );
  }
}