import '../models/artisan.dart';
import '../models/product.dart';

// --- LISTA DE ARTESANOS (Creamos 5 perfiles) ---
final List<Artisan> globalArtisans = [
  Artisan(
    id: 'a1',
    nombre: 'Don José Maderas',
    historia: 'Tercera generación de carpinteros. Trabajo con maderas recuperadas del monte.',
    fotoPerfil: 'assets/images/mate.jpeg', // Usamos fotos de productos como perfil por ahora
    telefono: '3511111111',
    whatsapp: '5493511111111',
    ubicacion: 'Taller del Norte',
  ),
  Artisan(
    id: 'a2',
    nombre: 'Ana Tejidos',
    historia: 'Tejidos ancestrales con lana de oveja y tintes naturales de raíces y flores.',
    fotoPerfil: 'assets/images/bufanda.jpeg',
    telefono: '3512222222',
    whatsapp: '5493512222222',
    ubicacion: 'Calle de las Artes',
  ),
  Artisan(
    id: 'a3',
    nombre: 'Luz Natural',
    historia: 'Velas de soja volcadas a mano, inspiradas en los aromas de nuestras sierras.',
    fotoPerfil: 'assets/images/vela.jpeg',
    telefono: '3513333333',
    whatsapp: '5493513333333',
    ubicacion: 'Feria del Río',
  ),
  Artisan(
    id: 'a4',
    nombre: 'Tejidos del Valle',
    historia: 'Muñecos de apego (Amigurumis) hechos con algodón hipoalergénico y mucho amor.',
    fotoPerfil: 'assets/images/zorro.jpeg',
    telefono: '3514444444',
    whatsapp: '5493514444444',
    ubicacion: 'Centro Cultural',
  ),
  Artisan(
    id: 'a5',
    nombre: 'Barro & Fuego',
    historia: 'Cerámica horneada a leña. Cada pieza es única e irrepetible.',
    fotoPerfil: 'assets/images/Cuenco.jpeg',
    telefono: '3515555555',
    whatsapp: '5493515555555',
    ubicacion: 'Camino Real',
  ),
];

// --- LISTA DE PRODUCTOS COMPLETA (Con IDs y nombres de archivo corregidos) ---
final List<Product> globalProducts = [
  Product(
    id: 'p1',
    artisanId: 'a3', // Pertenece a Luz Natural
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera que crepita al arder.',
    precio: 4500.0,
    imagePath: 'assets/images/vela.jpeg', // Asegúrate que sea .jpeg
    categoria: 'Decoración',
  ),
  Product(
    id: 'p2',
    artisanId: 'a4', // Pertenece a Tejidos del Valle
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego, hilo de algodón suave.',
    precio: 8200.0,
    imagePath: 'assets/images/zorro.jpeg',
    categoria: 'Juguetes',
  ),
  Product(
    id: 'p3',
    artisanId: 'a1', // Pertenece a Don José
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón de madera curada con virola cincelada.',
    precio: 6000.0,
    imagePath: 'assets/images/mate.jpeg',
    categoria: 'Hogar',
  ),
  Product(
    id: 'p4',
    artisanId: 'a5', // Pertenece a Barro & Fuego
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Esmaltado a mano en horno de leña. Pieza única.',
    precio: 3800.0,
    imagePath: 'assets/images/Cuenco.jpeg', // C mayúscula
    categoria: 'Cocina',
  ),
  Product(
    id: 'p5',
    artisanId: 'a2', // Pertenece a Ana Tejidos
    nombre: 'Bufanda Nórdica',
    descripcion: 'Tejida en dos agujas con lana merino súper abrigada.',
    precio: 9500.0,
    imagePath: 'assets/images/bufanda.jpeg',
    categoria: 'Indumentaria',
  ),
];

// --- FUNCIONES DE AYUDA ---

// Busca al artesano por su ID. Si no lo encuentra, devuelve el primero para que no explote.
Artisan getArtisanById(String id) {
  return globalArtisans.firstWhere(
    (artisan) => artisan.id == id,
    orElse: () => globalArtisans.first, 
  );
}

// Busca los productos de un artesano
List<Product> getProductsByArtisan(String artisanId) {
  return globalProducts.where((prod) => prod.artisanId == artisanId).toList();
}