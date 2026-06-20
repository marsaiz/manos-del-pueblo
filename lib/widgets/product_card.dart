import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final List<Artisan> artisans;

  const ProductCard({super.key, required this.product, required this.artisans});

  @override
  Widget build(BuildContext context) {
    // --- LOGICA DE FAVORITOS ---
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(product.id);
    // ---------------------------

    final artisan = artisans.firstWhere(
      (a) => a.id == product.artisanId,
      orElse: () => artisans.first,
    );
    final nombreArtesano = artisan.nombre;

    return Semantics(
      label: 'Producto: ${product.nombre}, por $nombreArtesano, precio: ${double.tryParse(product.precio) != null ? '\$${product.precio}' : product.precio}. Toca para ver detalle.',
      button: true,
      explicitChildNodes: true,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          // focusColor visible para navegación por teclado (WCAG 2.4.7)
          focusColor: const Color(0xFF5D4037).withValues(alpha: 0.15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(product: product, artisan: artisan),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[100],
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: (product.imagePaths.isNotEmpty)
                          ? (product.imagePaths.first.startsWith('http')
                                ? Image.network(
                                    product.imagePaths.first,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  )
                                : Image.asset(
                                    product.imagePaths.first,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ))
                          : Container(color: Colors.grey[300]),
                    ),
                  ),

                  // --- INDICADOR DE MÚLTIPLES FOTOS ---
                  if (product.imagePaths.length > 1)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.collections,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.imagePaths.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              // Badge decorativo: no escala para no romper layout
                              textScaler: TextScaler.noScaling,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- BOTÓN DE FAVORITOS (CORAZÓN) ---
                  Positioned(
                    top: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      radius: 16,
                      child: Semantics(
                        label: isFav
                            ? 'Quitar ${product.nombre} de favoritos'
                            : 'Agregar ${product.nombre} a favoritos',
                        button: true,
                        // Foco independiente de la card padre
                        excludeSemantics: false,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            favoritesProvider.toggleFavorite(product.id);
                          },
                        ),
                      ),
                    ),
                  ),

                  // ------------------------------------
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.categoria,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        // Badge decorativo: no escala para no romper layout
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nombreArtesano,
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    double.tryParse(product.precio) != null
                        ? '\$${product.precio}'
                        : product.precio,
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // Column (InkWell child)
        ), // InkWell
      ), // Card
    ); // Semantics
  }
}
