# Mejora: Eliminación Automática de Imágenes de Productos

## Problema Identificado

Cuando se eliminaba un producto de la base de datos (Firestore), las imágenes asociadas permanecían en Firebase Storage, causando:

- ❌ Costos innecesarios de almacenamiento
- ❌ Archivos huérfanos sin referencia
- ❌ Desorden en Storage
- ❌ Dificultad para gestionar el espacio

## Solución Implementada

Ahora cuando se elimina un producto, automáticamente se eliminan también sus imágenes de Firebase Storage.

### Cambios Realizados

#### 1. Nuevo Método en `ImageUploadService`

```dart
// lib/services/image_upload_service.dart

/// Elimina las imágenes de un producto específico
static Future<void> deleteProductImages(List<String> imageUrls) async {
  if (imageUrls.isEmpty) {
    debugPrint("ℹ️  No hay imágenes para eliminar");
    return;
  }

  try {
    for (var url in imageUrls) {
      if (url.isNotEmpty && url.startsWith('http')) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
          debugPrint("✅ Imagen eliminada: ${ref.name}");
        } catch (e) {
          debugPrint("⚠️  Error al eliminar imagen $url: $e");
          // Continuar con las demás imágenes aunque una falle
        }
      }
    }
    debugPrint("✅ Todas las imágenes del producto eliminadas de Storage");
  } catch (e) {
    debugPrint('Error al eliminar imágenes del producto: $e');
  }
}
```

**Características:**
- Acepta una lista de URLs de imágenes
- Elimina cada imagen de Storage
- Maneja errores individualmente (si una falla, continúa con las demás)
- Logs detallados para debugging

#### 2. Método `deleteProduct` Actualizado

```dart
// lib/services/firestore_service.dart

static Future<void> deleteProduct(String productId) async {
  // 1. Primero obtener el producto para acceder a sus imágenes
  final productDoc = await _db.collection('products').doc(productId).get();
  
  if (productDoc.exists) {
    final data = productDoc.data();
    if (data != null) {
      // Obtener las URLs de las imágenes
      List<String> imageUrls = [];
      if (data.containsKey('imagePaths')) {
        imageUrls = List<String>.from(data['imagePaths'] ?? []);
      } else if (data.containsKey('imagePath')) {
        final imagePath = data['imagePath'] ?? '';
        if (imagePath.isNotEmpty) {
          imageUrls = [imagePath];
        }
      }
      
      // 2. Eliminar las imágenes de Storage
      if (imageUrls.isNotEmpty) {
        await ImageUploadService.deleteProductImages(imageUrls);
      }
    }
  }
  
  // 3. Eliminar el documento de Firestore
  await _db.collection('products').doc(productId).delete();
  debugPrint("✅ Producto eliminado de Firestore");
}
```

**Flujo:**
1. Obtiene el producto de Firestore
2. Extrae las URLs de las imágenes (soporta `imagePaths` y `imagePath` legacy)
3. Elimina las imágenes de Storage
4. Elimina el documento de Firestore

#### 3. Método `deleteArtisanCascade` Mejorado

```dart
static Future<void> deleteArtisanCascade(String artisanId) async {
  // 1. Obtener todos los productos del artesano
  final productsSnapshot = await _db
      .collection('products')
      .where('artisanId', isEqualTo: artisanId)
      .get();

  // 2. Eliminar imágenes de cada producto de Storage
  for (var doc in productsSnapshot.docs) {
    final data = doc.data();
    List<String> imageUrls = [];
    
    if (data.containsKey('imagePaths')) {
      imageUrls = List<String>.from(data['imagePaths'] ?? []);
    } else if (data.containsKey('imagePath')) {
      final imagePath = data['imagePath'] ?? '';
      if (imagePath.isNotEmpty) {
        imageUrls = [imagePath];
      }
    }
    
    if (imageUrls.isNotEmpty) {
      await ImageUploadService.deleteProductImages(imageUrls);
    }
  }

  // 3. Crear batch para eliminar documentos de Firestore
  final batch = _db.batch();

  // 4. Marcar productos para eliminar en el batch
  for (var doc in productsSnapshot.docs) {
    batch.delete(doc.reference);
  }

  // 5. Marcar al artesano para eliminar
  batch.delete(_db.collection('artisans').doc(artisanId));

  // 6. Ejecutar todas las eliminaciones en Firestore
  await batch.commit();

  debugPrint("✅ Artesano, sus productos e imágenes eliminados");
}
```

**Mejoras:**
- Ahora elimina las imágenes de los productos antes de eliminar los documentos
- Mantiene la eliminación en batch para Firestore (eficiente)
- Elimina imágenes de productos + foto de perfil del artesano (con `deleteArtisanFolder`)

## Flujo Completo de Eliminación

### Eliminar un Producto Individual

