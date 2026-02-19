# Incorporación del Logo en la Aplicación

## Archivos Modificados

### 1. `lib/screens/home_screen.dart`
- **Cambio**: Agregado el logo en el AppBar junto al título
- **Ubicación**: En el AppBar, ahora muestra el logo (40px de altura) seguido del texto "Manos del Pueblo"

### 2. `lib/screens/about_screen.dart`
- **Cambio**: Reemplazado el icono genérico por el logo real
- **Ubicación**: En el círculo superior de la pantalla "Sobre Nosotros"
- **Diseño**: Logo dentro de un círculo con borde marrón y fondo beige

### 3. `pubspec.yaml`
- **Cambio**: Agregado `assets/logo.png` a la lista de assets
- **Necesario para**: Que Flutter pueda cargar el logo desde los assets

### 4. `web/index.html`
- **Cambio**: Configurado el favicon para que use `favicon.png`
- **Incluye**: Soporte para múltiples navegadores y dispositivos móviles

## Archivos de Logo

- **`web/favicon.png`**: Logo para el navegador (favicon)
- **`assets/logo.png`**: Logo para usar dentro de la aplicación Flutter

## Próximos Pasos

1. Ejecutar `flutter pub get` para actualizar las dependencias
2. Compilar la aplicación: `flutter build web`
3. Copiar a docs: `rmdir /s /q docs & mkdir docs & xcopy build\web docs /E /I /Y`
4. Subir cambios a GitHub

## Resultado

El logo "Manos del Pueblo" ahora aparece en:
- ✅ Favicon del navegador
- ✅ AppBar de la pantalla principal
- ✅ Pantalla "Sobre Nosotros"
