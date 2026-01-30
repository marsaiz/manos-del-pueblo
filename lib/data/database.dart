import '../models/artisan.dart';
import '../models/product.dart';

// ****************************************************
// ESTE ARCHIVO FUE GENERADO AUTOMÁTICAMENTE POR PYTHON
// NO LO EDITES MANUALMENTE, EDITA LOS .CSV
// ****************************************************

// --- LISTA DE ARTESANOS ---
final List<Artisan> globalArtisans = [
  Artisan(
    id: 'a1',
    nombre: 'Don José Maderas',
    historia: 'Carpintero de tercera generación.',
    fotoPerfil: 'assets/images/mate.jpeg',
    telefono: '3511111111',
    whatsapp: '5493511111111',
    ubicacion: 'Taller del Norte',
    direccion: 'Av. del Carmen 450',
    localidad: 'Villa Allende',
    codigoPostal: '5105',
    provincia: 'Córdoba',
    instagram: 'donjose_maderas',
    facebook: '',
  ),
  Artisan(
    id: 'a2',
    nombre: 'Ana Tejidos',
    historia: 'Tejidos con lana natural y tintes.',
    fotoPerfil: 'assets/images/bufanda.jpeg',
    telefono: '3512222222',
    whatsapp: '5493512222222',
    ubicacion: 'Calle de las Artes',
    direccion: 'San Martín 120',
    localidad: 'Jesús María',
    codigoPostal: '5220',
    provincia: 'Córdoba',
    instagram: 'ana_tejidos',
    facebook: '',
  ),
  Artisan(
    id: 'a3',
    nombre: 'Luz Natural',
    historia: 'Velas de soja aromáticas.',
    fotoPerfil: 'assets/images/vela.jpeg',
    telefono: '3513333333',
    whatsapp: '5493513333333',
    ubicacion: 'Feria del Río',
    direccion: 'Belgrano 880',
    localidad: 'Córdoba Capital',
    codigoPostal: '5000',
    provincia: 'Córdoba',
    instagram: 'luz_natural',
    facebook: '',
  ),
  Artisan(
    id: 'a4',
    nombre: 'Tejidos del Valle',
    historia: 'Amigurumis y muñecos de apego.',
    fotoPerfil: 'assets/images/zorro.jpeg',
    telefono: '3514444444',
    whatsapp: '5493514444444',
    ubicacion: 'Centro Cultural',
    direccion: 'Pueyrredón s/n',
    localidad: 'La Cumbre',
    codigoPostal: '5174',
    provincia: 'Córdoba',
    instagram: 'tejidos_del_valle',
    facebook: '',
  ),
  Artisan(
    id: 'a5',
    nombre: 'Barro & Fuego',
    historia: 'Cerámica horneada a leña.',
    fotoPerfil: 'assets/images/Cuenco.jpeg',
    telefono: '3515555555',
    whatsapp: '5493515555555',
    ubicacion: 'Camino Real',
    direccion: 'Ruta 17 km 12',
    localidad: 'San Marcos Sierras',
    codigoPostal: '5282',
    provincia: 'Córdoba',
    instagram: 'barro_y_fuego',
    facebook: '',
  ),

  Artisan(
    id: 'a6',
    nombre: 'Cmtc Artesanias',
    historia: 'Artisanias en Madera',
    fotoPerfil: '',
    telefono: '+2302467992',
    whatsapp: '+5490230215467992',
    ubicacion: '',
    direccion: '25 de Mayo',
    localidad: 'Eduardo Castex',
    codigoPostal: '6380',
    provincia: 'La Pampa',
    instagram: '',
    facebook: '',
  ),
];

// --- LISTA DE PRODUCTOS ---
final List<Product> globalProducts = [
  Product(
    id: 'p1',
    artisanId: 'a3',
    nombre: 'Vela de Soja y Miel',
    descripcion: 'Vela ecológica con pabilo de madera.',
    precio: '4500',
    imagePath: 'assets/images/vela.jpeg',
    categoria: 'Decoración',
  ),
  Product(
    id: 'p2',
    artisanId: 'a4',
    nombre: 'Zorro Amigurumi',
    descripcion: 'Muñeco tejido para apego.',
    precio: '8200',
    imagePath: 'assets/images/zorro.jpeg',
    categoria: 'Juguetes',
  ),
  Product(
    id: 'p3',
    artisanId: 'a1',
    nombre: 'Mate de Algarrobo',
    descripcion: 'Mate bocón curado.',
    precio: '6000',
    imagePath: 'assets/images/mate.jpeg',
    categoria: 'Hogar',
  ),
  Product(
    id: 'p4',
    artisanId: 'a5',
    nombre: 'Cuenco de Cerámica',
    descripcion: 'Esmaltado a mano.',
    precio: '3800',
    imagePath: 'assets/images/Cuenco.jpeg',
    categoria: 'Cocina',
  ),
  Product(
    id: 'p5',
    artisanId: 'a2',
    nombre: 'Bufanda Nórdica',
    descripcion: 'Lana merino súper abrigada.',
    precio: '9500',
    imagePath: 'assets/images/bufanda.jpeg',
    categoria: 'Indumentaria',
  ),
];

// --- FUNCIONES DE AYUDA ---
Artisan getArtisanById(String id) {
  return globalArtisans.firstWhere(
    (artisan) => artisan.id == id,
    orElse: () => globalArtisans.first,
  );
}

List<Product> getProductsByArtisan(String artisanId) {
  return globalProducts.where((prod) => prod.artisanId == artisanId).toList();
}
