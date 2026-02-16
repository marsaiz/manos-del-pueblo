# 🎯 Sistema de Actualizaciones Obligatorias - Manos del Pueblo

## ✅ Implementación Completa

Se ha implementado un sistema de actualizaciones obligatorias usando Firebase Remote Config que permite:

- ✅ Forzar actualizaciones cuando hay bugs críticos
- ✅ Sugerir actualizaciones opcionales para nuevas versiones
- ✅ Controlar todo desde Firebase Console sin publicar nueva versión
- ✅ Funciona en iOS y Android
- ✅ No interfiere con tu app FoodDelivery (usa prefijo `manos_`)

## 📁 Archivos creados/modificados

### Código
- `lib/services/remote_config_service.dart` - Servicio mejorado
- `lib/services/version_check_service.dart` - Verificación de versiones
- `lib/widgets/update_dialog.dart` - Diálogo de actualización
- `lib/main.dart` - Integración al inicio de la app
- `pubspec.yaml` - Agregada dependencia `package_info_plus`

### Documentación
- `VALORES_FIREBASE_MANOS_DEL_PUEBLO.md` ⭐ **EMPIEZA AQUÍ**
- `PASOS_RAPIDOS_FIREBASE.md` - Checklist rápido
- `CONFIGURACION_FIREBASE_REMOTE_CONFIG.md` - Guía detallada
- `GUIA_ACTUALIZACIONES.md` - Todos los escenarios
- `INSTALACION_ACTUALIZACIONES.md` - Instalación

## 🚀 Inicio Rápido (3 pasos)

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar Firebase Remote Config

Abre `VALORES_FIREBASE_MANOS_DEL_PUEBLO.md` y copia los 9 parámetros a Firebase Console.

**Importante**: Usa el prefijo `manos_` en todos los parámetros para no conflictuar con FoodDelivery.

### 3. Probar
```bash
flutter run
```

## 📊 Cómo funciona

```
Usuario abre app
    ↓
Verifica versión actual (desde package_info_plus)
    ↓
Consulta Remote Config
    ↓
Compara versiones
    ↓
┌─────────────────────────────────────┐
│ ¿Versión < mínima O force_update?  │
└─────────────────────────────────────┘
    ↓ SÍ                    ↓ NO
Actualización          ¿Versión < última?
FORZADA                    ↓ SÍ        ↓ NO
(no se puede cerrar)   Actualización   Continuar
                       OPCIONAL        normal
                       (se puede cerrar)
```

## 🎮 Uso en producción

### Escenario 1: Nueva versión (actualización opcional)
```
1. Publica v1.1.0 en Google Play
2. Firebase → manos_latest_version_android → "1.1.0"
3. Publica cambios
```
Resultado: Usuarios con v1.0.0 ven mensaje opcional

### Escenario 2: Bug crítico (actualización forzada)
```
1. Publica v1.0.1 con el fix
2. Firebase → manos_min_version_android → "1.0.1"
3. Publica cambios
```
Resultado: Usuarios con v1.0.0 NO pueden usar la app

### Escenario 3: Mantenimiento de emergencia
```
1. Firebase → manos_force_update → true
2. Publica cambios
```
Resultado: TODOS los usuarios ven actualización forzada

## 🔧 Configuración de Firebase

### Tu package name: `ar.manosdelpueblo.app`

### URL de Google Play:
```
https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
```

### URL de App Store:
```
https://apps.apple.com/app/id[TU_APP_ID]
```
(Reemplaza `[TU_APP_ID]` cuando lo tengas de App Store Connect)

## 📝 Parámetros en Firebase Remote Config

Debes crear estos 9 parámetros (con prefijo `manos_`):

1. `manos_min_version_android` (String)
2. `manos_min_version_ios` (String)
3. `manos_latest_version_android` (String)
4. `manos_latest_version_ios` (String)
5. `manos_force_update` (Boolean)
6. `manos_update_message` (String)
7. `manos_force_update_message` (String)
8. `manos_android_store_url` (String)
9. `manos_ios_store_url` (String)

Ver valores exactos en: `VALORES_FIREBASE_MANOS_DEL_PUEBLO.md`

## 🧪 Testing

### Probar actualización forzada:

1. Edita `pubspec.yaml`:
   ```yaml
   version: 0.9.0+1  # Menor a la mínima
   ```

2. Ejecuta:
   ```bash
   flutter run
   ```

3. Deberías ver el diálogo que NO se puede cerrar

4. Revierte:
   ```yaml
   version: 1.0.0+1  # Versión correcta
   ```

### Probar actualización opcional:

1. En Firebase: `manos_latest_version_android: "1.1.0"`
2. En pubspec.yaml: `version: 1.0.0+1`
3. Ejecuta la app
4. Deberías ver el diálogo que SÍ se puede cerrar

## ⚠️ Importante

- ✅ Siempre publica en las tiendas ANTES de actualizar Remote Config
- ✅ Prueba en desarrollo antes de cambiar valores en producción
- ✅ El prefijo `manos_` evita conflictos con FoodDelivery
- ⚠️ No olvides hacer clic en "Publicar cambios" en Firebase
- ⚠️ Los cambios pueden tardar hasta 1 hora en propagarse

## 🆘 Troubleshooting

### Los cambios no se reflejan
- Verifica que hayas publicado los cambios en Firebase
- Cierra completamente la app y vuelve a abrirla
- Espera hasta 1 hora (intervalo de fetch)

### El diálogo no aparece
- Verifica que los parámetros estén publicados en Firebase
- Revisa los logs: `flutter logs`
- Verifica la versión en `pubspec.yaml`

### La URL de la tienda no funciona
- Verifica que el package name sea correcto
- Para iOS, necesitas el App ID real de App Store Connect

## 📚 Documentación completa

- **VALORES_FIREBASE_MANOS_DEL_PUEBLO.md** - Valores exactos a copiar
- **PASOS_RAPIDOS_FIREBASE.md** - Checklist paso a paso
- **CONFIGURACION_FIREBASE_REMOTE_CONFIG.md** - Guía detallada de Firebase
- **GUIA_ACTUALIZACIONES.md** - Todos los escenarios y casos de uso
- **INSTALACION_ACTUALIZACIONES.md** - Instalación y primeros pasos

## 🎉 ¡Listo!

El sistema está completamente implementado. Solo necesitas:

1. Ejecutar `flutter pub get`
2. Configurar los 9 parámetros en Firebase Console
3. Publicar los cambios en Firebase

¡Y ya está funcionando! 🚀
