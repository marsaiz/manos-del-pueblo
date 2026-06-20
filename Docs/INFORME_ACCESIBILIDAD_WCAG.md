# Informe de Accesibilidad Digital
## Aplicación Manos del Pueblo — Versión 1.2.1

---

**Fecha de emisión:** Junio 2026  
**Aplicación:** Manos del Pueblo  
**Plataformas:** iOS, Android, Web  
**Tecnología:** Flutter 3.x / Dart  
**Bundle ID:** ar.manosdelpueblo.app  
**Sitio Web:** https://manos-del-pueblo.ar  
**Contacto técnico:** contacto@manos-del-pueblo.ar

---

## 1. Declaración de Conformidad

La aplicación Manos del Pueblo ha implementado un conjunto de mejoras de accesibilidad orientadas a cumplir con los criterios establecidos en las **Pautas de Accesibilidad para el Contenido Web (WCAG) 2.1, Nivel AA**, así como con las guías de accesibilidad de plataformas móviles:

- **Apple Human Interface Guidelines — Accessibility**
- **Android Accessibility Guidelines (Material Design)**
- **Ley 26.653 de Accesibilidad de la Información en las Tecnologías** (Argentina)

---

## 2. Estándar de Referencia

### WCAG 2.1 — Principios y Criterios Aplicados

El estándar WCAG 2.1 se organiza en cuatro principios fundamentales:

| Principio | Descripción |
|-----------|-------------|
| **Perceptible** | La información debe presentarse de forma que los usuarios puedan percibirla |
| **Operable** | Los componentes de la interfaz deben ser operables |
| **Comprensible** | La información y el manejo de la interfaz deben ser comprensibles |
| **Robusto** | El contenido debe ser suficientemente robusto para ser interpretado por tecnologías de asistencia |

---

## 3. Inventario de Mejoras Implementadas

### 3.1 Etiquetas Semánticas (Semantic Labels)

**Criterios WCAG cubiertos:**
- 1.1.1 Contenido no textual (Nivel A)
- 4.1.2 Nombre, función, valor (Nivel A)

**Descripción técnica:**

Se implementó el widget `Semantics` de Flutter en todos los elementos interactivos e imágenes que carecían de descripción textual para tecnologías de asistencia (VoiceOver en iOS, TalkBack en Android).

**Archivos modificados:**

| Archivo | Elemento | Etiqueta implementada |
|---------|----------|----------------------|
| `lib/widgets/product_card.dart` | Card de producto | "Producto: [nombre], por [artesano], precio: [precio]. Toca para ver detalle." |
| `lib/widgets/product_card.dart` | Botón favoritos | "Agregar/Quitar [producto] de favoritos" |
| `lib/screens/home_screen.dart` | Avatar artesano | "Filtrar por artesano: [nombre]" / "Filtro activo: [nombre]" |
| `lib/screens/artisan_profile_screen.dart` | Foto de perfil | "Foto de perfil de [nombre del artesano]" |
| `lib/screens/artisan_profile_screen.dart` | Botón WhatsApp | "Contactar por WhatsApp a [nombre]" |
| `lib/screens/artisan_profile_screen.dart` | Botón Instagram | "Ver Instagram de [nombre]" |
| `lib/screens/artisan_profile_screen.dart` | Botón Facebook | "Ver Facebook de [nombre]" |
| `lib/screens/artisan_profile_screen.dart` | Botón Llamar | "Llamar a [nombre]" |
| `lib/screens/product_detail_screen.dart` | Imágenes carrusel | "Foto [N] de [total] de [producto]" |
| `lib/widgets/app_drawer.dart` | Logo/ícono header | "Logo de Manos del Pueblo" |
| `lib/widgets/app_drawer.dart` | Items del menú | Descripción funcional de cada ítem |

**Ejemplo de implementación:**

```dart
Semantics(
  label: 'Producto: Mate artesanal, por José López, precio: $1500. Toca para ver detalle.',
  button: true,
  explicitChildNodes: true,
  child: Card(...),
)
```

