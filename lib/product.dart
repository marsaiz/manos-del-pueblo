class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String nombreDelArtesano;
  final String imagePath; // CAMBIO: Ahora guardamos la ruta local (assets)

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.nombreDelArtesano,
    required this.imagePath,
  });
}