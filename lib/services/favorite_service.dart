import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/models/fragrance.dart';

class FavoriteService {
  static final ValueNotifier<List<Fragrance>> _favoritesNotifier = ValueNotifier([]);
  static ValueNotifier<List<Fragrance>> get favoritesNotifier => _favoritesNotifier;
  static List<Fragrance> get favorites => _favoritesNotifier.value;

  static bool isFavorite(String fragranceId) {
    return favorites.any((fragrance) => fragrance.id == fragranceId);
  }

  // BARU: Fungsi untuk memuat favorit dari database
  static Future<void> loadFavoritesForUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return; // Jangan lakukan apa-apa jika tidak ada user

    try {
      final response = await Supabase.instance.client
          .from('user_favorites')
          .select('fragrances(*)') // Ambil semua data parfum yang terhubung
          .eq('user_id', user.id);

      final favoriteList = List<Map<String, dynamic>>.from(response)
          .map((item) => Fragrance.fromJson(item['fragrances']))
          .toList();
          
      _favoritesNotifier.value = favoriteList;
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      // Mungkin tampilkan snackbar jika perlu
    }
  }

  // BARU: Fungsi untuk membersihkan favorit saat logout
  static void clearFavorites() {
    _favoritesNotifier.value = [];
  }

  // MODIFIKASI: toggleFavorite sekarang mengelola state lokal dan database
  static Future<void> toggleFavorite(Fragrance fragrance) async {
    final isCurrentlyFavorite = isFavorite(fragrance.id);
    final currentFavorites = List<Fragrance>.from(favorites);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // Mungkin tampilkan pesan "Anda harus login untuk menambahkan favorit"
      return;
    }

    if (isCurrentlyFavorite) {
      // Hapus dari state lokal
      currentFavorites.removeWhere((item) => item.id == fragrance.id);
      _favoritesNotifier.value = currentFavorites;
      // Hapus dari database
      await _removeFavoriteFromDB(user.id, fragrance.id);
    } else {
      // Tambah ke state lokal
      currentFavorites.add(fragrance);
      _favoritesNotifier.value = currentFavorites;
      // Tambah ke database
      await _addFavoriteToDB(user.id, fragrance.id);
    }
  }

  // Helper untuk menambah ke DB
  static Future<void> _addFavoriteToDB(String userId, String fragranceId) async {
    try {
      await Supabase.instance.client
          .from('user_favorites')
          .insert({'user_id': userId, 'fragrance_id': fragranceId});
    } catch (e) {
      debugPrint("Error adding favorite to DB: $e");
    }
  }

  // Helper untuk menghapus dari DB
  static Future<void> _removeFavoriteFromDB(String userId, String fragranceId) async {
    try {
      await Supabase.instance.client
          .from('user_favorites')
          .delete()
          .match({'user_id': userId, 'fragrance_id': fragranceId});
    } catch (e) {
      debugPrint("Error removing favorite from DB: $e");
    }
  }
}