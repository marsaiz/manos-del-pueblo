# Credenciales de Prueba para Google Play Console

## 📱 Información de la App
**Nombre:** Manos del Pueblo  
**Package:** ar.manosdelpueblo.app  
**Versión:** 1.0.1+2

---

## 🔐 PINs de Acceso Administrativo

La aplicación utiliza un sistema de PINs para proteger las funciones administrativas. A continuación se detallan los PINs necesarios para revisar todas las funcionalidades:

### PIN Principal - Acceso Administrativo
**PIN:** `4628`  
**Uso:** Acceso general a funciones de administración

**Cómo usar:**
1. Abrir el menú lateral (☰)
2. Ir a "Sobre Nosotros"
3. Tocar el ícono de candado (🔒)
4. Ingresar PIN: `4628`
5. Acceder a "Gestionar Artesanos"

---

### PIN de Gestión de Productos
**PIN:** `1234`  
**Uso:** Agregar, editar y eliminar productos y cursos

**Cómo usar:**
1. Desde cualquier producto, tocar el botón de editar (✏️)
2. Realizar cambios
3. Al guardar, se solicitará el PIN: `1234`

**O desde el menú:**
1. Menú lateral → "Añadir Producto"
2. Completar formulario
3. Ingresar PIN: `1234` al final

---

### PIN de Eliminación de Artesanos
**PIN:** `919345`  
**Uso:** Eliminar artesanos (operación destructiva)

**Cómo usar:**
1. Acceder a "Gestionar Artesanos" (con PIN `4628`)
2. En la pestaña "Lista", tocar el ícono de eliminar (🗑️) junto a un artesano
3. Ingresar PIN: `919345`

---

## 🎯 Funcionalidades a Revisar

### 1. Navegación General (Sin PIN)
- ✅ Ver catálogo de productos
- ✅ Filtrar por artesano
- ✅ Filtrar por localidad
- ✅ Buscar productos
- ✅ Ver perfil de artesano
- ✅ Agregar/quitar favoritos
- ✅ Compartir productos
- ✅ Ver cursos disponibles
- ✅ Contactar artesanos (WhatsApp, Instagram, Facebook)

### 2. Funciones Administrativas (Requieren PIN)

#### Con PIN `4628`:
- ✅ Acceder a panel de administración
- ✅ Ver lista de artesanos
- ✅ Agregar nuevo artesano
- ✅ Subir imágenes de artesanos
- ✅ Gestionar categorías de productos

#### Con PIN `1234`:
- ✅ Agregar nuevo producto
- ✅ Editar producto existente
- ✅ Eliminar producto
- ✅ Agregar nuevo curso
- ✅ Editar curso existente
- ✅ Eliminar curso

#### Con PIN `919345`:
- ✅ Eliminar artesano completo (incluye productos e imágenes)

---

## 📋 Flujo de Prueba Recomendado

### Paso 1: Exploración General (Sin PIN)
1. Abrir la app
2. Navegar por el catálogo de productos
3. Filtrar por diferentes artesanos
4. Ver perfil de un artesano
5. Agregar productos a favoritos
6. Ver la sección de cursos
7. Probar compartir un producto

### Paso 2: Acceso Administrativo (PIN: 4628)
1. Menú → "Sobre Nosotros"
2. Tocar el candado 🔒
3. Ingresar PIN: `4628`
4. Tocar "Gestionar Artesanos"
5. Explorar las 4 pestañas:
   - Lista de artesanos
   - Añadir artesano
   - Subir imágenes
   - Gestionar categorías

### Paso 3: Gestión de Productos (PIN: 1234)
1. Menú → "Añadir Producto"
2. Completar el formulario
3. Ingresar PIN: `1234`
4. Guardar producto
5. Editar el producto creado
6. Ingresar PIN: `1234` nuevamente

### Paso 4: Gestión de Cursos (PIN: 1234)
1. Ir a "Cursos"
2. Desde el panel de administración, gestionar cursos
3. Usar PIN: `1234` para operaciones

### Paso 5: Eliminación (PIN: 919345)
1. Acceder a "Gestionar Artesanos" (PIN: `4628`)
2. Intentar eliminar un artesano de prueba
3. Ingresar PIN: `919345`

---

## 🔒 Seguridad y Privacidad

### Datos de Prueba
- La app contiene datos reales de artesanos locales
- Los PINs proporcionados son solo para revisión de Google
- **IMPORTANTE:** Estos PINs se cambiarán después de la aprobación

### Permisos Requeridos
- **Internet:** Para cargar imágenes y datos desde Firebase
- **Almacenamiento:** Para compartir productos
- **ID de Publicidad:** Para analytics (declarado en manifest)

### Servicios Externos
- **Firebase Firestore:** Base de datos
- **Firebase Storage:** Almacenamiento de imágenes
- **Firebase Remote Config:** Configuración remota

---

## 📞 Contacto para Soporte

Si el equipo de revisión necesita asistencia adicional:

**Email:** contacto@manos-del-pueblo.ar  
**Respuesta:** Dentro de 24 horas

---

## ⚠️ Notas Importantes

1. **No eliminar artesanos reales:** Por favor, usar el PIN `919345` solo para verificar que funciona, pero no eliminar artesanos reales de la base de datos.

2. **Productos de prueba:** Pueden agregar productos de prueba con el PIN `1234` y eliminarlos después.

3. **Categorías:** Pueden ver y gestionar categorías, pero preferiblemente no eliminar las existentes.

4. **Imágenes:** Pueden subir imágenes de prueba, pero preferiblemente usar imágenes pequeñas.

---

## 🎨 Características Especiales

### Diseño Adaptativo
- Funciona en teléfonos y tablets
- Orientación vertical y horizontal
- SafeArea implementado para evitar overlaps con botones del sistema

### Accesibilidad
- Textos con overflow controlado
- Botones con tamaños táctiles adecuados
- Contraste de colores apropiado

### Rendimiento
- Carga lazy de imágenes
- Caché de datos
- Optimización de consultas a Firebase

---

**Fecha de creación:** 2026-02-20  
**Versión del documento:** 1.0
