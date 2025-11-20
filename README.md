# 🎨 Manos del Pueblo

**Manos del Pueblo** es una plataforma digital diseñada para visibilizar y potenciar el trabajo de los artesanos locales. Funciona como un catálogo interactivo donde los usuarios pueden explorar productos únicos, conocer la historia de sus creadores y contactarlos directamente.

🌐 **Sitio Web Oficial:** [https://manos-del-pueblo.ar](https://manos-del-pueblo.ar)

---

## 🚀 Características

*   **Identidad Local:** Dominio `.ar` integrado para mayor confianza.
*   **Carrusel de Artesanos:** Navegación intuitiva tipo "Historias" para filtrar por creador.
*   **Buscador Inteligente:** Permite encontrar productos por nombre, categoría o artesano en tiempo real.
*   **Diseño Responsive:** Adaptado para funcionar perfecto en celulares y computadoras.
*   **Arquitectura Escalable:** Código organizado para permitir el crecimiento del inventario.

---

## 📂 Estructura del Proyecto

El proyecto está construido en **Flutter** y sigue una arquitectura limpia:

```text
manos-del-pueblo/
├── assets/
│   └── images/          # Fotos locales (productos y perfiles)
├── docs/                # Carpeta de distribución web (GitHub Pages)
├── lib/
│   ├── data/
│   │   └── database.dart    # Inventario: Lista de Artesanos y Productos
│   ├── models/
│   │   ├── artisan.dart     # Clase Artesano
│   │   └── product.dart     # Clase Producto
│   ├── screens/
│   │   └── home_screen.dart # Interfaz visual principal
│   └── main.dart            # Configuración inicial
└── pubspec.yaml         # Dependencias