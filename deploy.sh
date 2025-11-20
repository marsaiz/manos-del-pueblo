#!/bin/bash

# --- CONFIGURACIÓN ---
DOMINIO="manos-del-pueblo.ar"

# Si ocurre un error en cualquier paso, el script se detiene (Seguridad)
set -e

# Colores para que se vea bonito
VERDE='\033[0;32m'
AZUL='\033[0;34m'
NC='\033[0m' # Sin color

echo -e "${AZUL}🚀 Iniciando despliegue de $DOMINIO...${NC}"

# 1. COMPILAR
echo -e "${AZUL}🔨 Compilando versión Web...${NC}"
flutter build web --base-href "/" --release

# 2. PREPARAR CARPETA DOCS
echo -e "${AZUL}📂 Actualizando carpeta /docs...${NC}"
rm -rf docs
mkdir docs
cp -r build/web/* docs/

# 3. RESTAURAR CNAME (Vital)
echo -e "${AZUL}🌐 Restaurando configuración de dominio...${NC}"
echo "$DOMINIO" > docs/CNAME

# 4. SUBIR A GITHUB
echo -e "${AZUL}📦 Subiendo cambios a GitHub...${NC}"

# Pide un mensaje para el commit (si no escribes nada, usa uno por defecto)
read -p "Escribe un mensaje para el commit (Enter para usar por defecto): " MENSAJE
MENSAJE=${MENSAJE:-"Botón \"Compartir\" (Share): Fundamental. Que alguien vea un cuenco y pueda mandárselo a su tía por WhatsApp con un clic: \"Mira qué lindo esto para tu cocina\""}

git add .
git commit -m "$MENSAJE"
git push

echo -e "${VERDE}✅ ¡ÉXITO! Tu sitio se ha actualizado correctamente.${NC}"
echo -e "${VERDE}👉 Visita: https://$DOMINIO${NC}"