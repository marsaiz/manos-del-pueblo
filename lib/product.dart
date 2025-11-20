// --- MODELO DE DATOS ---
class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String nombreDelArtesano;
  final String imageUrl; // Volvemos a usar imageUrl (Web)

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.nombreDelArtesano,
    required this.imageUrl,
  });
}

// --- DATOS DE EJEMPLO CON FOTOS REALES DE INTERNET ---
final List<Product> mockProducts = [
  Product(
    id: '1',
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera que crepita al arder. Aroma intenso.',
    precio: 4500.0,
    nombreDelArtesano: 'Luz Natural',
    imageUrl: 'https://images.unsplash.com/photo-1603006905003-be475563bc59?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '2',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego, hecho con hilo de algodón suave.',
    precio: 8200.0,
    nombreDelArtesano: 'Tejidos del Valle',
    imageUrl: 'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '3',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón de madera curada con detalle de virola cincelada.',
    precio: 6000.0,
    nombreDelArtesano: 'Don José Maderas',
    imageUrl: 'https://images.unsplash.com/photo-1616438401189-2f8a0f589758?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: '4',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Ideal para sopas o cereales. Esmaltado a mano en horno de leña.',
    precio: 3800.0,
    nombreDelArtesano: 'Barro & Fuego',
    imageUrl: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
  ),
   Product(
    id: '5',
    nombre: 'Bufanda Nórdica',
    descripcion: 'Tejida en dos agujas con lana merino súper abrigada.',
    precio: 9500.0,
    nombreDelArtesano: 'Ana Tejidos',
    imageUrl: 'https://images.unsplash.com/photo-1607366402464-c0802d24251e?auto=format&fit=crop&w=600&q=80',
  ),
];