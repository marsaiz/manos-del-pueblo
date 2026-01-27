import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para manejar los favoritos
import 'package:share_plus/share_plus.dart'; // Para compartir

// Tus archivos locales
import '../providers/favorites_provider.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import 'artisan_profile_screen.dart';
import 'favorites_screen.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtroActivo = 'Todos';
  String _localidadSeleccionada = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
  }

  // Lógica central para aplicar todos los filtros (texto, artesano y localidad)
  List<Product> _getFilteredProducts(
    List<Product> allProducts,
    List<Artisan> allArtisans,
  ) {
    if (allArtisans.isEmpty) return [];

    return allProducts.where((product) {
      final artisan = allArtisans.firstWhere(
        (a) => a.id == product.artisanId,
        orElse: () => allArtisans.first,
      );

      // 1. Filtro por Artesano
      final matchesArtisan =
          _filtroActivo == 'Todos' ||
          _filtroActivo == 'Búsqueda' ||
          product.artisanId == _filtroActivo;

      // 2. Filtro por Localidad
      final matchesLocation =
          _localidadSeleccionada == 'Todas' ||
          artisan.localidad == _localidadSeleccionada;

      // 3. Filtro por Texto
      bool matchesText = true;
      if (_searchText.isNotEmpty) {
        final query = _searchText.toLowerCase();
        matchesText =
            product.nombre.toLowerCase().contains(query) ||
            product.categoria.toLowerCase().contains(query) ||
            artisan.nombre.toLowerCase().contains(query) ||
            artisan.localidad.toLowerCase().contains(query);
      }

      return matchesArtisan && matchesLocation && matchesText;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manos del Pueblo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Ver mis favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: StreamBuilder<List<Artisan>>(
        stream: FirestoreService.getArtisans(),
        builder: (context, snapshot) {
          final artisans = snapshot.data ?? [];
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF5D4037)),
                  accountName: Text(
                    "Manos del Pueblo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  accountEmail: Text("Catálogo de Artesanos Locales"),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.storefront,
                      color: Color(0xFF5D4037),
                      size: 35,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.brown),
                  title: const Text('Añadir Artesano'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add-artisan');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Sobre Nosotros"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                if (artisans.isNotEmpty) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Nuestros Artesanos",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...artisans.map(
                    (artisan) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (artisan.fotoPerfil.startsWith('http'))
                            ? NetworkImage(artisan.fotoPerfil)
                            : AssetImage(artisan.fotoPerfil) as ImageProvider,
                      ),
                      title: Text(artisan.nombre),
                      subtitle: Text(artisan.ubicacion),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtisanProfileScreen(artisan: artisan),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      body: StreamBuilder<List<Artisan>>(
        stream: FirestoreService.getArtisans(),
        builder: (context, artisanSnapshot) {
          return StreamBuilder<List<Product>>(
            stream: FirestoreService.getProducts(),
            builder: (context, productSnapshot) {
              if (artisanSnapshot.hasError || productSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error de conexión. Prueba sincronizar datos en el menú.",
                  ),
                );
              }
              if (!artisanSnapshot.hasData || !productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final artisans = artisanSnapshot.data!;
              final allProducts = productSnapshot.data!;

              if (artisans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("No hay datos cargados aún"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/about'),
                        child: const Text("Ir a Sincronizar"),
                      ),
                    ],
                  ),
                );
              }

              final filteredProducts = _getFilteredProducts(
                allProducts,
                artisans,
              );

              return Column(
                children: [
                  // 1. BARRA DE BÚSQUEDA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                          if (value.isNotEmpty) _filtroActivo = 'Búsqueda';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Buscar artesanías...',
                        hintText: 'Ej: Mate, Decoración, Córdoba...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  // 1.5 FILTRO DE LOCALIDADES
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children:
                          [
                            'Todas',
                            ...artisans.map((a) => a.localidad).toSet(),
                          ].map((location) {
                            final isSelected =
                                _localidadSeleccionada == location;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.brown,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _localidadSeleccionada = location;
                                  });
                                },
                                selectedColor: Colors.brown,
                                backgroundColor: Colors.brown[50],
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Colors.brown,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. CARRUSEL DE ARTESANOS
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: artisans.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildArtisanAvatar(
                            id: 'all',
                            nombre: 'Todos',
                            imagePath: null,
                            isActive: _filtroActivo == 'Todos',
                          );
                        }
                        final artisan = artisans[index - 1];
                        return _buildArtisanAvatar(
                          id: artisan.id,
                          nombre: artisan.nombre,
                          imagePath: artisan.fotoPerfil,
                          isActive: _filtroActivo == artisan.id,
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // 3. GRILLA DE PRODUCTOS
                  Expanded(
                    child: filteredProducts.isNotEmpty
                        ? GridView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.70,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: filteredProducts[index],
                                artisans: artisans,
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text("No hay productos aquí"),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildArtisanAvatar({
    required String id,
    required String nombre,
    String? imagePath,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroActivo = id == 'all' ? 'Todos' : id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                    ? (imagePath.startsWith('http')
                          ? NetworkImage(imagePath)
                          : AssetImage(imagePath) as ImageProvider)
                    : null,
                child: (imagePath == null || imagePath.isEmpty)
                    ? const Icon(Icons.grid_view, color: Colors.brown)
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.1,
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

// --- TARJETA DE PRODUCTO (ProductCard) ---
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetail(product: product, artisan: artisan),
          ),
        );
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
                    child: (product.imagePath.startsWith('http'))
                        ? Image.network(
                            product.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[300]),
                          )
                        : Image.asset(
                            product.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[300]),
                          ),
                  ),

                  // --- BOTÓN DE FAVORITOS (CORAZÓN) ---
                  Positioned(
                    top: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      radius: 16,
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

// --- PANTALLA DE DETALLE (ProductDetail) ---
class ProductDetail extends StatelessWidget {
  final Product product;
  final Artisan artisan;

  const ProductDetail({
    super.key,
    required this.product,
    required this.artisan,
  });

  // Función para compartir
  void _shareProduct() async {
    final String mensaje =
        "¡Mira esta artesanía de ${artisan.nombre}!\n\n"
        "*${product.nombre}* - \$${product.precio.toStringAsFixed(0)}\n\n"
        "Ver más aquí: https://manos-del-pueblo.ar";

    await Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        actions: [
          // Botón de compartir
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir con amigos',
            onPressed: _shareProduct,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: (product.imagePath.startsWith('http'))
                  ? Image.network(product.imagePath, fit: BoxFit.cover)
                  : Image.asset(product.imagePath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${product.precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text(
                        "Creado por: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundImage:
                              (artisan.fotoPerfil.startsWith('http'))
                              ? NetworkImage(artisan.fotoPerfil)
                              : AssetImage(artisan.fotoPerfil) as ImageProvider,
                        ),
                        label: Text(
                          artisan.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.brown[50],
                        side: BorderSide.none,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArtisanProfileScreen(artisan: artisan),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Historia del producto",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.descripcion,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtisanProfileScreen(artisan: artisan),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront),
                      label: const Text("Visitar Tienda del Artesano"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
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
