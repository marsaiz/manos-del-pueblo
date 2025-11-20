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
      // TEMA: Versión simplificada para compatibilidad
      theme: ThemeData(
        primarySwatch: Colors.brown, // Color base compatible con versiones viejas
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige suave
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // Eliminamos la configuración compleja de CardTheme para evitar el error
      ),
      home: const ArtesaniasHome(),
    );
  }
}

// --- MODELO DE DATOS ---
class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String nombreDelArtesano;
  final String imageUrl; 

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.nombreDelArtesano,
    required this.imageUrl,
  });
}

// --- DATOS DE EJEMPLO ---
final List<Product> mockProducts = [
  Product(
    id: '1',
    nombre: 'Vela de Soja y Lavanda',
    descripcion: 'Vela aromática ecológica vertida a mano en frasco de vidrio reutilizable.',
    precio: 4500.0,
    nombreDelArtesano: 'Clara Velas',
    imageUrl: 'https://images.unsplash.com/photo-1602825489113-656d09143776?auto=format&fit=crop&w=500&q=60',
  ),
  Product(
    id: '2',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido al crochet con hilo de algodón hipoalergénico.',
    precio: 8200.0,
    nombreDelArtesano: 'Tejidos del Valle',
    imageUrl: 'https://images.unsplash.com/photo-1559438653-64869c80cb32?auto=format&fit=crop&w=500&q=60',
  ),
  Product(
    id: '3',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate torneado en madera de algarrobo con virola de aluminio.',
    precio: 6000.0,
    nombreDelArtesano: 'Carpintería Don José',
    imageUrl: 'https://images.unsplash.com/photo-1587585563431-b7c746393d1c?auto=format&fit=crop&w=500&q=60',
  ),
  Product(
    id: '4',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Cuenco esmaltado a mano, apto para microondas y lavavajillas.',
    precio: 3800.0,
    nombreDelArtesano: 'Barro & Fuego',
    imageUrl: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=500&q=60',
  ),
   Product(
    id: '5',
    nombre: 'Bufanda de Lana',
    descripcion: 'Bufanda tejida en telar con lana de oveja natural.',
    precio: 9500.0,
    nombreDelArtesano: 'Telares Andinos',
    imageUrl: 'https://images.unsplash.com/photo-1606299362296-54b281a64445?auto=format&fit=crop&w=500&q=60',
  ),
];

// --- PANTALLA PRINCIPAL ---
class ArtesaniasHome extends StatelessWidget {
  const ArtesaniasHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manos del Pueblo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: mockProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            childAspectRatio: 0.70, // Ajustado para evitar desbordamiento
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = mockProducts[index];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}

// --- TARJETA DE PRODUCTO ---
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: product.id,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

// --- DETALLE ---
class ProductDetail extends StatelessWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product.id,
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
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
                    child: ElevatedButton.icon( // Usamos ElevatedButton clásico
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Función de contacto próximamente!')),
                        );
                      },
                      // CAMBIO: Usamos Icons.message en lugar de Icons.whatsapp
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