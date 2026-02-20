class Category {
  final String id;
  final String nombre;
  final int orden; // Para ordenar las categorías

  Category({
    required this.id,
    required this.nombre,
    required this.orden,
  });

  // Convertir desde Firestore
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      orden: map['orden'] ?? 0,
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'orden': orden,
    };
  }
}
