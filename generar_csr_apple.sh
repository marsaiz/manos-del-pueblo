#!/bin/bash
# Script para generar Certificate Signing Request (CSR) para Apple Developer

set -e

echo "=========================================="
echo "  Generador de CSR para Apple Developer"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Solicitar información
echo -e "${YELLOW}Ingresa la siguiente información:${NC}"
echo ""

read -p "Tu nombre completo (ej: Marcelo Aberlardo Saiz): " NOMBRE
read -p "Tu email (ej: tu@email.com): " EMAIL
read -p "País (código de 2 letras, ej: AR): " PAIS
read -p "Ciudad (ej: Buenos Aires): " CIUDAD
read -p "Provincia/Estado (ej: Buenos Aires): " PROVINCIA

# Nombre de archivos
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
KEY_FILE="apple_dev_${TIMESTAMP}.key"
CSR_FILE="apple_dev_${TIMESTAMP}.certSigningRequest"

echo ""
echo "Generando clave privada y CSR..."
echo ""

# Generar clave privada y CSR
openssl req -new -newkey rsa:2048 -nodes \
  -keyout "$KEY_FILE" \
  -out "$CSR_FILE" \
  -subj "/emailAddress=$EMAIL/CN=$NOMBRE/C=$PAIS/ST=$PROVINCIA/L=$CIUDAD"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ CSR generado exitosamente${NC}"
    echo ""
    echo "Archivos creados:"
    echo "  - Clave privada: $KEY_FILE"
    echo "  - CSR: $CSR_FILE"
    echo ""
    echo "=========================================="
    echo "IMPORTANTE - GUARDA ESTOS ARCHIVOS"
    echo "=========================================="
    echo ""
    echo "1. GUARDA LA CLAVE PRIVADA ($KEY_FILE) en un lugar seguro"
    echo "   ¡La necesitarás para usar el certificado!"
    echo ""
    echo "2. Sube el archivo CSR ($CSR_FILE) a Apple Developer:"
    echo "   - Haz clic en 'Choose File' en la página de Apple"
    echo "   - Selecciona: $CSR_FILE"
    echo "   - Haz clic en 'Continue'"
    echo ""
    echo "3. Descarga el certificado (.cer) que Apple generará"
    echo ""
    echo "4. Convierte el certificado a formato .p12 ejecutando:"
    echo "   ./convertir_certificado_apple.sh"
    echo ""
    
    # Crear script de conversión
    cat > convertir_certificado_apple.sh << 'CONVERSION_SCRIPT'
#!/bin/bash
# Script para convertir certificado de Apple a formato P12

set -e

echo "=========================================="
echo "  Convertir certificado Apple a P12"
echo "=========================================="
echo ""

# Buscar archivos
KEY_FILES=($(ls -t apple_dev_*.key 2>/dev/null))
CER_FILES=($(ls -t *.cer 2>/dev/null))

if [ ${#KEY_FILES[@]} -eq 0 ]; then
    echo "Error: No se encontró archivo de clave privada (.key)"
    exit 1
fi

if [ ${#CER_FILES[@]} -eq 0 ]; then
    echo "Error: No se encontró certificado descargado (.cer)"
    echo "Descarga el certificado de Apple Developer primero"
    exit 1
fi

KEY_FILE="${KEY_FILES[0]}"
CER_FILE="${CER_FILES[0]}"

echo "Usando:"
echo "  Clave privada: $KEY_FILE"
echo "  Certificado: $CER_FILE"
echo ""

# Nombre del archivo de salida
P12_FILE="${CER_FILE%.cer}.p12"

# Convertir CER a PEM
PEM_FILE="${CER_FILE%.cer}.pem"
openssl x509 -in "$CER_FILE" -inform DER -out "$PEM_FILE" -outform PEM

echo "Ahora necesitas crear una contraseña para proteger el archivo P12"
echo "Esta contraseña la necesitarás cuando subas el certificado a Codemagic"
echo ""

# Crear P12
openssl pkcs12 -export -out "$P12_FILE" \
  -inkey "$KEY_FILE" \
  -in "$PEM_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Certificado P12 creado: $P12_FILE"
    echo ""
    echo "Ahora puedes:"
    echo "1. Subir $P12_FILE a Codemagic (Code signing identities)"
    echo "2. Usar la contraseña que acabas de crear"
    echo ""
    # Limpiar archivo temporal
    rm "$PEM_FILE"
else
    echo "Error al crear el archivo P12"
    exit 1
fi
CONVERSION_SCRIPT
    
    chmod +x convertir_certificado_apple.sh
    
    echo "Script de conversión creado: convertir_certificado_apple.sh"
    echo ""
else
    echo "Error al generar el CSR"
    exit 1
fi
