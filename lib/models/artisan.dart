class Artisan {
  final String id;
  final String nombre;
  final String historia; // Su biografía
  final String fotoPerfil; // Ruta de asset (ej: assets/images/jose.jpg)
  final String telefono;
  final String whatsapp; // Para el enlace directo
  final String ubicacion; // Ej: "Barrio Norte"

  Artisan({
    required this.id,
    required this.nombre,
    required this.historia,
    required this.fotoPerfil,
    required this.telefono,
    required this.whatsapp,
    required this.ubicacion,
  });
}