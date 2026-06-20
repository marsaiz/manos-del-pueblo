import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/artisan.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/adaptive_app_bar.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en favoritos
    final favoriteIds = Provider.of<FavoritesProvider>(context).favorites;

    return Scaffold(
      appBar: AdaptiveAppBar(title: const Text("Mis Favoritos")),
      body: StreamBuilder<List<Artisan>>(
        stream: FirestoreService.getArtisans(),
        builder: (context, artisanSnapshot) {
          if (!artisanSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final artisans = artisanSnapshot.data!;

          return StreamBuilder<List<Product>>(
            stream: FirestoreService.getProducts(),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final favoriteProducts = productSnapshot.data!
                  .where((prod) => favoriteIds.contains(prod.id))
                  .toList();

              if (favoriteProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Aún no tienes favoritos"),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: favoriteProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: favoriteProducts[index],
                    artisans: artisans,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
