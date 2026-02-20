# Sistema de Categorías Dinámicas

## 📋 Descripción

El sistema de categorías ahora se gestiona desde Firebase Firestore en lugar de estar hardcodeado en el código. Esto permite:

- ✅ Agregar nuevas categorías sin actualizar la app
- ✅ Editar nombres de categorías existentes
- ✅ Eliminar categorías que ya no se usan
- ✅ Reordenar categorías arrastrando y soltando
- ✅ Sincronización automática en todas las plataformas (web, Android, iOS)

## 🗄️ Estructura en Firestore

### Colección: `categories`

Cada documento tiene la siguiente estructura:

```json
{
  "id": "cat_1",
  "nombre": "Indumentaria",
  "orden": 1
}
```

**Campos:**
- `id` (string): Identificador único de la categoría
- `nombre` (string): Nombre visible de la categoría
- `orden` (number): Orden de visualización (menor número = aparece primero)

## 🚀 Inicialización

### Primera vez (Firestore vacío)

Si es la primera vez que usas el sistema, necesitas inicializar las categorías por defecto:

1. Abre la app
2. Ve a "Administrar Categorías" (desde el menú de administración)
3. Si no hay categorías, verás un botón "Inicializar Categorías por Defecto"
4. Haz clic en el botón

Esto creará las siguientes categorías:

1. Indumentaria
2. Herramientas
3. Juguetes
4. Hogar
5. Deco
6. Cocina
7. Alimentos
8. Bebidas
9. Utensilios
10. Joyería
11. Útiles Escolares
12. Jardinería
13. Instrumentos Musicales
14. Otros

### Desde código (alternativa)

También puedes inicializar las categorías desde código ejecutando:

```dart
await FirestoreService.initializeDefaultCategories();
```

## 🎯 Gestión de Categorías

### Acceder a la pantalla de administración

1. Abre el menú lateral (drawer)
2. Ve a "Sobre Nosotros"
3. Desbloquea el modo administrador con el PIN
4. Selecciona "Gestionar Artesanos"
5. Ve a la pestaña "Categorías" (cuarta pestaña)
6. Toca el botón "Abrir" para acceder a la gestión de categorías

### Agregar una categoría

1. En la pantalla "Administrar Categorías"
2. Toca el botón "+" en la barra superior
3. Ingresa el nombre de la nueva categoría
4. Toca "Agregar"

### Editar una categoría

1. Toca el ícono de editar (lápiz) junto a la categoría
2. Modifica el nombre
3. Toca "Guardar"

### Eliminar una categoría

1. Toca el ícono de eliminar (papelera) junto a la categoría
2. Ingresa el PIN de administrador
3. Confirma la eliminación

⚠️ **Advertencia:** Eliminar una categoría no afecta los productos existentes que la usan. Los productos mantendrán el nombre de la categoría eliminada.

### Reordenar categorías

1. Mantén presionado el ícono de arrastre (≡) junto a una categoría
2. Arrastra la categoría a la nueva posición
3. Suelta para guardar el nuevo orden

El orden se guarda automáticamente en Firestore.

## 💻 Uso en el código

### Obtener categorías

```dart
// Stream que se actualiza automáticamente
StreamBuilder<List<Category>>(
  stream: FirestoreService.getCategories(),
  builder: (context, snapshot) {
    final categories = snapshot.data ?? [];
    // Usar las categorías
  },
)
```

### Agregar categoría

```dart
final category = Category(
  id: 'cat_unique_id',
  nombre: 'Nueva Categoría',
  orden: 15,
);

await FirestoreService.addCategory(category);
```

### Actualizar categoría

```dart
final updatedCategory = Category(
  id: category.id,
  nombre: 'Nombre Actualizado',
  orden: category.orden,
);

await FirestoreService.updateCategory(updatedCategory);
```

### Eliminar categoría

```dart
await FirestoreService.deleteCategory(categoryId);
```

## 🔄 Migración desde categorías hardcodeadas

Las pantallas `add_product_screen.dart` y `edit_product_screen.dart` ahora cargan las categorías dinámicamente desde Firestore.

**Antes:**
```dart
final List<String> _categorias = [
  'Indumentaria',
  'Herramientas',
  // ...
];
```

**Ahora:**
```dart
List<String> _categorias = [];

void _loadCategories() {
  FirestoreService.getCategories().listen((categories) {
    setState(() {
      _categorias = categories.map((c) => c.nombre).toList();
      _categorias.add('Otro...'); // Opción personalizada
    });
  });
}
```

## 📱 Comportamiento en la app

### Al agregar/editar productos

- Las categorías se cargan automáticamente desde Firestore
- Se muestran en el orden definido
- Siempre incluye la opción "Otro..." para categorías personalizadas
- Si el usuario selecciona "Otro...", puede escribir una categoría personalizada

### Sincronización

- Los cambios en Firestore se reflejan inmediatamente en todas las instancias de la app
- No es necesario reiniciar la app para ver nuevas categorías
- Funciona en web, Android e iOS simultáneamente

## 🔒 Seguridad

- Solo los administradores con PIN pueden gestionar categorías
- Se requiere PIN de administrador para eliminar categorías
- Las operaciones se registran en los logs de Firestore

## 🐛 Solución de problemas

### Las categorías no aparecen

1. Verifica que Firestore esté configurado correctamente
2. Verifica que la colección `categories` exista
3. Ejecuta `initializeDefaultCategories()` para crear las categorías por defecto

### Error al cargar categorías

1. Verifica la conexión a internet
2. Verifica los permisos de Firestore
3. Revisa los logs de la consola para más detalles

### Categorías duplicadas

Si tienes categorías duplicadas, elimina las que no necesites desde la pantalla de administración.

## 📊 Reglas de Firestore recomendadas

```javascript
match /categories/{categoryId} {
  // Todos pueden leer categorías
  allow read: if true;
  
  // Solo administradores pueden escribir
  allow write: if request.auth != null && 
                  request.auth.token.admin == true;
}
```

---

**Fecha de implementación:** 2026-02-20
**Versión:** 1.0.2+
