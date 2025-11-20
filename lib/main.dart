import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manos del Pueblo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige suave
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ArtesaniasHome(),
    );
  }
}

// --- CLASE PRODUCT (La definimos aquí para evitar errores de importación) ---
class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String nombreDelArtesano;
  final String imagePath; 

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.nombreDelArtesano,
    required this.imagePath,
  });
}

// --- LISTA DE PRODUCTOS CORREGIDA (Extensiones .jpeg y mayúsculas) ---
final List<Product> mockProducts = [
  Product(
    id: '1',
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera que crepita al arder.',
    precio: 4500.0,
    nombreDelArtesano: 'Luz Natural',
    // CORREGIDO: .jpeg
    imagePath: 'assets/images/vela.jpeg', 
  ),
  Product(
    id: '2',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego, hilo de algodón suave.',
    precio: 8200.0,
    nombreDelArtesano: 'Tejidos del Valle',
    // CORREGIDO: .jpeg
    imagePath: 'assets/images/zorro.jpeg',
  ),
  Product(
    id: '3',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón de madera curada con virola cincelada.',
    precio: 6000.0,
    nombreDelArtesano: 'Don José Maderas',
    // CORREGIDO: .jpeg
    imagePath: 'assets/images/mate.jpeg',
  ),
  Product(
    id: '4',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Esmaltado a mano en horno de leña. Pieza única.',
    precio: 3800.0,
    nombreDelArtesano: 'Barro & Fuego',
    // CORREGIDO: C mayúscula y .jpeg (Tal como en tu captura)
    imagePath: 'assets/images/cuenco.jpeg', 
  ),
   Product(
    id: '5',
    nombre: 'Bufanda Nórdica',
    descripcion: 'Tejida en dos agujas con lana merino súper abrigada.',
    precio: 9500.0,
    nombreDelArtesano: 'Ana Tejidos',
    // CORREGIDO: .jpeg
    imagePath: 'assets/images/bufanda.jpeg',
  ),
];

// --- PANTALLA PRINCIPAL ---
class ArtesaniasHome extends StatelessWidget {
  const ArtesaniasHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manos del Pueblo')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: mockProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: mockProducts[index]);
          },
        ),
      ),
    );
  }
}

// --- TARJETA DEL PRODUCTO ---
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                product.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Si falla, muestra un aviso en rojo para que lo veas fácil
                  return Container(
                    color: Colors.red[100],
                    child: Center(
                      child: Text(
                        "Error:\n${product.imagePath}", 
                        textAlign: TextAlign.center, 
                        style: const TextStyle(fontSize: 10, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.nombreDelArtesano,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

// --- PANTALLA DE DETALLE ---
class ProductDetail extends StatelessWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.nombre)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.person, size: 18),
                        label: Text(product.nombreDelArtesano),
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
                      onPressed: () {},
                      icon: const Icon(Icons.message),
                      label: const Text("Contactar al Artesano"),
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