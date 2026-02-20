# Fix: Overflow en Dropdowns de Selección

## Problema Identificado

Al agregar o editar productos, aparecía una barra amarilla y negra (overflow warning) en los dropdowns de selección de artesano y categoría.

### Error en Consola
```
RenderFlex OVERFLOWING
The specific RenderFlex in question is: RenderFlex#a071e OVERFLOWING
creator: Row ← Padding ← SizedBox ← DefaultTextStyle ← _Decorator ← InputDecorator
```

### Causa
Los nombres de artesanos largos no cabían en el espacio disponible del dropdown, causando que el texto se desbordara.

## Solución Implementada

Se agregaron dos propiedades clave a todos los `DropdownButtonFormField`:

### 1. `isExpanded: true`
Permite que el dropdown use todo el ancho disponible del contenedor padre.

### 2. `overflow: TextOverflow.ellipsis` + `maxLines: 1`
Corta el texto largo con puntos suspensivos ("...") cuando no cabe.

## Archivos Modificados

### 1. `lib/screens/admin/add_product_screen.dart`

#### Dropdown de Artesano
```dart
// ANTES ❌
DropdownButtonFormField<String>(
  items: artisans.map((artisan) {
    return DropdownMenuItem<String>(
      value: artisan.id,
      child: Text(artisan.nombre), // ← Texto sin límite
    );
  }).toList(),
  // ...
)

// DESPUÉS ✅
DropdownButtonFormField<String>(
  isExpanded: true, // ← Usa todo el ancho disponible
  items: artisans.map((artisan) {
    return DropdownMenuItem<String>(
      value: artisan.id,
      child: Text(
        artisan.nombre,
        overflow: TextOverflow.ellipsis, // ← Corta con "..."
        maxLines: 1, // ← Una sola línea
      ),
    );
  }).toList(),
  // ...
)
```

#### Dropdown de Categoría
```dart
// ANTES ❌
DropdownButtonFormField<String>(
  items: [..._categorias, 'Otro...'].map((categoria) {
    return DropdownMenuItem<String>(
      value: categoria,
      child: Text(categoria), // ← Sin límite
    );
  }).toList(),
  // ...
)

// DESPUÉS ✅
DropdownButtonFormField<String>(
  isExpanded: true, // ← Usa todo el ancho
  items: [..._categorias, 'Otro...'].map((categoria) {
    return DropdownMenuItem<String>(
      value: categoria,
      child: Text(
        categoria,
        overflow: TextOverflow.ellipsis, // ← Corta con "..."
        maxLines: 1,
      ),
    );
  }).toList(),
  // ...
)
```

### 2. `lib/screens/admin/edit_product_screen.dart`

Se aplicaron los mismos cambios a los dropdowns de:
- Selección de artesano
- Selección de categoría

## Comportamiento Antes vs Después

### Antes ❌
```
┌─────────────────────────────┐
│ [👤] Artesano con nombre mu│y largo que no cabe
│      ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤  ← Overflow warning
└─────────────────────────────┘
```

### Después ✅
```
┌─────────────────────────────┐
│ [👤] Artesano con nombre... │ ← Texto cortado con ellipsis
│                             │
└─────────────────────────────┘
```

## Ejemplos de Nombres que Causaban Problema

- "Artesano con nombre muy largo de la localidad"
- "María Fernanda González Rodríguez"
- "Cooperativa de Artesanos Unidos del Pueblo"

Ahora todos se muestran correctamente:
- "Artesano con nombre muy lar..."
- "María Fernanda González R..."
- "Cooperativa de Artesanos U..."

## Beneficios

✅ **Sin warnings de overflow** - No más barras amarillas y negras
✅ **Mejor UX** - El texto se adapta al espacio disponible
✅ **Consistente** - Funciona con nombres de cualquier longitud
✅ **Legible** - Los puntos suspensivos indican que hay más texto

## Casos de Uso

### Nombres Cortos
```
Dropdown: [Juan Pérez ▼]
```
Se muestra completo, sin cambios.

