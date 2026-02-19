# Guía para Actualizar Iconos de la App

## Estado Actual
- ✅ Logo nuevo: `assets/logo.png` (1024x1024px, 1.1MB)
- ⚠️ Tamaño excede el límite de Google Play (max 1024KB)
- ✅ Configuración actualizada en `pubspec.yaml`

## Requisitos de Google Play

### Para Google Play Store (Feature Graphic y Screenshots)
- **Icono de alta resolución**: 512x512px
- **Formato**: 32-bit PNG
- **Espacio de color**: sRGB
- **Tamaño máximo**: 1024KB (1MB)
- **Forma**: Cuadrado completo (Google Play aplica máscara redondeada automáticamente)
- **Sin sombras**: Google Play las aplica dinámicamente

### Para Android Adaptive Icons (APK)
- **Foreground**: Tu logo (puede tener transparencia)
- **Background**: Color sólido o imagen
- **Tamaño**: 1024x1024px recomendado
- **Safe zone**: El contenido importante debe estar en el 66% central

## Pasos para Actualizar los Iconos

### 1. Optimizar el logo (reducir tamaño del archivo)

Puedes usar una de estas opciones:

**Opción A: Online (más fácil)**
1. Ve a https://tinypng.com/
2. Sube `assets/logo.png`
3. Descarga la versión optimizada
4. Reemplaza el archivo original

**Opción B: Con ImageMagick (si lo tienes instalado)**
```bash
# Optimizar manteniendo calidad
convert assets/logo.png -strip -quality 85 assets/logo_optimized.png
mv assets/logo_optimized.png assets/logo.png
```

**Opción C: Con herramientas online de Google**
- https://squoosh.app/ (recomendado por Google)

### 2. Generar los iconos para todas las plataformas

```bash
# Instalar/actualizar dependencias
flutter pub get

# Generar iconos
flutter pub run flutter_launcher_icons
```

Este comando generará automáticamente:
- Iconos para Android en todas las resoluciones (mipmap)
- Adaptive icons para Android 8.0+
- Iconos para iOS en todas las resoluciones
- Iconos para Web

### 3. Verificar los iconos generados

**Android:**
```bash
ls -la android/app/src/main/res/mipmap-*/
```

Deberías ver:
- `ic_launcher.png` (icono estándar)
- `ic_launcher_foreground.png` (adaptive icon foreground)
- `ic_launcher_background.png` (adaptive icon background)

**iOS:**
```bash
ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

### 4. Crear icono de 512x512px para Google Play Console

Google Play requiere un icono de 512x512px para la consola:

```bash
# Con ImageMagick
convert assets/logo.png -resize 512x512 assets/logo_512.png

# O usa una herramienta online
```

Este archivo `logo_512.png` lo subirás manualmente en Google Play Console:
1. Ve a Google Play Console
2. Tu app → Presencia en la tienda → Recursos gráficos
3. Sube el icono de 512x512px

### 5. Probar en dispositivos

**Android:**
```bash
flutter run --release
```

**iOS:**
```bash
flutter run --release -d ios
```

Verifica que el icono se vea bien en:
- Pantalla de inicio
- Cajón de aplicaciones
- Configuración del sistema
- Diferentes temas (claro/oscuro)

## Consideraciones Importantes

### Android Adaptive Icons
Tu logo debe funcionar bien con diferentes formas de máscara:
- Círculo (algunos launchers)
- Cuadrado redondeado (Google Pixel)
- Squircle (Samsung)
- Gota de agua (algunos launchers)

**Recomendación**: Asegúrate de que el contenido importante de tu logo esté en el 66% central de la imagen.

### iOS
- iOS requiere que el icono NO tenga transparencia
- La configuración `remove_alpha_ios: true` se encarga de esto automáticamente

### Web
- Se genera un favicon y manifest icons automáticamente
- Usa el color de tema especificado: `#5D4037`

## Troubleshooting

### Error: "Image file size exceeds 1024KB"
- Optimiza tu imagen con TinyPNG o Squoosh
- Reduce la calidad JPEG/PNG sin perder mucha calidad visual

### Los iconos no se actualizan en el dispositivo
```bash
# Android: Desinstala y reinstala
flutter clean
flutter pub get
flutter run --release

# iOS: Limpia el build
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run --release
```

### El icono se ve cortado en algunos dispositivos
- Revisa que el contenido importante esté en el safe zone (66% central)
- Considera agregar padding al logo

## Archivos Generados

Después de ejecutar `flutter pub run flutter_launcher_icons`, se generarán:

```
android/app/src/main/res/
├── mipmap-hdpi/
├── mipmap-mdpi/
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
└── mipmap-xxxhdpi/

ios/Runner/Assets.xcassets/AppIcon.appiconset/
└── Contents.json (con todas las variantes)

web/
├── favicon.png
└── manifest.json (actualizado)
```

## Checklist Final

Antes de subir a las tiendas:

- [ ] Logo optimizado (< 1MB)
- [ ] Iconos generados con `flutter pub run flutter_launcher_icons`
- [ ] Probado en Android (diferentes launchers si es posible)
- [ ] Probado en iOS
- [ ] Icono de 512x512px creado para Google Play Console
- [ ] Verificado que el logo se ve bien en tema claro y oscuro
- [ ] Sin transparencias en iOS
- [ ] Contenido importante en safe zone para adaptive icons

## Recursos Adicionales

- [Especificaciones de iconos de Google Play](https://developer.android.com/distribute/google-play/resources/icon-design-specifications)
- [Android Adaptive Icons](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons)
