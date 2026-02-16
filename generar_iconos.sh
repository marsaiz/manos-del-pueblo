#!/bin/bash

# Script para generar íconos de la app
# Uso: ./generar_iconos.sh

echo "🎨 Generando íconos de la app..."
echo ""

# 1. Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

echo ""
echo "🔨 Generando íconos para Android e iOS..."

# 2. Generar íconos
dart run flutter_launcher_icons

echo ""
echo "✅ ¡Íconos generados exitosamente!"
echo ""
echo "📱 Los íconos se han generado en:"
echo "   - Android: android/app/src/main/res/mipmap-*/"
echo "   - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Compila la app: flutter build apk (Android) o flutter build ios (iOS)"
echo "   2. Instala en tu dispositivo: flutter install"
echo "   3. Verifica que el ícono se muestre correctamente"
echo ""
