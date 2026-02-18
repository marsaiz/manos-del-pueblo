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
import 'admin/edit_product_screen.dart';
import '../widgets/app_drawer.dart';

enum SortMethod { random, alphabetical }

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

  // Control de ordenamiento
  SortMethod _currentSort = SortMethod.random;
  List<String> _shuffledProductIds = [];

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

    // 1. Aplicamos filtros básicos
    final filtered = allProducts.where((product) {
      final artisan = allArtisans.firstWhere(
        (a) => a.id == product.artisanId,
        orElse: () => allArtisans.first,
      );

      final matchesArtisan =
          _filtroActivo == 'Todos' ||
          _filtroActivo == 'Búsqueda' ||
          product.artisanId == _filtroActivo;

      final matchesLocation =
          _localidadSeleccionada == 'Todas' ||
          artisan.localidad.trim().toLowerCase() ==
              _localidadSeleccionada.trim().toLowerCase();

      bool matchesText = true;
      if (_searchText.isNotEmpty) {
        final query = _searchText.trim().toLowerCase();
        matchesText =
            product.nombre.toLowerCase().contains(query) ||
            product.categoria.toLowerCase().contains(query) ||
            artisan.nombre.toLowerCase().contains(query) ||
            artisan.localidad.toLowerCase().contains(query);
      }

      return matchesArtisan && matchesLocation && matchesText;
    }).toList();

    // 2. Aplicamos el ordenamiento seleccionado
    if (_currentSort == SortMethod.alphabetical) {
      filtered.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    } else {
      // Orden aleatorio persistente durante la sesión
      if (_shuffledProductIds.isEmpty && allProducts.isNotEmpty) {
        final ids = allProducts.map((p) => p.id).toList()..shuffle();
        _shuffledProductIds = ids;
      }

      // Ordenamos según el orden aleatorio generado
      filtered.sort((a, b) {
        int indexA = _shuffledProductIds.indexOf(a.id);
        int indexB = _shuffledProductIds.indexOf(b.id);
        // Si un ID no está (producto nuevo), va al final
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA.compareTo(indexB);
      });
    }

    return filtered;
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
          IconButton(
            icon: Icon(
              _currentSort == SortMethod.random
                  ? Icons.shuffle
                  : Icons.sort_by_alpha,
            ),
            tooltip: _currentSort == SortMethod.random
                ? 'Orden: Aleatorio'
                : 'Orden: Alfabético',
            onPressed: () {
              setState(() {
                _currentSort = _currentSort == SortMethod.random
                    ? SortMethod.alphabetical
                    : SortMethod.random;
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const AppDrawer(),
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
                            // Obtenemos localidades únicas, normalizadas para el set pero mostradas como están
                            ...artisans
                                .map((a) => a.localidad.trim())
                                .where((l) => l.isNotEmpty)
                                .toSet(),
                          ].map((location) {
                            final isSelected =
                                _localidadSeleccionada.toLowerCase() ==
                                location.toLowerCase();
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
                                    // Guardamos la localidad seleccionada
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
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
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
                backgroundColor: Colors.grey[100],
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
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
        ),
      ),
    );
  }
}

// --- PANTALLA DE DETALLE (ProductDetail) ---
class ProductDetail extends StatefulWidget {
  final Product product;
  final Artisan artisan;

  const ProductDetail({
    super.key,
    required this.product,
    required this.artisan,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Función para compartir
  void _shareProduct() async {
    final String mensaje =
        "¡Mira esta artesanía de ${widget.artisan.nombre}!\n\n"
        "*${widget.product.nombre}* - ${double.tryParse(widget.product.precio) != null ? '\$${widget.product.precio}' : widget.product.precio}\n\n"
        "Ver más aquí: https://manos-del-pueblo.ar";

    await Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Botón de editar
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar producto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProductScreen(product: widget.product),
                ),
              );
            },
          ),
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
            // --- CARRUSEL DE IMÁGENES CON ZOOM ---
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: widget.product.imagePaths.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: widget.product.imagePaths.length,
                          itemBuilder: (context, index) {
                            final path = widget.product.imagePaths[index];
                            return InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 3.0,
                              child: Hero(
                                tag: index == 0
                                    ? 'product_image_${widget.product.id}'
                                    : 'product_image_${widget.product.id}_$index',
                                child: (path.startsWith('http'))
                                    ? Image.network(path, fit: BoxFit.contain)
                                    : Image.asset(path, fit: BoxFit.contain),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Indicadores de página
                if (widget.product.imagePaths.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.imagePaths.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.brown
                                : Colors.brown.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Botones de navegación (opcional, para visual)
                if (widget.product.imagePaths.length > 1)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage > 0)
                            IconButton(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.brown,
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                          if (_currentPage <
                              widget.product.imagePaths.length - 1)
                            IconButton(
                              onPressed: () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.brown,
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    double.tryParse(widget.product.precio) != null
                        ? '\$${widget.product.precio}'
                        : widget.product.precio,
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
                              (widget.artisan.fotoPerfil.startsWith('http'))
                              ? NetworkImage(widget.artisan.fotoPerfil)
                              : AssetImage(widget.artisan.fotoPerfil)
                                    as ImageProvider,
                        ),
                        label: Text(
                          widget.artisan.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.brown[50],
                        side: BorderSide.none,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArtisanProfileScreen(artisan: widget.artisan),
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
                    widget.product.descripcion,
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
                                ArtisanProfileScreen(artisan: widget.artisan),
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
                  // Espacio adicional para evitar que los botones de navegación de Android tapen el contenido
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
