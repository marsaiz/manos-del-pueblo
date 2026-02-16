# 🚀 Pasos Rápidos - Configurar Firebase Remote Config

## Checklist de configuración

### ✅ Paso 1: Instalar dependencias
```bash
flutter pub get
```

### ✅ Paso 2: Agregar parámetros en Firebase Console

Ve a: **Firebase Console → Tu Proyecto → Remote Config → Agregar parámetro**

Copia y pega estos 9 parámetros (uno por uno):

#### 1. manos_min_version_android
- Tipo: **String**
- Valor: `1.0.0`

#### 2. manos_min_version_ios
- Tipo: **String**
- Valor: `1.0.0`

#### 3. manos_latest_version_android
- Tipo: **String**
- Valor: `1.0.0`

#### 4. manos_latest_version_ios
- Tipo: **String**
- Valor: `1.0.0`

#### 5. manos_force_update
- Tipo: **Boolean**
- Valor: `false`

#### 6. manos_update_message
- Tipo: **String**
- Valor: `Hay una nueva versión disponible. Por favor actualiza la aplicación.`

#### 7. manos_force_update_message
- Tipo: **String**
- Valor: `Esta versión ya no es compatible. Debes actualizar para continuar.`

#### 8. manos_android_store_url
- Tipo: **String**
- Valor: `https://play.google.com/store/apps/details?id=com.example.manos_del_pueblo`
  - ⚠️ Reemplaza `com.example.manos_del_pueblo` con tu package name real

#### 9. manos_ios_store_url
- Tipo: **String**
- Valor: `https://apps.apple.com/app/id123456789`
  - ⚠️ Reemplaza `123456789` con tu App ID de App Store

### ✅ Paso 3: Publicar cambios

**MUY IMPORTANTE**: Haz clic en el botón **"Publicar cambios"** en la parte superior de Remote Config.

### ✅ Paso 4: Obtener tu package name (Android)

```bash
# Busca en este archivo:
cat android/app/build.gradle.kts | grep applicationId
```

O abre `android/app/build.gradle.kts` y busca:
```kotlin
applicationId = "com.example.manos_del_pueblo"  // <-- Este es tu package name
```

### ✅ Paso 5: Obtener tu App ID (iOS)

El App ID lo obtienes de App Store Connect después de crear tu app:
1. Ve a https://appstoreconnect.apple.com/
2. Crea tu app (si no existe)
3. El App ID aparece en la URL: `https://appstoreconnect.apple.com/apps/123456789/`

### ✅ Paso 6: Actualizar URLs en Firebase

1. Ve a Remote Config
2. Edita `manos_android_store_url` con tu URL real
3. Edita `manos_ios_store_url` con tu URL real
4. **Publica los cambios**

### ✅ Paso 7: Probar

```bash
flutter run
```

La app debería iniciar sin problemas. Para probar el diálogo de actualización:

1. Cambia la versión en `pubspec.yaml`:
   ```yaml
   version: 0.9.0+1  # Versión menor a la mínima
   ```

2. Ejecuta de nuevo:
   ```bash
   flutter run
   ```

3. Deberías ver el diálogo de actualización forzada

4. Revierte el cambio:
   ```yaml
   version: 1.0.0+1  # Versión correcta
   ```

## 🎯 Uso en producción

### Cuando publiques una nueva versión (ej: 1.1.0):

1. Publica en Google Play / App Store
2. Ve a Firebase Remote Config
3. Actualiza `manos_latest_version_android` → `1.1.0`
4. Actualiza `manos_latest_version_ios` → `1.1.0`
5. **Publica cambios**

Los usuarios verán un mensaje de actualización opcional.

### Si hay un bug crítico:

1. Publica la versión corregida (ej: 1.0.1)
2. Ve a Firebase Remote Config
3. Actualiza `manos_min_version_android` → `1.0.1`
4. **Publica cambios**

Los usuarios con v1.0.0 NO podrán usar la app hasta actualizar.

### Para mantenimiento de emergencia:

1. Ve a Firebase Remote Config
2. Cambia `manos_force_update` → `true`
3. **Publica cambios**

TODOS los usuarios verán el diálogo de actualización forzada.

## 📝 Notas

- ✅ El prefijo `manos_` evita conflictos con tu app FoodDelivery
- ✅ Ambas apps pueden coexistir en el mismo proyecto Firebase
- ⚠️ Siempre publica en las tiendas ANTES de actualizar Remote Config
- ⚠️ Prueba en desarrollo antes de cambiar valores en producción

## 🆘 Ayuda

Si algo no funciona, revisa:
- `CONFIGURACION_FIREBASE_REMOTE_CONFIG.md` - Guía detallada
- `GUIA_ACTUALIZACIONES.md` - Todos los escenarios posibles
- Logs de la app: `flutter logs`