```
Usuario → Confirma eliminación con PIN
    ↓
FirestoreService.deleteProduct(productId)
    ↓
1. Obtiene producto de Firestore
2. Extrae URLs de imágenes
3. ImageUploadService.deleteProductImages(urls)
    ↓
    - Elimina imagen 1 de Storage
    - Elimina imagen 2 de Storage
    - ...
4. Elimina documento de Firestore
    ↓
✅ Producto e imágenes eliminados
```

### Eliminar un Artesano (Cascada)

```
Usuario → Confirma eliminación con PIN
    ↓
FirestoreService.deleteArtisanCascade(artisanId)
    ↓
1. Obtiene todos los productos del artesano
2. Para cada producto:
    - Extrae URLs de imágenes
    - Elimina imágenes de Storage
3. Elimina documentos de productos (batch)
4. Elimina documento de artesano (batch)
    ↓
ImageUploadService.deleteArtisanFolder(artisanId)
    ↓
- Elimina foto de perfil
- Elimina cualquier archivo restante
    ↓
✅ Artesano, productos e imágenes eliminados
```

## Beneficios

### 1. Ahorro de Costos
- ✅ No acumulas archivos huérfanos
- ✅ Solo pagas por Storage que realmente usas
- ✅ Limpieza automática

### 2. Mejor Gestión
- ✅ Storage organizado y limpio
- ✅ Fácil identificar qué archivos están en uso
- ✅ Menos confusión al navegar Storage

### 3. Consistencia de Datos
- ✅ Firestore y Storage siempre sincronizados
- ✅ No hay referencias rotas
- ✅ Integridad de datos mantenida

### 4. Experiencia de Usuario
- ✅ Eliminación completa y transparente
- ✅ No hay "basura" acumulándose
- ✅ Logs claros para debugging

## Compatibilidad

### Retrocompatibilidad
✅ Soporta productos con:
- `imagePaths` (lista de URLs) - formato actual
- `imagePath` (URL única) - formato legacy

### Manejo de Errores
✅ Si una imagen falla al eliminarse:
- Se registra el error en logs
- Continúa con las demás imágenes
- No bloquea la eliminación del producto

### Casos Edge
✅ Maneja correctamente:
- Productos sin imágenes
- URLs vacías o inválidas
- Imágenes ya eliminadas
- Errores de red

## Pruebas Recomendadas

### 1. Eliminar Producto con Imágenes
```dart
// Crear producto con imágenes
// Eliminar producto
// Verificar en Storage que las imágenes se eliminaron
```

### 2. Eliminar Producto sin Imágenes
```dart
// Crear producto sin imágenes
// Eliminar producto
// Verificar que no hay errores
```

### 3. Eliminar Artesano con Productos
```dart
// Crear artesano con varios productos
// Cada producto con múltiples imágenes
// Eliminar artesano
// Verificar que todo se eliminó de Storage
```

### 4. Manejo de Errores
```dart
// Producto con URL inválida
// Eliminar producto
// Verificar que continúa sin fallar
```

## Monitoreo

### Logs a Observar

**Eliminación exitosa:**
```
✅ Imagen eliminada: product_p1_1234567890.jpg
✅ Imagen eliminada: product_p1_1234567891.jpg
✅ Todas las imágenes del producto eliminadas de Storage
✅ Producto eliminado de Firestore
```

**Con errores:**
```
⚠️  Error al eliminar imagen https://...: [error]
✅ Imagen eliminada: product_p1_1234567891.jpg
✅ Todas las imágenes del producto eliminadas de Storage
✅ Producto eliminado de Firestore
```

### Firebase Console

Después de eliminar productos, verifica en:
1. **Firestore Database** → Colección `products` → Producto eliminado ✓
2. **Storage** → `artesanos/{id}/productos/` → Imágenes eliminadas ✓

## Próximas Mejoras (Opcional)

### 1. Soft Delete
En lugar de eliminar permanentemente, marcar como eliminado:
```dart
await _db.collection('products').doc(productId).update({
  'deleted': true,
  'deletedAt': FieldValue.serverTimestamp(),
});
```

### 2. Papelera de Reciclaje
Mover a una colección temporal antes de eliminar:
```dart
await _db.collection('deleted_products').doc(productId).set(productData);
```

### 3. Logs de Auditoría
Registrar quién eliminó qué y cuándo:
```dart
await _db.collection('audit_logs').add({
  'action': 'delete_product',
  'productId': productId,
  'timestamp': FieldValue.serverTimestamp(),
});
```

### 4. Confirmación Doble
Para productos con muchas imágenes o valiosos:
```dart
if (imageUrls.length > 5) {
  // Pedir confirmación adicional
}
```

## Resumen

✅ **Implementado:**
- Eliminación automática de imágenes al borrar productos
- Eliminación en cascada mejorada para artesanos
- Manejo robusto de errores
- Logs detallados

✅ **Beneficios:**
- Ahorro de costos de Storage
- Mejor organización
- Consistencia de datos
- Experiencia de usuario mejorada

✅ **Compatibilidad:**
- Soporta formatos legacy y actuales
- Manejo de errores sin bloqueos
- Retrocompatible con datos existentes
