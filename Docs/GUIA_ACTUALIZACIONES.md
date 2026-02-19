# Guía de Actualizaciones Obligatorias con Firebase Remote Config

## Descripción

Este sistema permite controlar las actualizaciones de la app desde Firebase Remote Config sin necesidad de publicar una nueva versión. Puedes forzar actualizaciones o sugerir actualizaciones opcionales.

## Configuración en Firebase Console

### 1. Acceder a Remote Config

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, busca "Remote Config" en la sección "Engage"

### 2. Crear los parámetros

Crea los siguientes parámetros en Remote Config (con prefijo `manos_` para no conflictuar con otras apps):

#### Parámetros de versión:

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `manos_min_version_android` | String | `1.0.0` | Versión mínima requerida para Android |
| `manos_min_version_ios` | String | `1.0.0` | Versión mínima requerida para iOS |
| `manos_latest_version_android` | String | `1.0.0` | Última versión disponible para Android |
| `manos_latest_version_ios` | String | `1.0.0` | Última versión disponible para iOS |

#### Parámetros de control:

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `manos_force_update` | Boolean | `false` | Si es `true`, fuerza actualización sin importar la versión |
| `manos_update_message` | String | `Hay una nueva versión disponible...` | Mensaje para actualización opcional |
| `manos_force_update_message` | String | `Esta versión ya no es compatible...` | Mensaje para actualización forzada |

#### Parámetros de tiendas:

| Parámetro | Tipo | Valor | Descripción |
|-----------|------|-------|-------------|
| `manos_android_store_url` | String | URL de Play Store | Link a tu app en Google Play |
| `manos_ios_store_url` | String | URL de App Store | Link a tu app en App Store |

### 3. Ejemplos de URLs de tiendas

**Android (Google Play):**
```
https://play.google.com/store/apps/details?id=com.example.manos_del_pueblo
```

**iOS (App Store):**
```
https://apps.apple.com/app/id123456789
```

## Cómo funciona

### Flujo de verificación

1. Al iniciar la app, se obtiene la versión actual desde `package_info_plus`
2. Se consultan los valores de Remote Config
3. Se comparan las versiones usando versionado semántico (x.y.z)
4. Se determina el estado:
   - **Actualización forzada**: Si la versión actual < versión mínima O `force_update` = true
   - **Actualización opcional**: Si la versión actual < última versión
   - **Actualizada**: Si la versión actual >= última versión

### Tipos de actualización

#### Actualización Forzada
- El usuario NO puede cerrar el diálogo
- Debe actualizar para usar la app
- Se activa cuando:
  - La versión actual es menor que `min_version_android/ios`
  - O cuando `force_update` está en `true`

#### Actualización Opcional
- El usuario puede cerrar el diálogo y usar la app
- Se muestra cuando hay una versión más nueva disponible
- Se activa cuando:
  - La versión actual es menor que `latest_version_android/ios`
  - Pero mayor o igual que `min_version_android/ios`

## Escenarios de uso

### Escenario 1: Lanzar nueva versión (actualización opcional)

```
Versión actual en tiendas: 1.0.0
Nueva versión publicada: 1.1.0

Configuración en Remote Config:
- manos_min_version_android: "1.0.0"
- manos_latest_version_android: "1.1.0"
- manos_force_update: false

Resultado: Los usuarios con v1.0.0 verán un mensaje opcional de actualización
```

### Escenario 2: Forzar actualización por bug crítico

```
Versión con bug: 1.0.0
Versión corregida: 1.0.1

Configuración en Remote Config:
- manos_min_version_android: "1.0.1"
- manos_latest_version_android: "1.0.1"
- manos_force_update: false

Resultado: Los usuarios con v1.0.0 NO podrán usar la app hasta actualizar
```

### Escenario 3: Mantenimiento de emergencia

```
Configuración en Remote Config:
- manos_force_update: true
- manos_force_update_message: "La app está en mantenimiento. Por favor actualiza."

Resultado: TODOS los usuarios verán el diálogo de actualización forzada
```

### Escenario 4: Deprecar versiones antiguas

