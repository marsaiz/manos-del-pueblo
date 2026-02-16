# 🔄 Cómo Cambiar el Ícono de la App

## 📋 Guía Completa para Cambiar Íconos

Esta guía te muestra cómo cambiar el ícono de tu app en todas las plataformas: Android, iOS y Web.

---

## 🎨 Paso 1: Preparar el Nuevo Ícono

### Requisitos del Ícono:
- **Formato**: PNG
- **Tamaño mínimo**: 512x512 px
- **Tamaño recomendado**: 1024x1024 px
- **Fondo**: Puede ser transparente o con color
- **Calidad**: Alta resolución para evitar pixelación

### Ubicación:
Guarda tu nuevo ícono en la carpeta `assets/` con cualquier nombre, por ejemplo:
- `assets/nuevo_logo.png`
- `assets/logo_v2.png`
- `assets/icon_2024.png`

---

## 📱 Paso 2: Cambiar Ícono en Android e iOS

### Opción A: Cambiar la Ruta en pubspec.yaml (Recomendado)

1. **Abre `pubspec.yaml`**

2. **Busca la sección `flutter_launcher_icons`:**
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/logo_manos.png"  # <-- Cambiar aquí
     min_sdk_android: 21
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/logo_manos.png"  # <-- Y aquí
     remove_alpha_ios: true
   ```

3. **Cambia las rutas al nuevo ícono:**
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/nuevo_logo.png"  # ✅ Nueva ruta
     min_sdk_android: 21
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/nuevo_logo.png"  # ✅ Nueva ruta
     remove_alpha_ios: true
   ```

4. **Asegúrate de que el nuevo ícono esté en la sección `assets`:**
   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/logo.png
       - assets/logo_manos.png
       - assets/nuevo_logo.png  # ✅ Agregar aquí
   ```

5. **Regenera los íconos:**
   ```bash
   # Opción 1: Usar el script
   ./generar_iconos.sh
   
   # Opción 2: Comando manual
   dart run flutter_launcher_icons
   ```

### Opción B: Reemplazar el Archivo Existente

1. **Reemplaza el archivo `assets/logo_manos.png` con tu nuevo ícono**
   - Mantén el mismo nombre: `logo_manos.png`
   - Asegúrate de que tenga el tamaño correcto (mínimo 512x512)

2. **Regenera los íconos:**
   ```bash
   dart run flutter_launcher_icons
   ```

---

## 🌐 Paso 3: Cambiar Favicon (Web)

El favicon es el ícono que aparece en la pestaña del navegador cuando tu app se ejecuta en web.

### Ubicación del Favicon:
```
web/
├── favicon.png
└── icons/
    ├── Icon-192.png
    ├── Icon-512.png
    └── Icon-maskable-192.png
    └── Icon-maskable-512.png
```

### Método 1: Reemplazar Manualmente

1. **Crea versiones del nuevo ícono en diferentes tamaños:**
   - `favicon.png` - 16x16 o 32x32 px
   - `Icon-192.png` - 192x192 px
   - `Icon-512.png` - 512x512 px
   - `Icon-maskable-192.png` - 192x192 px (con padding)
   - `Icon-maskable-512.png` - 512x512 px (con padding)

2. **Reemplaza los archivos en `web/` y `web/icons/`**

### Método 2: Usar flutter_launcher_icons (Automático)

1. **Actualiza `pubspec.yaml` para incluir web:**
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     web:
       generate: true
       image_path: "assets/nuevo_logo.png"
       background_color: "#FFFFFF"
       theme_color: "#5D4037"
     image_path: "assets/nuevo_logo.png"
     min_sdk_android: 21
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/nuevo_logo.png"
     remove_alpha_ios: true
   ```

2. **Regenera todos los íconos:**
   ```bash
   dart run flutter_launcher_icons
   ```

---

## 🎯 Paso 4: Compilar y Verificar

### Android:
```bash
flutter clean
flutter build apk
flutter install
```

Verifica en el drawer de aplicaciones.

### iOS:
```bash
flutter clean
flutter build ios
```

Abre en Xcode y ejecuta en simulador/dispositivo.

### Web:
```bash
flutter clean
flutter build web
```

Abre en navegador y verifica el favicon en la pestaña.

---

## 📝 Checklist Completo

Usa este checklist cuando cambies el ícono:

