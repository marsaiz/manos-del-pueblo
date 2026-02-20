# Instrucciones de Prueba para Google Play Console
## Manos del Pueblo - App de Artesanos

---

## 📱 INFORMACIÓN GENERAL

**Nombre de la App:** Manos del Pueblo  
**Versión:** 1.0.0  
**Plataformas:** Android, iOS, Web

---

## 🔐 CREDENCIALES DE ACCESO

### PINes de Administración

| Función | PIN | Uso |
|---------|-----|-----|
| **Acceso Administrativo** | `4628` | Acceso al panel de administración |
| **Gestión de Productos** | `1234` | Crear, editar productos |
| **Eliminar Artesano** | `919345` | Eliminar artesanos (acción destructiva) |

---

## 👨‍💼 PARTE 1: PRUEBAS COMO ADMINISTRADOR

### 1.1 Acceder al Panel de Administración

1. Abrir la app
2. Ir a la pestaña **"Sobre Nosotros"** (última pestaña)
3. Desplazarse hacia abajo hasta la sección **"Administración"**
4. Tocar **"Gestionar Artesanos"**
5. Ingresar PIN: **4628**
6. Tocar **"VERIFICAR"**

✅ **Resultado esperado:** Acceso al panel con 3 pestañas (Lista, Añadir, Categorías)

---

### 1.2 Crear un Nuevo Artesano

1. En el panel de administración, ir a la pestaña **"Añadir"**
2. Tocar el botón **"IR A FORMULARIO"**
3. Completar el formulario:
   - **Foto de perfil:** Tocar el círculo para subir una imagen
   - **Nombre:** Ej: "Juan Pérez"
   - **Historia:** Ej: "Artesano con 20 años de experiencia..."
   - **Teléfono:** Ej: "3512345678"
   - **WhatsApp:** Ej: "5493512345678"
   - **Dirección:** Ej: "Calle Falsa 123"
   - **Localidad:** Ej: "Villa Carlos Paz"
   - **Código Postal:** Ej: "5152"
   - **Provincia:** "Córdoba" (predeterminado)
   - **Instagram:** Ej: "juanperez_artesano"
   - **Facebook:** Ej: "juanperezartesano"
   - **Ubicación:** Coordenadas (opcional)
4. Tocar **"GUARDAR ARTESANO"**

✅ **Resultado esperado:** Artesano creado y visible en la pestaña "Lista"

---

### 1.3 Editar un Artesano Existente

1. Ir a la pestaña **"Lista"**
2. Buscar el artesano recién creado
3. Tocar el **ícono de lápiz azul** (editar)
4. Modificar algún campo (ej: cambiar el teléfono)
5. Opcionalmente, cambiar la foto de perfil
6. Tocar **"ACTUALIZAR ARTESANO"**
7. Ingresar PIN: **4628**
8. Tocar **"CONFIRMAR"**

✅ **Resultado esperado:** Cambios guardados correctamente

---

### 1.4 Eliminar un Artesano

1. En la pestaña **"Lista"**
2. Tocar el **ícono de basura rojo** (eliminar)
3. Leer el mensaje de confirmación
4. Ingresar PIN: **919345** (PIN especial para eliminación)
5. Tocar **"CONFIRMAR"**

✅ **Resultado esperado:** Artesano eliminado junto con todos sus productos e imágenes

---

### 1.5 Gestionar Categorías de Productos

1. En el panel de administración, ir a la pestaña **"Categorías"**
2. Tocar **"Abrir"**
3. Ver la lista de categorías existentes
4. **Para agregar una categoría:**
   - Tocar el botón **"+"** (abajo a la derecha)
   - Ingresar nombre: Ej: "Cerámica"
   - Tocar **"AGREGAR"**
5. **Para editar una categoría:**
   - Tocar el ícono de lápiz en la categoría
   - Modificar el nombre
   - Tocar **"GUARDAR"**
6. **Para eliminar una categoría:**
   - Tocar el ícono de basura
   - Confirmar la eliminación

✅ **Resultado esperado:** Categorías gestionadas correctamente

---

## 🎨 PARTE 2: PRUEBAS COMO ARTESANO

### 2.1 Acceder a la Gestión de Productos

1. Desde cualquier pantalla, tocar el **menú hamburguesa (☰)** (arriba a la izquierda)
2. Seleccionar **"Administrar Productos"**
3. Ingresar PIN: **1234**
4. Tocar **"VERIFICAR"**

---

### 2.2 Crear un Nuevo Producto

1. En la pantalla de administración de productos, tocar el botón **"+"** (abajo a la derecha)
2. Completar el formulario del producto:
   - **Artesano:** Seleccionar de la lista desplegable
   - **Fotos:** Tocar los 3 cuadros para subir hasta 3 imágenes
   - **Nombre:** Ej: "Poncho de lana"
   - **Descripción:** Ej: "Poncho tejido a mano con lana de oveja..."
   - **Precio:** Ej: "15000" o "Consultar"
   - **Categoría:** Seleccionar de la lista (ej: "Indumentaria")
