# Configuración de Firebase Remote Config para Manos del Pueblo

## Importante: Múltiples Apps en el Mismo Proyecto

Como ya tienes otra app (FoodDelivery) usando Remote Config en el mismo proyecto de Firebase, todos los parámetros de Manos del Pueblo usan el prefijo `manos_` para evitar conflictos.

## Pasos para agregar los parámetros

### 1. Acceder a Remote Config

1. Ve a Firebase Console: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. En el menú lateral, haz clic en "Remote Config"

### 2. Agregar cada parámetro

Para cada parámetro de la tabla abajo, haz lo siguiente:

1. Haz clic en "Agregar parámetro"
2. Ingresa el nombre del parámetro (exactamente como aparece en la tabla)
3. Selecciona el tipo de dato
4. Ingresa el valor por defecto
5. Haz clic en "Guardar"

### 3. Tabla de parámetros a crear

| Nombre del parámetro | Tipo | Valor inicial | Descripción |
|---------------------|------|---------------|-------------|
| `manos_min_version_android` | String | `1.0.0` | Versión mínima para Android |
| `manos_min_version_ios` | String | `1.0.0` | Versión mínima para iOS |
| `manos_latest_version_android` | String | `1.0.0` | Última versión para Android |
| `manos_latest_version_ios` | String | `1.0.0` | Última versión para iOS |
| `manos_force_update` | Boolean | `false` | Forzar actualización |
| `manos_update_message` | String | Ver abajo | Mensaje actualización opcional |
| `manos_force_update_message` | String | Ver abajo | Mensaje actualización forzada |
| `manos_android_store_url` | String | Ver abajo | URL Google Play |
| `manos_ios_store_url` | String | Ver abajo | URL App Store |

### 4. Valores de texto para los mensajes

**Para `manos_update_message`:**
```
Hay una nueva versión disponible. Por favor actualiza la aplicación.
```

**Para `manos_force_update_message`:**
```
Esta versión ya no es compatible. Debes actualizar para continuar.
```

### 5. URLs de las tiendas

**Para `manos_android_store_url`:**

Necesitas el package name de tu app. Lo encuentras en:
- Archivo: `android/app/build.gradle.kts`
- Busca: `applicationId`

Formato de la URL:
```
https://play.google.com/store/apps/details?id=TU_PACKAGE_NAME
```

Ejemplo:
```
https://play.google.com/store/apps/details?id=com.example.manos_del_pueblo
```

**Para `manos_ios_store_url`:**

Necesitas el App ID de App Store Connect. Lo obtienes después de crear tu app en App Store Connect.

Formato de la URL:
```
https://apps.apple.com/app/id123456789
```

Reemplaza `123456789` con tu App ID real.

### 6. Publicar los cambios

⚠️ **MUY IMPORTANTE**: Después de agregar todos los parámetros, debes hacer clic en el botón "Publicar cambios" en la parte superior de la página de Remote Config.

Los cambios NO se aplicarán hasta que los publiques.

## Verificación

Después de publicar, deberías ver algo así en tu consola de Remote Config:

```
Parámetros existentes (FoodDelivery):
- force_update
- latest_app_version
- min_app_version
- update_message
- update_url_android
- update_url_ios

Nuevos parámetros (Manos del Pueblo):
- manos_min_version_android
- manos_min_version_ios
- manos_latest_version_android
- manos_latest_version_ios
- manos_force_update
- manos_update_message
- manos_force_update_message
- manos_android_store_url
- manos_ios_store_url
```

## Cómo actualizar valores en el futuro

### Cuando publiques una nueva versión:

1. Ve a Remote Config en Firebase Console
2. Busca el parámetro que quieres actualizar (ej: `manos_latest_version_android`)
3. Haz clic en el ícono de editar (lápiz)
4. Cambia el valor (ej: de `1.0.0` a `1.1.0`)
5. Haz clic en "Guardar"
6. **Haz clic en "Publicar cambios"** (arriba)

### Para forzar actualización inmediata:

1. Cambia `manos_force_update` a `true`
2. Publica los cambios
3. Todos los usuarios verán el diálogo de actualización forzada

### Para requerir versión mínima:

1. Actualiza `manos_min_version_android` o `manos_min_version_ios`
2. Publica los cambios
3. Usuarios con versión menor verán actualización forzada

## Ejemplo práctico

Imagina que acabas de publicar la versión 1.1.0 en Google Play:

1. Ve a Remote Config
2. Edita `manos_latest_version_android` → cambia a `1.1.0`
3. Publica cambios
4. Los usuarios con v1.0.0 verán un mensaje de actualización opcional

Si hay un bug crítico en v1.0.0:

1. Edita `manos_min_version_android` → cambia a `1.0.1`
2. Publica cambios
3. Los usuarios con v1.0.0 NO podrán usar la app hasta actualizar

## Troubleshooting

### Los cambios no se reflejan en la app

- Verifica que hayas hecho clic en "Publicar cambios"
- Los cambios pueden tardar hasta 1 hora (por el `minimumFetchInterval`)
- Cierra completamente la app y vuelve a abrirla

### No veo los parámetros nuevos

- Asegúrate de estar en el proyecto correcto de Firebase
- Verifica que hayas guardado cada parámetro
- Recuerda publicar los cambios

### La app no se conecta a Remote Config

- Verifica que `google-services.json` (Android) esté actualizado
- Verifica que `GoogleService-Info.plist` (iOS) esté actualizado
- Revisa los logs de la app para errores de Firebase

## Notas importantes

- ✅ Los parámetros con prefijo `manos_` NO afectarán tu app FoodDelivery
- ✅ Puedes tener múltiples apps usando Remote Config en el mismo proyecto
- ✅ Cada app lee solo sus propios parámetros
- ⚠️ Siempre publica los cambios después de editarlos
- ⚠️ Prueba en desarrollo antes de cambiar valores en producción
