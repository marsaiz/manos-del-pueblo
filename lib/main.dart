import 'package:flutter/material.dart';
// import 'product.dart'; // Si usas el archivo separado, descomenta esto. Si no, usa la clase abajo.

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
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
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

// --- CLASE PRODUCTO ---
class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String nombreDelArtesano;
  final String imagePath; // CAMBIO: Usamos ruta local

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.nombreDelArtesano,
    required this.imagePath,
  });
}

// --- DATOS LOCALES (Tus fotos en assets/images/) ---
final List<Product> mockProducts = [
  Product(
    id: '1',
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera.',
    precio: 4500.0,
    nombreDelArtesano: 'Luz Natural',
    imagePath: 'assets/images/vela.jpg', 
  ),
  Product(
    id: '2',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego.',
    precio: 8200.0,
    nombreDelArtesano: 'Tejidos del Valle',
    imagePath: 'assets/images/zorro.jpg',
  ),
  Product(
    id: '3',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón de madera curada.',
    precio: 6000.0,
    nombreDelArtesano: 'Don José Maderas',
    imagePath: 'assets/images/mate.jpg',
  ),
  Product(
    id: '4',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Esmaltado a mano en horno de leña.',
    precio: 3800.0,
    nombreDelArtesano: 'Barro & Fuego',
    imagePath: 'assets/images/cuenco.jpg',
  ),
   Product(
    id: '5',
    nombre: 'Bufanda Nórdica',
    descripcion: 'Tejida en dos agujas con lana merino.',
    precio: 9500.0,
    nombreDelArtesano: 'Ana Tejidos',
    imagePath: 'assets/images/bufanda.jpg',
  ),
];

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

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(product: product)));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // CAMBIO: Image.asset para cargar desde tu carpeta
              child: Image.asset(
                product.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Si te olvidas de subir una foto, muestra este icono
                  return Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        Text("Falta imagen", style: TextStyle(fontSize: 10)),
                      ],
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
                  Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  Text('\$${product.precio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetail extends StatelessWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.nombre)),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            // CAMBIO: Image.asset aquí también
            child: Image.asset(product.imagePath, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${product.precio.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown)),
                const SizedBox(height: 20),
                const Text("Historia del producto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(product.descripcion, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}