```
Versiones en uso: 1.0.0, 1.1.0, 1.2.0
Nueva versión: 1.3.0

Configuración en Remote Config:
- manos_min_version_android: "1.2.0"
- manos_latest_version_android: "1.3.0"

Resultado:
- v1.0.0 y v1.1.0: Actualización FORZADA
- v1.2.0: Actualización opcional
- v1.3.0: Sin mensaje
```

## Pasos para implementar una actualización

### 1. Publicar nueva versión en las tiendas

Primero publica tu app en Google Play y App Store con la nueva versión.

### 2. Actualizar Remote Config

Una vez que la nueva versión esté disponible en las tiendas:

1. Ve a Firebase Console > Remote Config
2. Actualiza los parámetros según el tipo de actualización que necesites
3. Haz clic en "Publicar cambios"

### 3. Los usuarios verán el mensaje

- Los cambios se propagan en minutos
- La próxima vez que los usuarios abran la app, verán el mensaje
- El intervalo de fetch es de 1 hora (configurable en `remote_config_service.dart`)

## Personalizar mensajes

Puedes personalizar los mensajes en Remote Config:

```
manos_update_message: "¡Nueva versión disponible! 🎉\n\nDescubre las nuevas funcionalidades y mejoras."

manos_force_update_message: "⚠️ Actualización Requerida\n\nEsta versión ya no es compatible. Por favor actualiza para continuar usando Manos del Pueblo."
```

## Configuración avanzada

### Cambiar intervalo de fetch

En `lib/services/remote_config_service.dart`:

```dart
await _remoteConfig.setConfigSettings(
  RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(minutes: 30), // Cambiar aquí
  ),
);
```

### Condiciones por plataforma en Firebase

Puedes crear condiciones en Firebase Console para valores diferentes por plataforma:

1. En Remote Config, crea una condición
2. Nombre: "Android"
3. Regla: `Platform == Android`
4. Asigna valores específicos para Android

Repite para iOS.

## Testing

### Probar en desarrollo

1. Cambia `minimumFetchInterval` a `Duration.zero` para testing
2. Modifica la versión en `pubspec.yaml` para simular versiones antiguas
3. Actualiza los valores en Remote Config
4. Reinicia la app

### Probar actualización forzada

```yaml
# pubspec.yaml
version: 0.9.0+1  # Versión menor a la mínima
```

```
# Remote Config
manos_min_version_android: "1.0.0"
```

### Probar actualización opcional

```yaml
# pubspec.yaml
version: 1.0.0+1
```

```
# Remote Config
manos_min_version_android: "1.0.0"
manos_latest_version_android: "1.1.0"
```

## Troubleshooting

### El diálogo no aparece

1. Verifica que Remote Config esté inicializado correctamente
2. Revisa los logs en la consola: `flutter logs`
3. Asegúrate de que los valores en Firebase estén publicados
4. Verifica que la versión en `pubspec.yaml` sea correcta

### El link de la tienda no funciona

1. Verifica que las URLs estén correctas en Remote Config
2. Para Android: Usa el package name correcto
3. Para iOS: Usa el App ID correcto (lo obtienes después de subir a App Store Connect)

### Cambios no se reflejan

1. Los cambios pueden tardar hasta 1 hora por el `minimumFetchInterval`
2. Para testing, reduce el intervalo a `Duration.zero`
3. Cierra completamente la app y vuelve a abrirla

## Notas importantes

- ⚠️ Siempre publica la nueva versión en las tiendas ANTES de actualizar Remote Config
- ⚠️ Prueba exhaustivamente antes de activar `force_update: true`
- ⚠️ Ten cuidado con las versiones mínimas, podrías bloquear usuarios legítimos
- 💡 Usa actualización forzada solo para bugs críticos o problemas de seguridad
- 💡 Comunica las actualizaciones a tus usuarios por otros canales también

## Versión actual de la app

Para cambiar la versión de tu app, edita `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^^^^^ ^^
#        |     |
#        |     +-- Build number (incrementa en cada build)
#        +-------- Version name (x.y.z - semántico)
```

Incrementa según:
- **Major (x)**: Cambios incompatibles o rediseño completo
- **Minor (y)**: Nuevas funcionalidades compatibles
- **Patch (z)**: Correcciones de bugs
