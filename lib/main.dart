import 'package:flutter/material.dart';
// IMPORTANTE: Asegúrate de que tu archivo se llame "product.dart"
import 'product.dart'; 

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

// --- DATOS DE EJEMPLO (Ahora con URLs reales de Internet) ---
final List<Product> mockProducts = [
  Product(
    id: '1',
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera que crepita al arder. Aroma intenso a miel silvestre.',
    precio: 4500.0,
    nombreDelArtesano: 'Luz Natural',
    imageUrl: 'https://images.unsplash.com/photo-1603006905003-be475563bc59?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '2',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego, hecho con hilo de algodón suave e hipoalergénico.',
    precio: 8200.0,
    nombreDelArtesano: 'Tejidos del Valle',
    imageUrl: 'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '3',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón de madera curada con detalle de virola de alpaca cincelada.',
    precio: 6000.0,
    nombreDelArtesano: 'Don José Maderas',
    imageUrl: 'https://images.unsplash.com/photo-1616438401189-2f8a0f589758?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '4',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Ideal para sopas o cereales. Esmaltado a mano en horno de leña. Pieza única.',
    precio: 3800.0,
    nombreDelArtesano: 'Barro & Fuego',
    imageUrl: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
  ),
   Product(
    id: '5',
    nombre: 'Bufanda Nórdica',
    descripcion: 'Tejida en dos agujas con lana merino súper abrigada. Color crudo natural.',
    precio: 9500.0,
    nombreDelArtesano: 'Ana Tejidos',
    imageUrl: 'https://images.unsplash.com/photo-1607366402464-c0802d24251e?auto=format&fit=crop&w=600&q=80',
  ),
];

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
              // CAMBIO: Usamos Image.network para las URLs
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image)),
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
            SizedBox(
              height: 300,
              width: double.infinity,
              // CAMBIO: Image.network aquí también
              child: Image.network(
                product.imageUrl, 
                fit: BoxFit.cover,
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Función de contacto próximamente!')),
                        );
                      },
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