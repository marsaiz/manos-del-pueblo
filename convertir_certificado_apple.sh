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
