# 🐍 Automatización de Carga de Datos (Sistema CMS)

Este documento explica cómo utilizar el sistema automático en Python para actualizar el catálogo de productos y artesanos sin necesidad de tocar el código Dart manualmente.

El sistema lee dos archivos **CSV** (que puedes editar en Excel) y genera automáticamente el archivo `lib/data/database.dart`.

---

## 1. Estructura de los Archivos de Datos

Crea estos dos archivos en la raíz del proyecto (junto al `pubspec.yaml`).

### 📄 Archivo: `artesanos.csv`
*Contiene la información de los creadores.*

    id,nombre,historia,fotoPerfil,telefono,whatsapp,ubicacion
    a1,Don José Maderas,Carpintero de tercera generación.,assets/images/mate.jpeg,3511111111,5493511111111,Taller del Norte
    a2,Ana Tejidos,Tejidos con lana natural y tintes.,assets/images/bufanda.jpeg,3512222222,5493512222222,Calle de las Artes
    a3,Luz Natural,Velas de soja aromáticas.,assets/images/vela.jpeg,3513333333,5493513333333,Feria del Río
    a4,Tejidos del Valle,Amigurumis y muñecos de apego.,assets/images/zorro.jpeg,3514444444,5493514444444,Centro Cultural
    a5,Barro & Fuego,Cerámica horneada a leña.,assets/images/Cuenco.jpeg,3515555555,5493515555555,Camino Real

### 📄 Archivo: `productos.csv`
*Contiene el catálogo de venta. Nota: El `artisanId` debe coincidir con un `id` del archivo de arriba.*

    id,artisanId,nombre,descripcion,precio,imagePath,categoria
    p1,a3,Vela de Soja y Miel,Vela ecológica con pabilo de madera.,4500.0,assets/images/vela.jpeg,Decoración
    p2,a4,Zorro Amigurumi,Muñeco tejido para apego.,8200.0,assets/images/zorro.jpeg,Juguetes
    p3,a1,Mate de Algarrobo,Mate bocón curado.,6000.0,assets/images/mate.jpeg,Hogar
    p4,a5,Cuenco de Cerámica,Esmaltado a mano.,3800.0,assets/images/Cuenco.jpeg,Cocina
    p5,a2,Bufanda Nórdica,Lana merino súper abrigada.,9500.0,assets/images/bufanda.jpeg,Indumentaria

---

## 2. El Script Automatizador (Python)

Crea un archivo llamado `generar_db.py` en la raíz del proyecto y pega este código completo:

    import csv
    import os

    # --- CONFIGURACIÓN ---
    ARCHIVO_ARTESANOS = 'artesanos.csv'
    ARCHIVO_PRODUCTOS = 'productos.csv'
    ARCHIVO_DESTINO = 'lib/data/database.dart'

    # --- PLANTILLAS DART ---
    HEADER = """import '../models/artisan.dart';
    import '../models/product.dart';

    // ****************************************************
    // ESTE ARCHIVO FUE GENERADO AUTOMÁTICAMENTE POR PYTHON
    // NO LO EDITES MANUALMENTE, EDITA LOS .CSV
    // ****************************************************

    // --- LISTA DE ARTESANOS ---
    final List<Artisan> globalArtisans = [
    """

    MIDDLE = """
    ];

    // --- LISTA DE PRODUCTOS ---
    final List<Product> globalProducts = [
    """

    FOOTER = """
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
        print("🚀 Iniciando generación de base de datos...")
        
        txt_artesanos = ""
        txt_productos = ""

        # 1. PROCESAR ARTESANOS
        try:
            with open(ARCHIVO_ARTESANOS, newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    txt_artesanos += f"""  Artisan(
        id: '{row['id']}',
        nombre: '{row['nombre']}',
        historia: '{row['historia']}',
        fotoPerfil: '{row['fotoPerfil']}',
        telefono: '{row['telefono']}',
        whatsapp: '{row['whatsapp']}',
        ubicacion: '{row['ubicacion']}',
      ),\\n"""
            print(f"✅ Artesanos leídos correctamente.")
        except Exception as e:
            print(f"❌ Error con artesanos: {e}")
            return

        # 2. PROCESAR PRODUCTOS
        try:
            with open(ARCHIVO_PRODUCTOS, newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    txt_productos += f"""  Product(
        id: '{row['id']}',
        artisanId: '{row['artisanId']}',
        nombre: '{row['nombre']}',
        descripcion: '{row['descripcion']}',
        precio: {row['precio']},
        imagePath: '{row['imagePath']}',
        categoria: '{row['categoria']}',
      ),\\n"""
            print(f"✅ Productos leídos correctamente.")
        except Exception as e:
            print(f"❌ Error con productos: {e}")
            return

        # 3. ESCRIBIR ARCHIVO FINAL
        full_content = HEADER + txt_artesanos + MIDDLE + txt_productos + FOOTER
        
        try:
            with open(ARCHIVO_DESTINO, 'w', encoding='utf-8') as f:
                f.write(full_content)
            print(f"🎉 ¡LISTO! Base de datos actualizada en: {ARCHIVO_DESTINO}")
        except Exception as e:
            print(f"❌ Error escribiendo archivo Dart: {e}")

    if __name__ == "__main__":
        generar_dart()

---

## 3. Flujo de Trabajo (Cómo usarlo)

Sigue estos pasos cada vez que quieras actualizar el catálogo:

1.  **Fotos:** Guarda las imágenes nuevas en la carpeta `assets/images/`.
2.  **Datos:** Abre `artesanos.csv` y `productos.csv`, agrega las filas nuevas y guarda.
3.  **Generar:** Ejecuta en la terminal:

        python3 generar_db.py

4.  **Publicar:** Ejecuta los comandos de despliegue web:

        flutter build web --base-href "/" --release
        rm -rf docs && mkdir docs && cp -r build/web/* docs/
        echo "manos-del-pueblo.ar" > docs/CNAME
        git add .
        git commit -m "Actualización de catálogo"
        git push