# Actualizar Versión Web - Manos del Pueblo

## Problema Identificado

La versión web está usando código desactualizado. Cuando se agrega un artesano desde la web, la imagen se guarda con el prefijo `new_` en lugar del ID correcto que empieza con `a`.

## Causa

La app móvil (Android/iOS) tiene el código corregido, pero la versión web no se ha recompilado y redesplegar después de la corrección.

---

## Solución: Recompilar y Redesplegar la Web

### Paso 1: Limpiar Build Anterior

```bash
flutter clean
```

### Paso 2: Obtener Dependencias

```bash
flutter pub get
```

### Paso 3: Compilar para Web (Producción)

```bash
flutter build web --release
```

Este comando genera los archivos optimizados en la carpeta `build/web/`

### Paso 4: Verificar Archivos Generados

Los archivos compilados estarán en:
```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
└── ...
```

### Paso 5: Desplegar a Firebase Hosting

Si estás usando Firebase Hosting:

```bash
firebase deploy --only hosting
```

O si tienes configurado un alias específico:

```bash
firebase deploy --only hosting:production
```

### Paso 6: Verificar el Despliegue

1. Abrir la URL de tu sitio web
2. Hacer **Ctrl + Shift + R** (o Cmd + Shift + R en Mac) para forzar recarga sin caché
3. Probar crear un artesano
4. Verificar en Firebase Storage que la carpeta se crea con el prefijo `a` correcto

---

## Comandos Completos (Copiar y Pegar)

```bash
# Limpiar y recompilar
flutter clean
flutter pub get
flutter build web --release

# Desplegar a Firebase
firebase deploy --only hosting

# O si prefieres desplegar todo (hosting + firestore + storage rules)
firebase deploy
```

---

## Verificación Post-Despliegue

### 1. Verificar Versión del Código

Abrir la consola del navegador (F12) y ejecutar:
```javascript
console.log(document.querySelector('meta[name="version"]'));
```

### 2. Limpiar Caché del Navegador

- **Chrome/Edge:** Ctrl + Shift + Delete → Seleccionar "Imágenes y archivos en caché" → Borrar
- **Firefox:** Ctrl + Shift + Delete → Seleccionar "Caché" → Borrar ahora
- **Safari:** Cmd + Option + E

### 3. Probar Funcionalidad

1. Ir a "Sobre Nosotros" → "Gestionar Artesanos"
2. Crear un nuevo artesano con foto
3. Verificar en Firebase Storage que la carpeta se llama `a[timestamp]` y NO `new_[timestamp]`

---

## Diferencias entre Web y App Móvil

| Aspecto | App Móvil (Android/iOS) | Web |
|---------|------------------------|-----|
| Actualización | Automática al instalar nueva versión | Requiere recompilación y redespliegue |
| Caché | Gestionado por el sistema operativo | Caché del navegador puede retener versión antigua |
| Código | Compilado nativamente | JavaScript generado estáticamente |
| Despliegue | Google Play / App Store | Firebase Hosting / Servidor web |

---

## Prevención Futura

### 1. Versionar el Build

Actualizar `pubspec.yaml` antes de cada despliegue:

```yaml
version: 1.0.1+2  # Incrementar el número después del +
```

### 2. Agregar Meta Tag de Versión

En `web/index.html`, agregar:

```html
<meta name="version" content="1.0.1">
```

### 3. Script de Despliegue Automático

Crear `deploy_web.sh`:

```bash
#!/bin/bash
echo "🧹 Limpiando build anterior..."
flutter clean

echo "📦 Obteniendo dependencias..."
flutter pub get

echo "🔨 Compilando para web..."
flutter build web --release

echo "🚀 Desplegando a Firebase..."
firebase deploy --only hosting

echo "✅ Despliegue completado!"
```

Dar permisos de ejecución:
```bash
chmod +x deploy_web.sh
```

Ejecutar:
```bash
./deploy_web.sh
```

---

## Troubleshooting

### Problema: Sigue mostrando versión antigua después de desplegar

**Solución:**
1. Verificar que `firebase deploy` se completó sin errores
2. Limpiar caché del navegador completamente
3. Probar en modo incógnito
4. Verificar la URL correcta (sin `/` al final puede causar caché)

### Problema: Error al compilar para web

**Solución:**
```bash
flutter doctor
flutter upgrade
flutter pub upgrade
flutter build web --release
```

### Problema: Firebase deploy falla

**Solución:**
```bash
firebase login
firebase use --add  # Seleccionar proyecto correcto
firebase deploy --only hosting
```

---

## Checklist de Despliegue Web

- [ ] Código actualizado en repositorio
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] `flutter build web --release` completado sin errores
- [ ] Archivos en `build/web/` generados correctamente
- [ ] `firebase deploy --only hosting` ejecutado
- [ ] Caché del navegador limpiado
- [ ] Funcionalidad probada en web
- [ ] Verificado en Firebase Storage que los IDs son correctos

---

**Fecha:** Febrero 2026  
**Última actualización:** Corrección del prefijo `new_` en artesanos