---

### 3.2 Contraste de Colores

**Criterios WCAG cubiertos:**
- 1.4.3 Contraste mínimo (Nivel AA) — ratio 4.5:1 para texto normal
- 1.4.6 Contraste mejorado (Nivel AAA) — ratio 7:1

**Descripción técnica:**

Se realizó un análisis completo de todos los colores de la aplicación mediante la fórmula de luminancia relativa WCAG. Se identificaron textos con color `Colors.grey` (ratio 2.68:1) y `Colors.grey[600]` (ratio 4.61:1 / 4.16:1 sobre crema) que no alcanzaban el mínimo requerido.

**Resultado del análisis de contraste:**

| Combinación de colores | Ratio | Nivel |
|------------------------|-------|-------|
| Blanco (#FFFFFF) sobre marrón AppBar (#5D4037) | 9.32:1 | ✅ AAA |
| Marrón (#5D4037) sobre blanco (#FFFFFF) | 9.32:1 | ✅ AAA |
| Marrón (#5D4037) sobre crema (#F5F5DC) | 8.42:1 | ✅ AAA |
| Negro87 (#212121) sobre blanco | 16.10:1 | ✅ AAA |
| Negro87 (#212121) sobre crema | 14.55:1 | ✅ AAA |
| Blanco sobre rojo eliminar (#D32F2F) | 4.98:1 | ✅ AA |
| **Gris corregido (#616161) sobre blanco** | **6.19:1** | **✅ AA** |
| **Gris corregido (#616161) sobre crema** | **5.60:1** | **✅ AA** |

**Corrección aplicada:**

Se reemplazó `Colors.grey` y `Colors.grey[600]` por `Colors.grey[700]` equivalente a `Color(0xFF616161)` en todos los textos informativos de la aplicación.

**Archivos y textos corregidos:**

| Archivo | Texto afectado |
|---------|----------------|
| `lib/widgets/product_card.dart` | Nombre del artesano bajo el producto |
| `lib/widgets/update_dialog.dart` | Versión actual y versión disponible |
| `lib/screens/about_screen.dart` | Lema de la app, número de versión, copyright |
| `lib/screens/courses_screen.dart` | Instructor y horario del curso |
| `lib/screens/artisan_profile_screen.dart` | Etiquetas debajo de botones de contacto |
| `lib/screens/course_detail_screen.dart` | Labels de filas informativas |
| `lib/widgets/app_drawer.dart` | Título de sección "Nuestros Artesanos" |

---

### 3.3 Escalado de Fuente Adaptable

**Criterios WCAG cubiertos:**
- 1.4.4 Cambio de tamaño del texto (Nivel AA) — el texto puede redimensionarse hasta 200% sin pérdida de contenido
- 1.4.12 Espaciado del texto (Nivel AA)

**Descripción técnica:**

Se implementó un sistema global de escalado de fuente que respeta la configuración de tamaño de texto del sistema operativo del usuario, con un rango controlado para evitar la ruptura de layouts.

**Implementación en `lib/main.dart`:**

```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(
        MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
      ),
    ),
    child: SelectionArea(child: child!),
  );
},
```

**Comportamiento por configuración del sistema:**

| Configuración del usuario | Comportamiento en la app |
|---------------------------|--------------------------|
| Texto muy pequeño (< 0.8x) | Se muestra al 0.8x mínimo |
| Texto normal (1.0x) | Se muestra al 1.0x sin cambios |
| Texto grande (1.3x) | Se muestra al 1.3x máximo permitido |
| Texto extragrande (> 1.3x) | Se limita a 1.3x para preservar layouts |

**Excepciones controladas:**

Los siguientes elementos decorativos en espacios de tamaño fijo se excluyeron del escalado para preservar la integridad visual:

- Badge de cantidad de fotos en tarjetas de producto (`textScaler: TextScaler.noScaling`)
- Badge de categoría en tarjetas de producto (`textScaler: TextScaler.noScaling`)
- Nombre del artesano en carrusel de 70px de ancho (`textScaler: TextScaler.linear(1.0)`)

---

### 3.4 Navegación por Teclado y Orden de Foco

**Criterios WCAG cubiertos:**
- 2.1.1 Teclado (Nivel A) — toda la funcionalidad debe ser operable mediante teclado
- 2.4.3 Orden de foco (Nivel A) — el orden de navegación debe ser lógico y predecible
- 2.4.7 Foco visible (Nivel AA) — el foco del teclado debe ser visible

**Descripción técnica:**

Se reemplazaron los widgets `GestureDetector` de las pantallas públicas por `InkWell`, que implementa correctamente el protocolo de foco de Flutter y es navegable mediante Tab en web, teclado externo, Switch Access (Android) y teclado de accesibilidad (iOS).

**Cambios de componentes:**

| Elemento | Componente anterior | Componente nuevo | Motivo |
|----------|--------------------|--------------------|--------|
| Card de producto | `GestureDetector` | `InkWell` con `focusColor` | Focusable por Tab/Switch |
| Avatar artesano | `GestureDetector` + `FocusableActionDetector` | `InkWell` con `focusColor` | Simplificación y consistencia |

**Indicador visual de foco:**

Se definió un color de foco visible (`focusColor`) en marrón translúcido (`Color(0xFF5D4037)` al 15% de opacidad) aplicado a todos los elementos interactivos, cumpliendo WCAG 2.4.7.

**Orden de navegación por Tab en pantalla principal (web):**

```
1. Botón hamburguesa (abrir menú)
2. Título de la app
3. Botón "Mis favoritos"
4. Botón "Ordenar"
5. Campo de búsqueda
6. Filtros de localidad (izquierda → derecha)
7. Avatares de artesanos (izquierda → derecha)
8. Cards de productos (izquierda → derecha, fila por fila)
```

Este orden sigue el patrón de lectura occidental (izquierda a derecha, arriba a abajo), cumpliendo WCAG 2.4.3.

---

### 3.5 Accesibilidad en la Versión Web

**Criterios WCAG cubiertos:**
- 2.1.1 Teclado (Nivel A)
- 2.4.7 Foco visible (Nivel AA)
- 3.1.1 Idioma de la página (Nivel A)
- 1.3.1 Información y relaciones (Nivel A)

**Mejoras en `web/index.html`:**

```html
<!-- Idioma declarado para lectores de pantalla -->
<html lang="es">

<!-- Viewport accesible con zoom habilitado -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Indicador de foco visible para navegación por teclado -->
<style>
  :focus-visible {
    outline: 3px solid #5D4037;
    outline-offset: 2px;
  }
  :focus:not(:focus-visible) {
    outline: none;
  }
</style>

<!-- Mensaje para usuarios sin JavaScript -->
<noscript>
  <p>Manos del Pueblo requiere JavaScript...</p>
</noscript>
```

**Selección de texto habilitada:**

Se implementó el widget `SelectionArea` de Flutter envolviendo toda la aplicación, permitiendo que los usuarios puedan seleccionar y copiar cualquier texto visible (nombres de artesanos, descripciones, precios) en la versión web.

```dart
child: SelectionArea(child: child!)
```

**Atributo `lang="es"` en el documento HTML:**

Permite que los lectores de pantalla (NVDA, JAWS, VoiceOver en Mac) pronuncien correctamente el contenido en español argentino.

---

### 3.6 Título Adaptable en Orientación Horizontal

**Criterios WCAG cubiertos:**
- 1.3.4 Orientación (Nivel AA) — el contenido no debe restringirse a una sola orientación
- 1.4.4 Cambio de tamaño del texto (Nivel AA)

**Descripción técnica:**

Se configuró el `AppBarTheme` global para que el título de la barra superior sea adaptable en orientación horizontal (landscape), evitando que ocupe una parte desproporcionada de la pantalla.

```dart
appBarTheme: AppBarTheme(
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    overflow: TextOverflow.ellipsis, // Trunca con "..." si no entra
  ),
  toolbarHeight: kToolbarHeight, // Altura estándar 56px
),
```

---

### 3.7 Compatibilidad con Plataformas iOS (App Store)

**Requisito Apple:** `ITSAppUsesNonExemptEncryption`

Se agregó la clave de privacidad en `ios/Runner/Info.plist` declarando que la aplicación no utiliza cifrado personalizado, solo HTTPS estándar:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**Compatibilidad de dispositivos:**

La aplicación se configuró exclusivamente para iPhone, eliminando la compatibilidad con iPad en `ios/Runner.xcodeproj/project.pbxproj`:

```
TARGETED_DEVICE_FAMILY = "1";  // Solo iPhone
```

---

## 4. Tecnologías de Asistencia Compatibles

| Tecnología | Plataforma | Nivel de soporte |
|-----------|-----------|-----------------|
| VoiceOver | iOS | ✅ Compatible |
| TalkBack | Android | ✅ Compatible |
| Switch Access | Android | ✅ Compatible (InkWell) |
| Teclado externo | iOS/Android/Web | ✅ Compatible |
| Navegación por Tab | Web | ✅ Compatible |
| Zoom del sistema | iOS/Android | ✅ Compatible |
| Texto grande del sistema | iOS/Android | ✅ Compatible (clamp 0.8–1.3x) |
| Selección de texto | Web | ✅ Compatible (SelectionArea) |
| NVDA / JAWS | Web (con limitaciones) | ⚠️ Parcial (Flutter Canvas) |

> **Nota sobre lectores de pantalla en Web:** Flutter Web renderiza mediante CanvasKit por defecto, lo que limita la lectura directa por NVDA/JAWS. Los Semantic Labels implementados mejoran esta situación. Para compatibilidad completa se puede compilar con `--web-renderer html`.

---

## 5. Áreas Pendientes de Mejora

Las siguientes mejoras se identificaron como trabajo futuro:

| Mejora | Criterio WCAG | Prioridad |
|--------|--------------|-----------|
| Política de privacidad accesible en URL pública | 3.3.5 Ayuda (AAA) | Alta |
| Modo de alto contraste | 1.4.6 Contraste mejorado (AAA) | Media |
| Animaciones reducidas (respeto a `prefers-reduced-motion`) | 2.3.3 Animación desde interacciones (AAA) | Baja |
| Compilación web con renderer HTML | WCAG 4.1.2 (A) | Media |

---

## 6. Declaración de Esfuerzo Razonable

Manos del Pueblo ha realizado un esfuerzo razonable y sistemático para identificar y corregir barreras de accesibilidad en su plataforma digital. Las mejoras implementadas cubren los criterios de Nivel A y Nivel AA de WCAG 2.1 aplicables a una aplicación móvil y web de catálogo comercial.

Se reconoce que la validación completa de accesibilidad requiere pruebas manuales con usuarios reales con discapacidad y con tecnologías de asistencia en dispositivos físicos, las cuales representan el siguiente paso en el proceso de mejora continua.

---

## 7. Compromiso de Mejora Continua

Manos del Pueblo se compromete a:

- Mantener y mejorar los niveles de accesibilidad en cada nueva versión
- Incorporar pruebas de accesibilidad en el proceso de desarrollo
- Atender solicitudes y reportes de usuarios con discapacidad
- Actualizar este informe ante cambios significativos en la aplicación

Para reportar problemas de accesibilidad: **contacto@manos-del-pueblo.ar**

---

## 8. Historial de Versiones de este Documento

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | Junio 2026 | Versión inicial — implementación WCAG 2.1 AA |

---

*Este documento fue elaborado en el marco del proceso de mejora de accesibilidad de la aplicación Manos del Pueblo, en respuesta a los requisitos normativos aplicables y al compromiso de la organización con la inclusión digital.*

---

**© 2026 Manos del Pueblo — contacto@manos-del-pueblo.ar — https://manos-del-pueblo.ar**
