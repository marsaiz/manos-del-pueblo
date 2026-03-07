# Configurar Firebase Remote Config para Web

## 📋 Variables Agregadas

Se agregaron las siguientes variables para soporte Web:

```
manos_min_version_web: 1.2.1
manos_latest_version_web: 1.2.1
manos_web_url: https://manos-del-pueblo.ar
```

---

## 🔧 Configuración en Firebase Console

### Paso 1: Acceder a Remote Config

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto "Manos del Pueblo"
3. En el menú lateral, busca **Remote Config** (en la sección "Engage")
4. Haz clic en **Remote Config**

---

### Paso 2: Agregar Parámetros para Web

Debes agregar 3 nuevos parámetros:

#### **Parámetro 1: manos_min_version_web**

1. Haz clic en **"Agregar parámetro"** o **"Add parameter"**
2. Completa:
   - **Clave del parámetro**: `manos_min_version_web`
   - **Descripción**: `Versión mínima requerida para la app web`
   - **Tipo de datos**: String
   - **Valor predeterminado**: `1.2.1`
3. Haz clic en **Guardar**

---

#### **Parámetro 2: manos_latest_version_web**

1. Haz clic en **"Agregar parámetro"**
2. Completa:
   - **Clave del parámetro**: `manos_latest_version_web`
   - **Descripción**: `Última versión disponible de la app web`
   - **Tipo de datos**: String
   - **Valor predeterminado**: `1.2.1`
3. Haz clic en **Guardar**

---

#### **Parámetro 3: manos_web_url**

1. Haz clic en **"Agregar parámetro"**
2. Completa:
   - **Clave del parámetro**: `manos_web_url`
   - **Descripción**: `URL de la aplicación web`
   - **Tipo de datos**: String
   - **Valor predeterminado**: `https://manos-del-pueblo.ar`
3. Haz clic en **Guardar**

---

### Paso 3: Publicar Cambios

1. Después de agregar los 3 parámetros, haz clic en **"Publicar cambios"** o **"Publish changes"**
2. Confirma la publicación

---

## 📊 Resumen de Todas las Variables

Después de la configuración, deberías tener estos parámetros en Firebase Remote Config:

### **Versiones Mínimas**
```
manos_min_version_android: 1.2.1
manos_min_version_ios: 1.2.1
manos_min_version_web: 1.2.1
```

### **Últimas Versiones**
```
manos_latest_version_android: 1.2.1
manos_latest_version_ios: 1.2.1
manos_latest_version_web: 1.2.1
```

### **URLs de Tiendas/Sitios**
```
manos_android_store_url: https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
manos_ios_store_url: https://apps.apple.com/ar/app/manos-del-pueblo/id6759227694
manos_web_url: https://manos-del-pueblo.ar
```

### **Configuración de Actualizaciones**
```
manos_force_update: false
manos_update_message: Hay una nueva versión disponible. Por favor actualiza la aplicación.
manos_force_update_message: Esta versión ya no es compatible. Debes actualizar para continuar.
```

### **Banner de Inicio**
```
home_banner_enabled: true
home_banner_text: Bienvenidos a Manos del Pueblo
```

---

## 🔄 Cómo Funciona el Control de Versiones para Web

### **Detección de Plataforma**

El código ahora detecta automáticamente si la app está corriendo en Web:

```dart
if (kIsWeb) {
  return getString('manos_min_version_web');
}
```

### **Flujo de Actualización para Web**

1. La app web carga y lee la versión del `pubspec.yaml`
2. Consulta Firebase Remote Config para obtener `manos_min_version_web` y `manos_latest_version_web`
3. Compara las versiones:
   - Si versión actual < versión mínima → Muestra mensaje de actualización forzada
   - Si versión actual < última versión → Muestra mensaje de actualización opcional
   - Si versión actual >= última versión → Todo OK

4. Si hay actualización disponible, el botón "Actualizar" redirige a `manos_web_url`

---

## 🚀 Actualizar Versión Web en el Futuro

Cuando publiques una nueva versión de la web:

### **Paso 1: Actualizar pubspec.yaml**
```yaml
version: 1.2.2+8
```

### **Paso 2: Compilar y Desplegar**
```bash
flutter build web --release
# Subir a GitHub Pages o tu servidor
```

### **Paso 3: Actualizar Firebase Remote Config**

1. Ve a Firebase Console → Remote Config
2. Edita `manos_latest_version_web` → Cambia a `1.2.2`
3. (Opcional) Si quieres forzar actualización, edita `manos_min_version_web` → Cambia a `1.2.2`
4. Publica los cambios

### **Paso 4: Usuarios Verán el Mensaje**

Los usuarios con versión antigua verán:
- "Hay una nueva versión disponible" (si solo actualizaste `latest_version`)
- "Esta versión ya no es compatible" (si actualizaste `min_version`)

---

## ⚠️ Notas Importantes

### **Actualización de Web vs Apps Móviles**

- **Web**: Los usuarios obtienen la nueva versión automáticamente al recargar (Ctrl+F5)
- **Android/iOS**: Los usuarios deben descargar desde las tiendas

### **Caché del Navegador**

Si los usuarios no ven la nueva versión:
1. Presionar **Ctrl + F5** (Windows/Linux) o **Cmd + Shift + R** (Mac)
2. Esto fuerza la recarga sin caché

### **Service Workers**

Si usas Service Workers para PWA, asegúrate de:
1. Incrementar la versión del Service Worker
2. Limpiar el caché antiguo

---

## 🧪 Probar la Configuración

### **Prueba Local**

1. Ejecuta la app web localmente:
   ```bash
   flutter run -d chrome
   ```

2. Verifica en la consola que se carguen los valores de Remote Config

3. Cambia temporalmente la versión en `pubspec.yaml` a una menor (ej: `1.0.0`)

4. Reinicia la app y verifica que aparezca el mensaje de actualización

### **Prueba en Producción**

1. Despliega la versión actual (1.2.1)
2. En Firebase, cambia `manos_latest_version_web` a `1.2.2`
3. Recarga la app web
4. Deberías ver el mensaje de actualización disponible

---

## 📞 Soporte

Si tienes problemas:
1. Verifica que los parámetros estén publicados en Firebase
2. Revisa la consola del navegador para errores
3. Asegúrate de que Firebase esté inicializado correctamente

---

**Última actualización**: Febrero 2026  
**Versión del documento**: 1.0
