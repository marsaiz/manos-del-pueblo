import 'package:flutter/material.dart';

// Tus archivos locales
import '../models/product.dart';
import '../models/artisan.dart';
import 'favorites_screen.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/adaptive_app_bar.dart';

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
      // Orden equitativo y aleatorio persistente durante la sesión
      if (_shuffledProductIds.isEmpty && allProducts.isNotEmpty) {
        // 1. Agrupar productos por artesano
        final Map<String, List<Product>> productsByArtisan = {};
        for (final p in allProducts) {
          productsByArtisan.putIfAbsent(p.artisanId, () => []).add(p);
        }

        // 2. Mezclar los productos internamente para cada artesano
        for (final list in productsByArtisan.values) {
          list.shuffle();
        }

        final List<String> interleavedIds = [];
        bool addedAny = true;

        // 3. Repartir como cartas: uno de cada artesano por ronda
        while (addedAny) {
          addedAny = false;
          // Mezclar el orden de los artesanos en cada ronda para más aleatoriedad
          final artisanIds = productsByArtisan.keys.toList()..shuffle();

          for (final artisanId in artisanIds) {
            final list = productsByArtisan[artisanId]!;
            if (list.isNotEmpty) {
              interleavedIds.add(list.removeAt(0).id);
              addedAny = true;
            }
          }
        }
        
        _shuffledProductIds = interleavedIds;
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
      appBar: AdaptiveAppBar(
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

              return CustomScrollView(
                slivers: [
                  // 1. BARRA DE BÚSQUEDA Y FILTROS INTEGRADOS (Collapsible)
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false, // Evitar botón de menú duplicado
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 76.0,
                    expandedHeight: 241.0, // 76 (search) + 44 (loc) + 10 (espacio) + 110 (art) + 1 (div)
                    titleSpacing: 0,
                    title: Container(
                      height: 76.0,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      alignment: Alignment.center,
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
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. GRILLA DE PRODUCTOS
                  if (filteredProducts.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductCard(
                              product: filteredProducts[index],
                              artisans: artisans,
                            );
                          },
                          childCount: filteredProducts.length,
                        ),
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
    return Semantics(
      label: isActive
          ? 'Filtro activo: $nombre'
          : 'Filtrar por artesano: $nombre',
      button: true,
      child: InkWell(
        onTap: () {
          setState(() {
            _filtroActivo = id == 'all' ? 'Todos' : id;
          });
        },
        borderRadius: BorderRadius.circular(35),
        focusColor: const Color(0xFF5D4037).withValues(alpha: 0.15),
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
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.brown : Colors.black87,
                ),
              ),
            ],
        ),
        ), // InkWell
      ), // Semantics
    );
  }
}
