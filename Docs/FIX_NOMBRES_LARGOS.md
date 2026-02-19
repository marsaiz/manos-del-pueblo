# 🔧 Fix: Nombres Largos en AppBar y Botones Tapados

## Problemas Identificados

### 1. Nombres largos en AppBar
Cuando un nombre de producto o artesano es muy largo, se desbordaba en el AppBar causando que el texto se saliera de la barra amarilla/negra.

### 2. Botón tapado por navegación de Android
El botón "Visitar Tienda del Artesano" quedaba tapado por los botones de navegación de Android en la parte inferior de la pantalla.

## ✅ Soluciones Implementadas

### 1. ProductDetail (lib/screens/home_screen.dart)

**Antes:**
```dart
appBar: AppBar(
  title: Text(widget.product.nombre),
  // ...
)
```

**Después:**
```dart
appBar: AppBar(
  title: Text(
    widget.product.nombre,
    maxLines: 2,              // Permite hasta 2 líneas
    overflow: TextOverflow.ellipsis,  // Agrega "..." si es muy largo
  ),
  // ...
)
```

### 2. ArtisanProfileScreen (lib/screens/artisan_profile_screen.dart)

**Antes:**
```dart
SliverAppBar(
  flexibleSpace: FlexibleSpaceBar(
    title: Text(
      artisan.nombre,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
      ),
    ),
    // ...
  ),
)
```

**Después:**
```dart
SliverAppBar(
  flexibleSpace: FlexibleSpaceBar(
    title: Text(
      artisan.nombre,
      maxLines: 2,                    // Permite hasta 2 líneas
      overflow: TextOverflow.ellipsis, // Agrega "..." si es muy largo
      textAlign: TextAlign.center,     // Centra el texto
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,                  // Tamaño reducido para mejor ajuste
        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
      ),
    ),
    // ...
  ),
)
```

## 📱 Comportamiento

### Nombres Cortos
- Se muestran normalmente en una línea
- No hay cambios visuales

### Nombres Medios
- Se ajustan a 2 líneas si es necesario
- Mantienen legibilidad

### Nombres Muy Largos
- Se muestran en 2 líneas
- Si aún no caben, se truncan con "..."
- Ejemplo: "Artesanía de Cuero Hecha a Mano con Técnicas Tradicionales..." 

## 🎨 Mejoras Adicionales

### ProductDetail
- `maxLines: 2` - Permite títulos de hasta 2 líneas
- `overflow: TextOverflow.ellipsis` - Trunca con puntos suspensivos

### ArtisanProfileScreen
- `maxLines: 2` - Permite nombres de hasta 2 líneas
- `overflow: TextOverflow.ellipsis` - Trunca con puntos suspensivos
- `textAlign: TextAlign.center` - Centra el texto para mejor estética
- `fontSize: 16` - Reduce ligeramente el tamaño para mejor ajuste

## 📊 Archivos Modificados

1. `lib/screens/home_screen.dart` 
   - ProductDetail AppBar (fix nombres largos)
   - Agregado padding al final (fix botón tapado)
2. `lib/screens/artisan_profile_screen.dart` - SliverAppBar del perfil (fix nombres largos)

## 🔧 Fix 2: Botón Tapado por Navegación de Android

### Problema
El botón "Visitar Tienda del Artesano" quedaba tapado por los botones de navegación de Android (atrás, home, recientes) en la parte inferior de la pantalla.

### Solución

**Antes:**
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () { /* ... */ },
    icon: const Icon(Icons.storefront),
    label: const Text("Visitar Tienda del Artesano"),
    // ...
  ),
),
// ❌ Sin espacio adicional - botón tapado
],
```

**Después:**
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () { /* ... */ },
    icon: const Icon(Icons.storefront),
    label: const Text("Visitar Tienda del Artesano"),
    // ...
  ),
),
// ✅ Espacio adicional para evitar que los botones de navegación tapen el contenido
const SizedBox(height: 80),
],
```

