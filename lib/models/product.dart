class Product {
  final String id;
  final String artisanId; // NUEVO: El enlace con el artesano
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagePath;
  final String categoria;

  Product({
    required this.id,
    required this.artisanId, // Agregamos esto
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagePath,
    required this.categoria,
    // Borramos 'nombreDelArtesano' de aquí porque ya no hace falta
  });
}