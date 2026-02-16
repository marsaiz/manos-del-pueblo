# 🎨 Guía: Configurar Ícono de la App

## 📱 Ícono Configurado

Se ha configurado `logo_manos.png` como el ícono de la aplicación para Android e iOS.

## 🚀 Pasos para Generar los Íconos

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Generar los íconos

```bash
dart run flutter_launcher_icons
```

Este comando generará automáticamente todos los tamaños de íconos necesarios para:
- ✅ Android (mipmap-hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ iOS (AppIcon.appiconset con todos los tamaños)
- ✅ Web (favicon.png, Icon-192.png, Icon-512.png)
- ✅ Android Adaptive Icons (con fondo blanco)

### 3. Verificar los íconos generados

Los íconos se generarán en:

**Android:**
```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

**iOS:**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**Web:**
```
web/favicon.png
web/icons/Icon-192.png
web/icons/Icon-512.png
web/icons/Icon-maskable-192.png
web/icons/Icon-maskable-512.png
```

### 4. Compilar y probar

**Para Android:**
```bash
flutter build apk
# o
flutter build appbundle
```

**Para iOS:**
```bash
flutter build ios
```

**Para Web:**
```bash
flutter build web
```

## ⚙️ Configuración Actual

```yaml
flutter_launcher_icons:
  android: true                              # Generar para Android
  ios: true                                  # Generar para iOS
  web:                                       # Generar para Web
    generate: true
    image_path: "assets/logo_manos.png"
    background_color: "#FFFFFF"              # Color de fondo del favicon
    theme_color: "#5D4037"                   # Color del tema (marrón de la app)
  image_path: "assets/logo_manos.png"       # Ruta del logo
  min_sdk_android: 21                        # SDK mínimo de Android
  adaptive_icon_background: "#FFFFFF"        # Fondo blanco para Android 8+
  adaptive_icon_foreground: "assets/logo_manos.png"  # Logo en primer plano
  remove_alpha_ios: true                     # Remover transparencia en iOS
```

## 📋 Requisitos del Ícono

### Tamaño Recomendado
- **Mínimo**: 512x512 px
- **Recomendado**: 1024x1024 px
- **Formato**: PNG con transparencia (opcional)

### Tu Logo Actual
- **Archivo**: `assets/logo_manos.png`
- **Ubicación**: Carpeta `assets/` en la raíz del proyecto

## 🎨 Adaptive Icons (Android 8+)

Los Adaptive Icons permiten que el ícono se adapte a diferentes formas según el fabricante del dispositivo:
- Círculo (Samsung)
- Cuadrado redondeado (Google Pixel)
- Squircle (OnePlus)
- Etc.

**Configuración actual:**
- Fondo: Blanco (#FFFFFF)
- Primer plano: logo_manos.png

## 🔧 Personalización Avanzada

### Cambiar el color de fondo del Adaptive Icon

Edita en `pubspec.yaml`:
```yaml
adaptive_icon_background: "#5D4037"  # Color marrón de tu app
```

### Usar imagen de fondo diferente

```yaml
adaptive_icon_background: "assets/icon_background.png"
adaptive_icon_foreground: "assets/logo_manos.png"
```

### Generar solo para una plataforma

```yaml
flutter_launcher_icons:
  android: true   # Solo Android
  ios: false      # No generar para iOS
  image_path: "assets/logo_manos.png"
```

## 🐛 Troubleshooting

### Error: "Image not found"
- Verifica que `assets/logo_manos.png` existe
- Verifica que está declarado en `pubspec.yaml` en la sección `assets:`

### Los íconos no se actualizan
1. Limpia el build:
   ```bash
   flutter clean
   ```
2. Regenera los íconos:
   ```bash
   dart run flutter_launcher_icons
   ```
3. Recompila la app:
   ```bash
   flutter build apk
   ```

### El ícono se ve pixelado
- Usa una imagen de mayor resolución (mínimo 1024x1024)
- Asegúrate de que el logo sea PNG de alta calidad

### El ícono tiene fondo negro en iOS
- Agrega `remove_alpha_ios: true` en la configuración
- O asegúrate de que tu PNG tenga fondo blanco sin transparencia

## 📱 Verificar en Dispositivo

### Android
1. Instala la app: `flutter install`
2. Ve al drawer de aplicaciones
3. Verifica que el ícono se muestre correctamente

### iOS
1. Compila para iOS: `flutter build ios`
2. Abre en Xcode y ejecuta en simulador/dispositivo
3. Ve a la pantalla de inicio
4. Verifica que el ícono se muestre correctamente

### Web
1. Compila para web: `flutter build web`
2. Abre en navegador: `flutter run -d chrome`
3. Verifica el favicon en la pestaña del navegador
4. Verifica que se vea correctamente

## 🎯 Resultado Esperado

Después de ejecutar los comandos, tu app tendrá:
- ✅ Ícono personalizado en Android
- ✅ Ícono personalizado en iOS
- ✅ Favicon personalizado en Web
- ✅ Adaptive Icon en Android 8+
- ✅ Todos los tamaños generados automáticamente
- ✅ Logo "Manos del Pueblo" visible en todas las plataformas

## 📝 Notas Importantes

1. **Ejecuta el comando cada vez que cambies el logo:**
   ```bash
   dart run flutter_launcher_icons
   ```

2. **Para publicar en las tiendas**, asegúrate de que el ícono:
   - Sea de alta calidad (1024x1024)
   - No tenga bordes o márgenes excesivos
   - Sea reconocible en tamaños pequeños
   - Cumpla con las guías de diseño de cada plataforma

3. **Backup**: Los íconos anteriores serán reemplazados. Si quieres conservarlos, haz una copia antes.

## 🔗 Referencias

- [flutter_launcher_icons en pub.dev](https://pub.dev/packages/flutter_launcher_icons)
- [Guía de íconos de Android](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [Guía de íconos de iOS](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

¡Listo! Ahora tu app tendrá el logo "Manos del Pueblo" como ícono. 🎉
