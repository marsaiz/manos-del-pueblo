# 📋 Valores Exactos para Firebase Remote Config - Manos del Pueblo

## Copia estos valores exactamente en Firebase Console

### Package Name detectado: `ar.manosdelpueblo.app`

---

## Parámetros a crear en Firebase Remote Config

### 1. manos_min_version_android
```
Tipo: String
Valor: 1.0.0
```

### 2. manos_min_version_ios
```
Tipo: String
Valor: 1.0.0
```

### 3. manos_latest_version_android
```
Tipo: String
Valor: 1.0.0
```

### 4. manos_latest_version_ios
```
Tipo: String
Valor: 1.0.0
```

### 5. manos_force_update
```
Tipo: Boolean
Valor: false
```

### 6. manos_update_message
```
Tipo: String
Valor: Hay una nueva versión disponible. Por favor actualiza la aplicación.
```

### 7. manos_force_update_message
```
Tipo: String
Valor: Esta versión ya no es compatible. Debes actualizar para continuar.
```

### 8. manos_android_store_url
```
Tipo: String
Valor: https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
```

### 9. manos_ios_store_url
```
Tipo: String
Valor: https://apps.apple.com/app/id123456789
```
⚠️ **IMPORTANTE**: Reemplaza `123456789` con tu App ID real cuando lo tengas de App Store Connect

---

## Instrucciones paso a paso

1. Ve a: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. Menú lateral → **Remote Config**
4. Haz clic en **"Agregar parámetro"**
5. Para cada parámetro de arriba:
   - Ingresa el nombre exacto (ej: `manos_min_version_android`)
   - Selecciona el tipo (String o Boolean)
   - Ingresa el valor
   - Haz clic en "Guardar"
6. Después de agregar los 9 parámetros, haz clic en **"Publicar cambios"** (arriba)

---

## Verificación

Después de publicar, deberías tener estos parámetros en Remote Config:

**Parámetros de FoodDelivery (existentes):**
- force_update
- latest_app_version
- min_app_version
- update_message
- update_url_android
- update_url_ios

**Parámetros de Manos del Pueblo (nuevos):**
- manos_min_version_android ✅
- manos_min_version_ios ✅
- manos_latest_version_android ✅
- manos_latest_version_ios ✅
- manos_force_update ✅
- manos_update_message ✅
- manos_force_update_message ✅
- manos_android_store_url ✅
- manos_ios_store_url ✅

---

## URLs de las tiendas

### Google Play (Android)
```
https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
```

Esta URL funcionará automáticamente cuando publiques tu app en Google Play con el package name `ar.manosdelpueblo.app`.

### App Store (iOS)

Cuando crees tu app en App Store Connect:

1. Ve a: https://appstoreconnect.apple.com/
2. Crea tu app
3. Obtén el App ID de la URL (ej: `https://appstoreconnect.apple.com/apps/987654321/`)
4. Tu URL será: `https://apps.apple.com/app/id987654321`
5. Actualiza el parámetro `manos_ios_store_url` en Firebase con esta URL

---

## Siguiente paso

Ejecuta:
```bash
flutter pub get
flutter run
```

La app debería funcionar normalmente. Los diálogos de actualización aparecerán cuando cambies las versiones en Remote Config.

---

## Ejemplo de uso real

### Cuando publiques versión 1.1.0:

1. Publica en Google Play
2. Ve a Firebase Remote Config
3. Edita `manos_latest_version_android`
4. Cambia de `1.0.0` a `1.1.0`
5. Publica cambios

Los usuarios con v1.0.0 verán: "Hay una nueva versión disponible..."

### Si necesitas forzar actualización:

1. Edita `manos_min_version_android`
2. Cambia a la versión mínima requerida
3. Publica cambios

Los usuarios con versión menor NO podrán usar la app.