### Resultado
- ✅ El botón ahora es completamente visible
- ✅ Hay espacio suficiente para hacer scroll
- ✅ No interfiere con los botones de navegación de Android
- ✅ Mejor experiencia de usuario en dispositivos Android

## 📊 Archivos Modificados (Actualizado)

1. `lib/screens/home_screen.dart` 
   - ProductDetail AppBar (fix nombres largos)
   - Agregado `SizedBox(height: 80)` al final (fix botón tapado)
2. `lib/screens/artisan_profile_screen.dart` - SliverAppBar del perfil (fix nombres largos)

## ✨ Resultado

### Fix 1: Nombres Largos
- ✅ Los nombres largos ya no se desbordan
- ✅ Se mantiene la legibilidad
- ✅ Mejor experiencia de usuario
- ✅ Funciona en todos los tamaños de pantalla
- ✅ Compatible con Android e iOS

### Fix 2: Botón Tapado
- ✅ El botón "Visitar Tienda" es completamente visible
- ✅ No interfiere con los botones de navegación de Android
- ✅ Espacio suficiente para hacer scroll
- ✅ Mejor accesibilidad

## 🧪 Casos de Prueba

### Fix 1: Nombres Largos

#### Caso 1: Nombre Corto
- Entrada: "Mate de Madera"
- Resultado: Se muestra en 1 línea, sin cambios

#### Caso 2: Nombre Medio
- Entrada: "Artesanía de Cuero Hecha a Mano"
- Resultado: Se muestra en 2 líneas completas

#### Caso 3: Nombre Muy Largo
- Entrada: "Artesanía de Cuero Hecha a Mano con Técnicas Tradicionales Argentinas del Siglo XIX"
- Resultado: "Artesanía de Cuero Hecha a Mano con Técnicas Tradicionales..."

### Fix 2: Botón Tapado

#### Caso 1: Pantalla con Scroll
- Acción: Hacer scroll hasta el final de la pantalla de producto
- Resultado: El botón "Visitar Tienda" es completamente visible

#### Caso 2: Dispositivo Android
- Acción: Abrir producto en dispositivo Android con botones de navegación
- Resultado: El botón no queda tapado por los botones de navegación

## 💡 Recomendaciones

Si en el futuro necesitas aplicar el mismo fix a otros AppBars:

```dart
AppBar(
  title: Text(
    tuTextoVariable,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
)
```

O para SliverAppBar:

```dart
SliverAppBar(
  flexibleSpace: FlexibleSpaceBar(
    title: Text(
      tuTextoVariable,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
  ),
)
```

## 🔍 Verificación

### Fix 1: Nombres Largos
1. Crea un producto con nombre muy largo
2. Selecciona el producto desde el home
3. Verifica que el título se ajusta correctamente en el AppBar
4. Haz lo mismo con un artesano de nombre largo

### Fix 2: Botón Tapado
1. Abre cualquier producto desde el home
2. Haz scroll hasta el final de la pantalla
3. Verifica que el botón "Visitar Tienda del Artesano" es completamente visible
4. Verifica que no queda tapado por los botones de navegación de Android

## 💡 Recomendaciones Futuras

### Para evitar botones tapados en otras pantallas:

Siempre agrega padding al final de formularios o listas largas:

```dart
Column(
  children: [
    // ... tu contenido ...
    
    ElevatedButton(
      onPressed: () {},
      child: Text('Tu Botón'),
    ),
    
    // ✅ Agregar espacio al final
    const SizedBox(height: 80),
  ],
)
```

### Nota sobre los formularios existentes:
Los formularios de administración (`add_product_screen.dart`, `edit_product_screen.dart`, `add_artisan_screen.dart`) ya tienen `SizedBox(height: 40)` al final, lo cual es suficiente porque están dentro de un `SingleChildScrollView` con padding.

¡Listo! 🎉