- [ ] Preparar nuevo ícono (1024x1024 PNG)
- [ ] Guardar en `assets/nuevo_logo.png`
- [ ] Actualizar `pubspec.yaml` en sección `assets`
- [ ] Actualizar `pubspec.yaml` en sección `flutter_launcher_icons`
- [ ] Ejecutar `flutter pub get`
- [ ] Ejecutar `dart run flutter_launcher_icons`
- [ ] Compilar para Android: `flutter build apk`
- [ ] Compilar para iOS: `flutter build ios`
- [ ] Compilar para Web: `flutter build web`
- [ ] Verificar en dispositivo Android
- [ ] Verificar en dispositivo iOS
- [ ] Verificar favicon en navegador web
- [ ] Commit y push de los cambios

---

## 🎨 Personalización del Adaptive Icon (Android)

Si quieres cambiar el color de fondo del Adaptive Icon:

```yaml
flutter_launcher_icons:
  adaptive_icon_background: "#5D4037"  # Color marrón de tu app
  # o usar una imagen:
  # adaptive_icon_background: "assets/icon_background.png"
```

---

## 🔧 Troubleshooting

### El ícono no se actualiza en el dispositivo

1. **Desinstala la app completamente:**
   ```bash
   flutter clean
   adb uninstall ar.manosdelpueblo.app  # Android
   ```

2. **Regenera los íconos:**
   ```bash
   dart run flutter_launcher_icons
   ```

3. **Reinstala:**
   ```bash
   flutter install
   ```

### El favicon no cambia en el navegador

1. **Limpia la caché del navegador:**
   - Chrome: Ctrl+Shift+Delete
   - Firefox: Ctrl+Shift+Delete
   - Safari: Cmd+Option+E

2. **Fuerza recarga:**
   - Ctrl+F5 (Windows/Linux)
   - Cmd+Shift+R (Mac)

### El ícono se ve pixelado

- Usa una imagen de mayor resolución (mínimo 1024x1024)
- Asegúrate de que sea PNG de alta calidad
- Evita JPG (pierde calidad)

---

## 📂 Estructura de Archivos

Después de cambiar el ícono, estos archivos se actualizarán:

```
proyecto/
├── assets/
│   └── nuevo_logo.png                    # Tu nuevo ícono
├── android/app/src/main/res/
│   ├── mipmap-hdpi/ic_launcher.png      # Generado automáticamente
│   ├── mipmap-mdpi/ic_launcher.png      # Generado automáticamente
│   ├── mipmap-xhdpi/ic_launcher.png     # Generado automáticamente
│   ├── mipmap-xxhdpi/ic_launcher.png    # Generado automáticamente
│   └── mipmap-xxxhdpi/ic_launcher.png   # Generado automáticamente
├── ios/Runner/Assets.xcassets/AppIcon.appiconset/
│   └── (múltiples archivos)              # Generados automáticamente
├── web/
│   ├── favicon.png                       # Actualizar manualmente o con plugin
│   └── icons/
│       ├── Icon-192.png                  # Actualizar manualmente o con plugin
│       └── Icon-512.png                  # Actualizar manualmente o con plugin
└── pubspec.yaml                          # Actualizar rutas aquí
```

---

## 💡 Consejos Profesionales

1. **Mantén el ícono simple**: Los íconos pequeños deben ser reconocibles
2. **Usa colores contrastantes**: Para que se vea bien en fondos claros y oscuros
3. **Prueba en diferentes tamaños**: Verifica que se vea bien en 48x48, 72x72, etc.
4. **Considera el Adaptive Icon**: En Android 8+, el ícono puede tener diferentes formas
5. **Guarda el original**: Mantén una copia del ícono en alta resolución (SVG o PNG 2048x2048)

---

## 🚀 Ejemplo Completo

Supongamos que quieres cambiar de `logo_manos.png` a `logo_2024.png`:

```bash
# 1. Copia tu nuevo ícono
cp ~/Downloads/logo_2024.png assets/

# 2. Edita pubspec.yaml
# Cambia: image_path: "assets/logo_manos.png"
# Por:    image_path: "assets/logo_2024.png"

# 3. Actualiza dependencias
flutter pub get

# 4. Genera los íconos
dart run flutter_launcher_icons

# 5. Limpia y recompila
flutter clean
flutter build apk

# 6. Instala y verifica
flutter install
```

---

## 📚 Referencias

- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Web Favicon Guidelines](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link)

---

¡Listo! Ahora sabes cómo cambiar el ícono en todas las plataformas. 🎉
