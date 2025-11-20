import csv
import os

# --- CONFIGURACIÓN ---
ARCHIVO_ARTESANOS = 'artesanos.csv'
ARCHIVO_PRODUCTOS = 'productos.csv'
ARCHIVO_DESTINO = 'lib/data/database.dart'

# --- PLANTILLA DEL ARCHIVO DART ---
# Esta es la estructura fija que no cambia
HEADER_DART = """import '../models/artisan.dart';
import '../models/product.dart';

// ****************************************************
// ESTE ARCHIVO FUE GENERADO AUTOMÁTICAMENTE POR PYTHON
// NO LO EDITES MANUALMENTE, EDITA LOS .CSV
// ****************************************************

// --- LISTA DE ARTESANOS ---
final List<Artisan> globalArtisans = [
"""

MIDDLE_DART = """
];

// --- LISTA DE PRODUCTOS ---
final List<Product> globalProducts = [
"""

FOOTER_DART = """
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
"""

def generar_dart():
    print("🚀 Iniciando generador de base de datos...")
    
    contenido_artesanos = ""
    contenido_productos = ""

    # 1. LEER ARTESANOS
    try:
        with open(ARCHIVO_ARTESANOS, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                contenido_artesanos += f"""  Artisan(
    id: '{row['id']}',
    nombre: '{row['nombre']}',
    historia: '{row['historia']}',
    fotoPerfil: '{row['fotoPerfil']}',
    telefono: '{row['telefono']}',
    whatsapp: '{row['whatsapp']}',
    ubicacion: '{row['ubicacion']}',
  ),\n"""
        print(f"✅ Artesanos procesados correctamente.")
    except FileNotFoundError:
        print(f"❌ ERROR: No encuentro el archivo {ARCHIVO_ARTESANOS}")
        return

    # 2. LEER PRODUCTOS
    try:
        with open(ARCHIVO_PRODUCTOS, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                contenido_productos += f"""  Product(
    id: '{row['id']}',
    artisanId: '{row['artisanId']}',
    nombre: '{row['nombre']}',
    descripcion: '{row['descripcion']}',
    precio: {row['precio']},
    imagePath: '{row['imagePath']}',
    categoria: '{row['categoria']}',
  ),\n"""
        print(f"✅ Productos procesados correctamente.")
    except FileNotFoundError:
        print(f"❌ ERROR: No encuentro el archivo {ARCHIVO_PRODUCTOS}")
        return

    # 3. ESCRIBIR ARCHIVO DART
    contenido_final = HEADER_DART + contenido_artesanos + MIDDLE_DART + contenido_productos + FOOTER_DART
    
    with open(ARCHIVO_DESTINO, 'w', encoding='utf-8') as f:
        f.write(contenido_final)
    
    print(f"🎉 ¡ÉXITO! Archivo {ARCHIVO_DESTINO} actualizado.")

if __name__ == "__main__":
    generar_dart()