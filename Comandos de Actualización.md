# 1. Compilar la versión Web (Base raíz para dominio .ar)
flutter build web --base-href "/" --release

# 2. Preparar la carpeta de publicación (Borrar vieja, crear nueva)
rm -rf docs
mkdir docs
cp -r build/web/* docs/

# 3. Restaurar el dominio CNAME (¡CRÍTICO!)
echo "manos-del-pueblo.ar" > docs/CNAME

# 4. Subir a GitHub
git add .
git commit -m "Actualización del sitio web"
git push