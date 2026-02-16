# Instalación del Sistema de Actualizaciones

## Pasos rápidos

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar Firebase Remote Config

Ve a [Firebase Console](https://console.firebase.google.com/) y configura los parámetros según la guía `GUIA_ACTUALIZACIONES.md`.

Parámetros mínimos requeridos:

```
manos_min_version_android: "1.0.0"
manos_min_version_ios: "1.0.0"
manos_latest_version_android: "1.0.0"
manos_latest_version_ios: "1.0.0"
manos_force_update: false
manos_update_message: "Hay una nueva versión disponible. Por favor actualiza la aplicación."
manos_force_update_message: "Esta versión ya no es compatible. Debes actualizar para continuar."
manos_android_store_url: "https://play.google.com/store/apps/details?id=TU_PACKAGE_NAME"
manos_ios_store_url: "https://apps.apple.com/app/idTU_APP_ID"
```

### 3. Actualizar URLs de las tiendas

Edita los valores en Firebase Remote Config con tus URLs reales:

**Para Android:**
- Reemplaza `TU_PACKAGE_NAME` con el package name de tu app (ej: `com.example.manos_del_pueblo`)
- Lo encuentras en `android/app/build.gradle.kts` en `applicationId`

**Para iOS:**
- Reemplaza `TU_APP_ID` con el ID de tu app en App Store
- Lo obtienes después de crear tu app en App Store Connect

### 4. Compilar y probar

```bash
# Para Android
flutter build apk
# o
flutter build appbundle

# Para iOS
flutter build ios
```

## Archivos creados

- `lib/services/remote_config_service.dart` - Servicio mejorado de Remote Config
- `lib/services/version_check_service.dart` - Servicio de verificación de versiones
- `lib/widgets/update_dialog.dart` - Diálogo de actualización
- `lib/main.dart` - Actualizado con verificación al inicio

## Cómo funciona

1. Al iniciar la app, se verifica la versión actual
2. Se compara con los valores de Remote Config
3. Si hay actualización disponible, se muestra un diálogo
4. Si es actualización forzada, el usuario no puede cerrar el diálogo
5. Si es opcional, puede cerrar y usar la app

## Testing rápido

Para probar que funciona:

1. Cambia la versión en `pubspec.yaml` a `0.9.0+1`
2. En Firebase Remote Config, pon `manos_min_version_android: "1.0.0"`
3. Ejecuta la app: `flutter run`
4. Deberías ver el diálogo de actualización forzada

## Próximos pasos

Lee `GUIA_ACTUALIZACIONES.md` para entender todos los escenarios y configuraciones avanzadas.
