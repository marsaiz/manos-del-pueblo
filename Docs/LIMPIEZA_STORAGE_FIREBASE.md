# Limpieza de Storage Firebase - Prevención de Archivos Huérfanos

## Resumen
Se implementó un sistema completo para prevenir archivos huérfanos en Firebase Storage, asegurando que todas las imágenes eliminadas o reemplazadas se borren correctamente del servidor.

## Problemas Identificados y Solucionados

### 1. Edición de Productos - Eliminación de Imágenes
**Problema:** Al editar un producto y eliminar una imagen, solo se quitaba la referencia en Firestore pero el archivo permanecía en Storage.

**Solución Implementada:**
- `edit_product_screen.dart`:
  - Método `_removeImage()` ahora elimina la imagen del Storage inmediatamente
  - Método `_performUpdate()` compara imágenes originales vs nuevas y elimina huérfanas
  - Doble protección: eliminación inmediata + limpieza al guardar

### 2. Creación de Productos - Eliminación de Imágenes
**Problema:** Al crear un producto, si subías una imagen y luego la eliminabas antes de guardar, quedaba huérfana en Storage.

**Solución Implementada:**
- `add_product_screen.dart`:
  - Método `_removeImage()` actualizado para eliminar del Storage
  - Funciona igual que en edición de productos

### 3. Edición de Cursos - Reemplazo de Imágenes
**Problema:** Al cambiar la imagen de un curso, la imagen anterior quedaba huérfana en Storage.

**Solución Implementada:**
- `add_edit_course_screen.dart`:
  - Método `_pickAndUploadImage()` ahora guarda la URL anterior
  - Después de subir la nueva imagen, elimina la anterior del Storage
  - Solo elimina si la URL anterior existe y es válida (http)

## Casos Ya Cubiertos (Funcionaban Correctamente)

### ✅ Eliminación de Productos
- `FirestoreService.deleteProduct()` obtiene las URLs de imágenes y las elimina del Storage
- Luego elimina el documento de Firestore

### ✅ Eliminación de Artesanos (Cascada)
- `FirestoreService.deleteArtisanCascade()` elimina:
  1. Todas las imágenes de todos los productos del artesano
  2. Todos los documentos de productos
  3. El documento del artesano
- `ImageUploadService.deleteArtisanFolder()` elimina toda la carpeta del artesano en Storage

### ✅ Eliminación de Cursos
- `FirestoreService.deleteCourse()` obtiene la URL de la imagen y la elimina del Storage
- Luego elimina el documento de Firestore

## Estructura de Archivos en Storage

```
storage/
├── artesanos/
│   ├── a1234567890/
│   │   ├── perfil/
│   │   │   └── profile_xxx.jpg
│   │   └── productos/
│   │       ├── p1234567890_0.jpg
│   │       ├── p1234567890_1.jpg
│   │       └── p1234567890_2.jpg
│   └── a9876543210/
│       └── ...
└── admin/
    └── productos/
        ├── course_1234567890.jpg
        └── course_9876543210.jpg
```

## Métodos de Limpieza Disponibles

### ImageUploadService

1. **deleteImage(String url)**
   - Elimina una imagen individual por URL
   - Usado para eliminar imágenes específicas

2. **deleteProductImages(List<String> imageUrls)**
   - Elimina múltiples imágenes de productos
   - Usado al eliminar productos o artesanos

3. **deleteArtisanFolder(String artisanId)**
   - Elimina toda la carpeta de un artesano
   - Incluye foto de perfil y todas las imágenes de productos

## Flujos de Eliminación

### Eliminar Imagen Individual (Edición)
```
Usuario toca X en imagen
    ↓
_removeImage(index)
    ↓
ImageUploadService.deleteImage(url)
    ↓
Archivo eliminado de Storage
    ↓
setState: _fotoUrls[index] = null
```

### Guardar Producto Editado
```
Usuario guarda producto
    ↓
_performUpdate()
    ↓
Compara imágenes originales vs nuevas
    ↓
Identifica URLs eliminadas
    ↓
ImageUploadService.deleteImage() para cada huérfana
    ↓
FirestoreService.updateProduct()
```

### Cambiar Imagen de Curso
```
Usuario selecciona nueva imagen
    ↓
_pickAndUploadImage()
    ↓
Guarda URL anterior
    ↓
Sube nueva imagen
    ↓
ImageUploadService.deleteImage(urlAnterior)
    ↓
Actualiza controlador con nueva URL
```

## Beneficios

1. **Ahorro de Espacio:** No se acumulan archivos no utilizados
2. **Costos Reducidos:** Menos almacenamiento = menos costos en Firebase
3. **Organización:** Storage limpio y organizado
4. **Rendimiento:** Menos archivos = búsquedas más rápidas
5. **Seguridad:** No quedan imágenes de productos/artesanos eliminados

## Testing Recomendado Antes de Producción

1. ✅ Crear producto con 3 imágenes → Eliminar 1 → Guardar → Verificar Storage
2. ✅ Crear producto con 2 imágenes → Eliminar ambas antes de guardar → Verificar Storage
3. ✅ Editar producto → Cambiar imagen 2 → Guardar → Verificar que la anterior se eliminó
4. ✅ Crear curso con imagen → Editar y cambiar imagen → Verificar que la anterior se eliminó
5. ✅ Eliminar producto completo → Verificar que todas sus imágenes se eliminaron
6. ✅ Eliminar artesano → Verificar que su carpeta completa se eliminó

## Notas Importantes

- Todas las eliminaciones incluyen manejo de errores con try-catch
- Se muestran mensajes informativos al usuario cuando hay problemas
- Los logs con debugPrint ayudan a rastrear operaciones en desarrollo
- La eliminación es permanente y no se puede deshacer
- Las operaciones funcionan en web, Android e iOS

## Fecha de Implementación
Febrero 2026 - Antes del lanzamiento en Google Play Store
