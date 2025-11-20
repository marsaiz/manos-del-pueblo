import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../data/database.dart';
import 'home_screen.dart'; // Para reusar ProductCard

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en favoritos
    final favoriteIds = Provider.of<FavoritesProvider>(context).favorites;
    
    // Filtramos la lista global buscando solo los que están marcados
    final favoriteProducts = globalProducts
        .where((prod) => favoriteIds.contains(prod.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Favoritos ❤️")),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Aún no tienes favoritos"),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: favoriteProducts[index]);
              },
            ),
    );
  }
}