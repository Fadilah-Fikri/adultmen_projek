import 'package:flutter/material.dart';
import 'package:adultmen_uas/services/favorite_service.dart';
import 'package:adultmen_uas/models/fragrance.dart';
import 'package:adultmen_uas/screen/product_detail_page.dart';

class FragranceCard extends StatefulWidget {
  final String id;
  final String name;
  final String desc;
  final String imageUrl;
  final String category; // <-- 1. TAMBAHKAN PROPERTI INI

  const FragranceCard({
    super.key,
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
    required this.category, // <-- 2. TAMBAHKAN DI CONSTRUCTOR
  });

  @override
  State<FragranceCard> createState() => _FragranceCardState();
}

class _FragranceCardState extends State<FragranceCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoriteService.isFavorite(widget.id);
    FavoriteService.favoritesNotifier.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoriteService.favoritesNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    final newIsFavorite = FavoriteService.isFavorite(widget.id);
    if (mounted && _isFavorite != newIsFavorite) {
      setState(() {
        _isFavorite = newIsFavorite;
      });
    }
  }
  
  void _handleToggleFavorite() {
    final fragrance = Fragrance(
      id: widget.id,
      name: widget.name,
      desc: widget.desc,
      imageUrl: widget.imageUrl,
      price: 0,
      category: widget.category, // <-- 3. TAMBAHKAN NILAI CATEGORY DI SINI
    );
    FavoriteService.toggleFavorite(fragrance);
  }

  @override
  Widget build(BuildContext context) {
    // Sisa kode build method tidak perlu diubah
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(fragranceId: widget.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Hero(
              tag: 'fragrance-image-${widget.id}',
              child: Image.network(
                widget.imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.desc,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red.shade400 : Colors.white,
                  size: 28,
                ),
                onPressed: _handleToggleFavorite,
                style: IconButton.styleFrom(
                  iconSize: 28,
                  shadowColor: Colors.black54,
                  elevation: 4
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}