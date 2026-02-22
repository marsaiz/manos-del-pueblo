#!/bin/bash
# Script para instalar IPA en iPhone desde Linux
# Usa ideviceinstaller (libimobiledevice)

set -e

echo "=========================================="
echo "  Instalador de IPA para iPhone/iPad"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Verificar que ideviceinstaller está instalado
if ! command -v ideviceinstaller &> /dev/null; then
    print_error "ideviceinstaller no está instalado"
    echo ""
    echo "Instálalo con:"
    echo "  sudo apt-get install ideviceinstaller libimobiledevice-utils"
    exit 1
fi

print_success "ideviceinstaller encontrado"

# Verificar que hay un dispositivo conectado
echo ""
print_info "Buscando dispositivos iOS conectados..."
DEVICE_ID=$(idevice_id -l 2>/dev/null | head -n 1)

if [ -z "$DEVICE_ID" ]; then
    print_error "No se detectó ningún dispositivo iOS"
    echo ""
    echo "Asegúrate de:"
    echo "  1. Conectar el iPhone por USB"
    echo "  2. Desbloquear el iPhone"
    echo "  3. Aceptar 'Confiar en este ordenador' si aparece"
    echo ""
    echo "Luego ejecuta: idevicepair pair"
    exit 1
fi

print_success "Dispositivo encontrado: $DEVICE_ID"

# Obtener información del dispositivo
echo ""
print_info "Información del dispositivo:"
DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || echo "Desconocido")
DEVICE_MODEL=$(ideviceinfo -k ProductType 2>/dev/null || echo "Desconocido")
IOS_VERSION=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Desconocido")

echo "  Nombre: $DEVICE_NAME"
echo "  Modelo: $DEVICE_MODEL"
echo "  iOS: $IOS_VERSION"

# Buscar archivos IPA
echo ""
print_info "Buscando archivos IPA en el directorio actual..."
IPA_FILES=($(find . -maxdepth 1 -name "*.ipa" -type f))

if [ ${#IPA_FILES[@]} -eq 0 ]; then
    print_error "No se encontraron archivos .ipa en el directorio actual"
    echo ""
    echo "Coloca tu archivo .ipa aquí o especifica la ruta completa"
    exit 1
fi

# Mostrar archivos IPA encontrados
echo ""
echo "Archivos IPA encontrados:"
for i in "${!IPA_FILES[@]}"; do
    echo "  $((i+1)). ${IPA_FILES[$i]}"
done

# Seleccionar archivo
echo ""
if [ ${#IPA_FILES[@]} -eq 1 ]; then
    IPA_FILE="${IPA_FILES[0]}"
    print_info "Usando: $IPA_FILE"
else
    read -p "Selecciona el número del archivo a instalar (1-${#IPA_FILES[@]}): " SELECTION
    IPA_FILE="${IPA_FILES[$((SELECTION-1))]}"
fi

# Verificar que el archivo existe
if [ ! -f "$IPA_FILE" ]; then
    print_error "Archivo no encontrado: $IPA_FILE"
    exit 1
fi

# Instalar el IPA
echo ""
print_info "Instalando $IPA_FILE..."
echo ""

if ideviceinstaller install "$IPA_FILE"; then
    echo ""
    print_success "¡Aplicación instalada exitosamente!"
    echo ""
    print_info "La app debería aparecer en la pantalla de inicio de tu iPhone"
else
    echo ""
    print_error "Error al instalar la aplicación"
    echo ""
    echo "Posibles causas:"
    echo "  - El IPA no está firmado correctamente"
    echo "  - El UDID del dispositivo no está en el perfil de aprovisionamiento"
    echo "  - El certificado ha expirado"
    echo "  - Necesitas un perfil de desarrollo válido"
    exit 1
fi

# Mostrar apps instaladas
echo ""
read -p "¿Quieres ver las apps instaladas? (s/n): " SHOW_APPS
if [[ $SHOW_APPS =~ ^[Ss]$ ]]; then
    echo ""
    print_info "Apps instaladas (puede tardar un momento)..."
    ideviceinstaller list --user
fi

echo ""
print_success "Proceso completado"
