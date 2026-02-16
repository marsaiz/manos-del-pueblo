# 🚀 Pasos Rápidos: Generar Íconos de la App

## ⚡ Opción 1: Usar el Script (Recomendado)

### Linux/Mac:
```bash
./generar_iconos.sh
```

### Windows:
```bash
generar_iconos.bat
```

## ⚡ Opción 2: Comandos Manuales

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar íconos
dart run flutter_launcher_icons

# 3. Compilar y probar
flutter build apk
# o
flutter build appbundle
```

## ✅ Verificación

Después de generar los íconos:

1. **Compila la app:**
   ```bash
   flutter build apk
   ```

2. **Instala en tu dispositivo:**
   ```bash
   flutter install
   ```

3. **Verifica:**
   - Android: Ve al drawer de aplicaciones
   - iOS: Ve a la pantalla de inicio
   - Web: Abre en navegador y verifica el favicon
   - Busca "Manos del Pueblo"
   - Verifica que el logo se muestre correctamente

## 📁 Archivos Generados

Los íconos se generarán automáticamente en:

```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
└── mipmap-xxxhdpi/ic_launcher.png

ios/Runner/Assets.xcassets/AppIcon.appiconset/
└── (múltiples tamaños para iOS)

web/
├── favicon.png
└── icons/
    ├── Icon-192.png
    ├── Icon-512.png
    ├── Icon-maskable-192.png
    └── Icon-maskable-512.png
```

## 🎨 Logo Configurado

- **Archivo**: `assets/logo_manos.png`
- **Plataformas**: Android, iOS y Web
- **Adaptive Icon**: Sí (Android 8+)
- **Fondo**: Blanco (#FFFFFF)
- **Favicon**: Generado automáticamente para Web

## 📝 Notas

- ✅ El paquete `flutter_launcher_icons` ya está configurado en `pubspec.yaml`
- ✅ Los scripts están listos para usar
- ✅ Solo necesitas ejecutar el comando una vez
- ✅ Genera íconos para Android, iOS y Web automáticamente
- ⚠️ Si cambias el logo, vuelve a ejecutar el comando

## 🔄 ¿Quieres Cambiar el Ícono en el Futuro?

Lee la guía completa: `COMO_CAMBIAR_ICONO.md`

---

¡Listo para generar tus íconos! 🎉