3. Tocar **"GUARDAR PRODUCTO"**
4. Ingresar PIN: **1234**
5. Tocar **"CONFIRMAR"**

✅ **Resultado esperado:** Producto creado y visible en la lista

---

### 2.3 Editar un Producto Existente

1. En la lista de productos, tocar el **ícono de lápiz** del producto a editar
2. Modificar campos deseados:
   - Cambiar precio
   - Agregar/eliminar imágenes (tocar X en la imagen para eliminar)
   - Cambiar descripción
   - Cambiar categoría
3. Tocar **"ACTUALIZAR PRODUCTO"**
4. Ingresar PIN: **1234**
5. Tocar **"CONFIRMAR"**

✅ **Resultado esperado:** Producto actualizado correctamente

---

### 2.4 Eliminar un Producto

1. En la pantalla de edición del producto (seguir pasos 2.3 hasta el paso 2)
2. Desplazarse hasta el final
3. Tocar el botón rojo **"ELIMINAR PRODUCTO"**
4. Leer el mensaje de confirmación
5. Ingresar PIN: **1234**
6. Tocar **"CONFIRMAR"**

✅ **Resultado esperado:** Producto eliminado junto con todas sus imágenes

---

## 🔍 FUNCIONALIDADES ADICIONALES A PROBAR

### Búsqueda y Filtros
1. En la pantalla principal, usar la barra de búsqueda
2. Buscar por nombre de artesano o producto
3. Usar los filtros de categoría (botones horizontales)

### Favoritos
1. Tocar el ícono de corazón en cualquier producto
2. Ir a la pestaña **"Favoritos"**
3. Ver los productos marcados como favoritos
4. Tocar nuevamente el corazón para quitar de favoritos

### Compartir Producto
1. Abrir cualquier producto
2. Tocar el ícono de compartir (arriba a la derecha)
3. Seleccionar una app para compartir
4. Verificar que se comparte el nombre, precio y descripción

### Contacto con Artesano
1. En el perfil del artesano, tocar el botón de **WhatsApp**
2. Verificar que abre WhatsApp con mensaje predefinido
3. Tocar el botón de **Instagram**
4. Verificar que abre el perfil de Instagram
5. Tocar el botón de **Facebook**
6. Verificar que abre el perfil de Facebook

### Cursos
1. Ir a la pestaña **"Cursos"**
2. Ver la lista de cursos disponibles
3. Tocar un curso para ver detalles
4. Tocar el botón de WhatsApp para consultar

---

## ⚠️ NOTAS IMPORTANTES

### Seguridad
- Los PINes están almacenados en Firebase y pueden ser modificados
- La sesión de administrador dura 30 minutos
- Después de 30 minutos de inactividad, se solicitará el PIN nuevamente

### Imágenes
- Las imágenes se suben a Firebase Storage
- Al eliminar un producto/artesano, las imágenes se eliminan automáticamente
- Al cambiar una imagen, la anterior se elimina automáticamente
- Máximo 3 imágenes por producto

### Eliminación de Datos
- La eliminación de artesanos es en cascada (elimina productos e imágenes)
- La eliminación de productos elimina todas sus imágenes
- Estas acciones NO se pueden deshacer

### Categorías
- Las categorías son dinámicas y se gestionan desde Firebase
- Al crear/editar productos, se cargan las categorías disponibles
- Existe la opción "Otro..." para categorías personalizadas

---

## 📞 CONTACTO PARA SOPORTE

Si encuentran algún problema durante las pruebas, pueden contactar a:
- **Email:** contacto@manos-del-pueblo.ar
- **Descripción del problema:** Por favor incluir capturas de pantalla y pasos para reproducir

---

## ✅ CHECKLIST DE PRUEBAS

### Administración
- [ ] Acceder al panel de administración con PIN 4628
- [ ] Crear un nuevo artesano
- [ ] Editar un artesano existente
- [ ] Eliminar un artesano con PIN 919345
- [ ] Gestionar categorías (crear, editar, eliminar)

### Gestión de Productos
- [ ] Crear un producto con PIN 1234
- [ ] Subir 3 imágenes a un producto
- [ ] Editar un producto existente
- [ ] Eliminar imágenes de un producto
- [ ] Eliminar un producto completo

### Funcionalidades Generales
- [ ] Buscar artesanos y productos
- [ ] Filtrar por categoría
- [ ] Agregar/quitar favoritos
- [ ] Compartir producto
- [ ] Contactar artesano por WhatsApp
- [ ] Ver perfil de Instagram/Facebook
- [ ] Ver y consultar cursos

---

**Fecha de creación:** Febrero 2026  
**Versión del documento:** 1.0
