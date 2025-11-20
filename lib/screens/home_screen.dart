import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/artisan.dart'; // Asegúrate de tener este archivo
import '../data/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _foundProducts = [];
  // Variable para saber qué filtro está activo (para pintarlo de otro color)
  String _filtroActivo = 'Todos';

  @override
  void initState() {
    _foundProducts = globalProducts;
    super.initState();
  }

  // Filtro por TEXTO (Buscador)
  void _runFilter(String enteredKeyword) {
    List<Product> results = [];
    if (enteredKeyword.isEmpty) {
      results = globalProducts;
    } else {
      results = globalProducts.where((product) {
        final nombreArtesano = getArtisanById(
          product.artisanId,
        ).nombre.toLowerCase();
        return product.nombre.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ) ||
            product.categoria.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ) ||
            nombreArtesano.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    setState(() {
      _foundProducts = results;
      _filtroActivo = 'Búsqueda'; // Para desmarcar los avatares
    });
  }

  // Filtro por ARTESANO (Al tocar el avatar)
  void _filterByArtisan(String artisanId) {
    setState(() {
      if (artisanId == 'all') {
        _foundProducts = globalProducts;
        _filtroActivo = 'Todos';
      } else {
        _foundProducts = getProductsByArtisan(artisanId);
        _filtroActivo = artisanId; // Guardamos el ID del artesano activo
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manos del Pueblo')),
      body: Column(
        children: [
          // --- 1. BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                labelText: 'Buscar artesanías...',
                hintText: 'Ej: Mate, Decoración...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          // --- 2. CARRUSEL DE ARTESANOS (Estilo Historias) ---
          SizedBox(
            height: 110, // Altura fija para esta zona
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal, // Scroll horizontal
              // Sumamos 1 al total para incluir el botón "Todos" al principio
              itemCount: globalArtisans.length + 1,
              itemBuilder: (context, index) {
                // Lógica para el primer botón ("Todos")
                if (index == 0) {
                  return _buildArtisanAvatar(
                    id: 'all',
                    nombre: 'Todos',
                    imagePath: null, // Sin foto, usa icono
                    isActive: _filtroActivo == 'Todos',
                  );
                }

                // Lógica para los Artesanos
                final artisan = globalArtisans[index - 1];
                return _buildArtisanAvatar(
                  id: artisan.id,
                  nombre: artisan.nombre, // Nomvbre completo
                  imagePath: artisan.fotoPerfil,
                  isActive: _filtroActivo == artisan.id,
                );
              },
            ),
          ),

          const Divider(height: 1), // Una línea sutil de separación
          // --- 3. GRILLA DE PRODUCTOS ---
          Expanded(
            child: _foundProducts.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _foundProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: _foundProducts[index]);
                    },
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No hay productos aquí"),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET AUXILIAR: Para dibujar cada círculo del carrusel
  Widget _buildArtisanAvatar({
    required String id,
    required String nombre,
    String? imagePath,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _filterByArtisan(id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 70, // Ancho fijo para que el texto se acomode y no baile
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Alineado arriba
          children: [
            // El círculo con borde
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.brown : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: imagePath != null
                    ? AssetImage(imagePath)
                    : null,
                child: imagePath == null
                    ? const Icon(Icons.grid_view, color: Colors.brown)
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            // El nombre abajo (Ahora permite 2 líneas)
            Text(
              nombre,
              textAlign: TextAlign.center, // Centrado
              maxLines: 2, // Máximo 2 renglones
              overflow: TextOverflow.ellipsis, // Si es muuuuy largo pone "..."
              style: TextStyle(
                fontSize: 11, // Letra un pelín más chica para que entre mejor
                height: 1.1, // Espaciado entre renglones más ajustado
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.brown : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PRODUCT CARD (Igual que antes) ---
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final nombreArtesano = getArtisanById(product.artisanId).nombre;

    return GestureDetector(
      onTap: () {
        // Aquí iría la navegación al detalle
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.categoria,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                  Text(
                    nombreArtesano,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