### Nombres Medios
```
Dropdown: [María González Rodríguez ▼]
```
Se muestra completo si cabe, o con ellipsis si no.

### Nombres Largos
```
Dropdown: [Cooperativa de Artesanos... ▼]
```
Se corta con "..." para indicar que hay más texto.

### Al Abrir el Dropdown
```
┌─────────────────────────────────────┐
│ Cooperativa de Artesanos Unidos     │ ← Texto completo visible
│ del Pueblo de San Martín            │    en el menú desplegable
├─────────────────────────────────────┤
│ Juan Pérez                          │
│ María González                      │
└─────────────────────────────────────┘
```

## Propiedades Utilizadas

### `isExpanded: true`
- **Qué hace**: Permite que el dropdown ocupe todo el ancho del contenedor padre
- **Por qué**: Sin esto, el dropdown intenta ajustarse al contenido, causando overflow
- **Dónde**: En el `DropdownButtonFormField`

### `overflow: TextOverflow.ellipsis`
- **Qué hace**: Corta el texto con "..." cuando no cabe
- **Por qué**: Evita que el texto se desborde visualmente
- **Dónde**: En el `Text` dentro del `DropdownMenuItem`

### `maxLines: 1`
- **Qué hace**: Limita el texto a una sola línea
- **Por qué**: Mantiene la altura del dropdown consistente
- **Dónde**: En el `Text` dentro del `DropdownMenuItem`

## Testing

### Probar el Fix

1. **Ejecutar la app:**
   ```bash
   flutter run
   ```

2. **Ir a agregar producto:**
   - Menú → Administración → Añadir Producto

3. **Abrir dropdown de artesano:**
   - Verificar que no aparecen barras amarillas/negras
   - Verificar que nombres largos se cortan con "..."

4. **Seleccionar un artesano:**
   - Verificar que la selección funciona correctamente
   - Verificar que el nombre seleccionado se muestra (cortado si es necesario)

5. **Repetir con dropdown de categoría**

### Casos de Prueba

✅ Artesano con nombre corto (< 20 caracteres)
✅ Artesano con nombre medio (20-40 caracteres)
✅ Artesano con nombre largo (> 40 caracteres)
✅ Categoría estándar
✅ Categoría "Otro..." con texto personalizado

## Prevención Futura

Para evitar este problema en futuros dropdowns:

### Template de Dropdown
```dart
DropdownButtonFormField<String>(
  isExpanded: true, // ← SIEMPRE incluir
  decoration: InputDecoration(
    // ... decoración
  ),
  items: items.map((item) {
    return DropdownMenuItem<String>(
      value: item.id,
      child: Text(
        item.name,
        overflow: TextOverflow.ellipsis, // ← SIEMPRE incluir
        maxLines: 1, // ← SIEMPRE incluir
      ),
    );
  }).toList(),
  onChanged: (value) {
    // ... lógica
  },
)
```

### Checklist para Nuevos Dropdowns

- [ ] `isExpanded: true` en el `DropdownButtonFormField`
- [ ] `overflow: TextOverflow.ellipsis` en el `Text`
- [ ] `maxLines: 1` en el `Text`
- [ ] Probado con texto largo (> 40 caracteres)

## Otros Dropdowns en la App

Revisar si hay otros dropdowns que puedan tener el mismo problema:

```bash
# Buscar todos los DropdownButtonFormField
grep -r "DropdownButtonFormField" lib/
```

Si encuentras otros, aplicar el mismo fix.

## Recursos

- [Flutter DropdownButton Documentation](https://api.flutter.dev/flutter/material/DropdownButton-class.html)
- [TextOverflow Documentation](https://api.flutter.dev/flutter/painting/TextOverflow.html)
- [Handling Overflow in Flutter](https://docs.flutter.dev/ui/layout/constraints)

## Resumen

✅ **Problema**: Overflow en dropdowns con nombres largos
✅ **Solución**: `isExpanded: true` + `TextOverflow.ellipsis`
✅ **Archivos**: `add_product_screen.dart` y `edit_product_screen.dart`
✅ **Resultado**: Sin warnings, mejor UX, texto adaptativo
