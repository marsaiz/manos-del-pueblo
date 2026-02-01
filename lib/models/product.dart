class Product {
  final String id;
  final String artisanId;
  final String nombre;
  final String descripcion;
  final String precio;
  final List<String> imagePaths; // Cambiado de String a List<String>
  final String categoria;

  Product({
    required this.id,
    required this.artisanId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagePaths,
    required this.categoria,
  });

  // Getter para compatibilidad con código que use imagePath
  String get imagePath => imagePaths.isNotEmpty ? imagePaths.first : '';
}
