import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/database.dart';
import 'artisan_profile_screen.dart'; 
import 'package:share_plus/share_plus.dart'; // <--- IMPORTAR ESTO ARRIBA DEL ARCHIVO

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _foundProducts = [];
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
        final nombreArtesano = getArtisanById(product.artisanId).nombre.toLowerCase();
        return product.nombre.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
            product.categoria.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
            nombreArtesano.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    setState(() {
      _foundProducts = results;
      _filtroActivo = 'Búsqueda';
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
        _filtroActivo = artisanId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- MENÚ LATERAL (DRAWER) ---
      drawer: Drawer(
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
                child: Icon(Icons.storefront, color: Color(0xFF5D4037), size: 35),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nuestros Artesanos",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            // Lista dinámica del menú
            ...globalArtisans.map(
              (artisan) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(artisan.fotoPerfil),
                ),
                title: Text(artisan.nombre),
                subtitle: Text(artisan.ubicacion),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context); // Cerrar menú
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtisanProfileScreen(artisan: artisan),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Sobre Nosotros"),
              onTap: () {},
            ),
          ],
        ),
      ),
      
      appBar: AppBar(title: const Text('Manos del Pueblo')),
      
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                labelText: 'Buscar artesanías...',
                hintText: 'Ej: Mate, Decoración...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          // 2. CARRUSEL DE ARTESANOS
          SizedBox(
            height: 110,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: globalArtisans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildArtisanAvatar(
                    id: 'all',
                    nombre: 'Todos',
                    imagePath: null,
                    isActive: _filtroActivo == 'Todos',
                  );
                }
                final artisan = globalArtisans[index - 1];
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
            child: _foundProducts.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _foundProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                backgroundImage: imagePath != null ? AssetImage(imagePath) : null,
                child: imagePath == null
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

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final nombreArtesano = getArtisanById(product.artisanId).nombre;

    return GestureDetector(
      onTap: () {
        // NAVEGACIÓN AL DETALLE
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(product: product),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.categoria,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  const ProductDetail({super.key, required this.product});

  // Función para compartir
  void _shareProduct() {
    // Creamos un texto bonito para compartir
    final String mensaje = 
        "¡Mira esta artesanía de ${getArtisanById(product.artisanId).nombre}!\n\n"
        "*${product.nombre}* - \$${product.precio.toStringAsFixed(0)}\n\n"
        "Ver más aquí: https://manos-del-pueblo.ar";
    
    // Lanzamos el menú nativo de compartir del celular
    Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final artisan = getArtisanById(product.artisanId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        actions: [
          // --- NUEVO BOTÓN DE COMPARTIR ---
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
              child: Image.asset(product.imagePath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (El resto de tu código de detalle sigue igual: Precio, Chip del Artesano, etc)
                  Text(
                    '\$${product.precio.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text("Creado por: ", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundImage: AssetImage(artisan.fotoPerfil),
                        ),
                        label: Text(artisan.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.brown[50],
                        side: BorderSide.none,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtisanProfileScreen(artisan: artisan),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Historia del producto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtisanProfileScreen(artisan: artisan),
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