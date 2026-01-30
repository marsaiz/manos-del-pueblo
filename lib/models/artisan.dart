class Artisan {
  final String id;
  final String nombre;
  final String historia; // Su biografía
  final String fotoPerfil; // Ruta de asset (ej: assets/images/jose.jpg)
  final String telefono;
  final String whatsapp; // Para el enlace directo
  final String ubicacion; // Ej: "Barrio Norte"
  final String direccion;
  final String localidad;
  final String codigoPostal;
  final String provincia;
  final String instagram;
  final String facebook;

  Artisan({
    required this.id,
    required this.nombre,
    required this.historia,
    required this.fotoPerfil,
    required this.telefono,
    required this.whatsapp,
    required this.ubicacion,
    required this.direccion,
    required this.localidad,
    required this.codigoPostal,
    required this.provincia,
    required this.instagram,
    required this.facebook,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artisan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
