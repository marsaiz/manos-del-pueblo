# 📱 Guía: Subir App a Google Play Store

**Proyecto**: Manos del Pueblo  
**Package Name**: `ar.manosdelpueblo.app`  
**Bundle**: `build/app/outputs/bundle/release/app-release.aab` (46MB)

---

## ✅ Estado Actual

- ✅ Android App Bundle compilado exitosamente
- ✅ App firmada con keystore de producción
- ✅ Keystore guardado en: `~/manos-del-pueblo-upload-keystore.jks`
- ⏳ Pendiente: Subir a Google Play Console

---

## 📋 Prerequisitos

### Cuentas y Accesos

- [ ] Cuenta Google Play Developer ($25 pago único)
- [ ] Acceso a [play.google.com/console](https://play.google.com/console)

### Archivos Necesarios

- [x] **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
- [x] **Keystore**: `~/manos-del-pueblo-upload-keystore.jks`
- [x] **Ícono**: 512x512 px (PNG, 32-bit)
- [x] **Feature Graphic**: 1024x500 px (PNG o JPG)
- [x] **Screenshots**: Mínimo 2 por dispositivo
- [x] **Política de Privacidad**: URL pública

---

## Paso 1: Crear la App en Google Play Console

### 1.1 Acceder a Google Play Console

```
URL: https://play.google.com/console
```

1. Inicia sesión con tu cuenta de Google Play Developer
2. Haz clic en **"Create app"** (Crear aplicación)

### 1.2 Completar Información Básica

**App name**: `Manos del Pueblo`

**Default language**: Spanish (Spain) - es-ES

**App or game**: App

**Free or paid**: Free

**Declarations**:
- ✅ I declare that this app complies with Google Play's Developer Program Policies
- ✅ I declare that this app complies with US export laws

3. Haz clic en **"Create app"**

---

## Paso 2: Configurar la Ficha de Play Store

### 2.1 Información Principal

Ve a **Dashboard** → **Set up your app** → **Main store listing**

**App name**: `Manos del Pueblo`

**Short description** (80 caracteres max):
```
Descubre y compra artesanías únicas hechas por artesanos locales
```

**Full description** (4000 caracteres max):
```
Manos del Pueblo conecta a artesanos locales con personas que valoran el trabajo hecho a mano y el comercio justo.

🎨 Descubre artesanías únicas
Explora una amplia variedad de productos artesanales: cerámica, textiles, joyería, decoración y más.

👥 Conoce a los artesanos
Cada producto cuenta la historia de su creador. Conoce a los artesanos, su técnica y su pasión.

🛒 Compra directamente
Apoya el comercio justo comprando directamente a los artesanos, sin intermediarios.

✨ Características:
• Catálogo completo de productos artesanales
• Perfiles detallados de artesanos
• Búsqueda y filtros por categoría
• Información de contacto directo
• Galería de fotos de alta calidad

Manos del Pueblo es más que una app de compras, es una comunidad que valora el trabajo artesanal y apoya a los creadores locales.
```

### 2.2 Recursos Gráficos

**App icon** (512x512 px):
- Formato: PNG de 32 bits
- Sin transparencia
- Debe ser el mismo que `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` escalado

**Feature graphic** (1024x500 px):
- Formato: PNG o JPG
- Aparece en la parte superior de la ficha de Play Store
- Debe ser llamativo y representar la app

**Phone screenshots** (mínimo 2, máximo 8):
- Formato: PNG o JPG
- Tamaño recomendado: 1080x1920 px (16:9)
- Captura pantallas principales de la app

**Tablet screenshots** (opcional pero recomendado):
- 7-inch: 1024x600 px
- 10-inch: 1920x1200 px

### 2.3 Categorización

**App category**: Shopping

**Tags** (opcional): artesanías, artesanos, hecho a mano, comercio justo

**Contact details**:
- Email: tu-email@ejemplo.com
- Phone: (opcional)
- Website: https://manosdelpueblo.ar (si tienes)

**Privacy policy URL** (obligatorio):
```
https://manosdelpueblo.ar/privacidad
```

Si no tienes sitio web, puedes usar:
- Google Docs (hacer público)
- GitHub Pages
- Servicios gratuitos como Termly

---

## Paso 3: Configurar Contenido de la App

### 3.1 Content Rating

Ve a **Dashboard** → **Content rating**

1. Haz clic en **"Start questionnaire"**
2. Selecciona **"Shopping"** como categoría
3. Responde las preguntas:
   - ¿Contiene violencia? No
   - ¿Contiene contenido sexual? No
   - ¿Contiene lenguaje ofensivo? No
   - ¿Permite interacción entre usuarios? No (o Sí si tiene chat)
   - ¿Comparte ubicación del usuario? No (o Sí si usas GPS)
4. Haz clic en **"Save questionnaire"**
5. Haz clic en **"Calculate rating"**

Resultado esperado: **PEGI 3** / **Everyone**

### 3.2 Target Audience

Ve a **Dashboard** → **Target audience and content**

**Target age groups**:
- ✅ 18 and over (recomendado para apps de compras)

**Appeal to children**: No

### 3.3 News App

**Is this a news app?**: No

### 3.4 COVID-19 Contact Tracing

**Is this a COVID-19 contact tracing or status app?**: No

### 3.5 Data Safety

Ve a **Dashboard** → **Data safety**

Completa el formulario sobre qué datos recoges:

**¿Recoges o compartes datos de usuario?**
- Si usas Firebase Analytics: Sí
- Si no recoges datos: No

Si recoges datos, especifica:
- Tipo de datos (ej: nombre, email, ubicación)
- Propósito (ej: funcionalidad de la app, analytics)
- Si se comparten con terceros
- Si el usuario puede solicitar eliminación

**Prácticas de seguridad**:
- ✅ Los datos se cifran en tránsito (HTTPS)
- ✅ Los usuarios pueden solicitar eliminación de datos
- ✅ Sigues la política de Familias de Play (si aplica)

---

## Paso 4: Subir el App Bundle

### 4.1 Crear una Release de Producción

Ve a **Dashboard** → **Production** → **Create new release**

### 4.2 Subir el App Bundle

1. Haz clic en **"Upload"**
2. Selecciona el archivo: `build/app/outputs/bundle/release/app-release.aab`
3. Espera a que se suba (puede tomar 2-5 minutos)

### 4.3 Completar Información de la Release

**Release name**: `1.0.0 (1)` (se genera automáticamente)

**Release notes** (en español):
```
Primera versión de Manos del Pueblo

✨ Características:
• Catálogo completo de productos artesanales
• Perfiles de artesanos con sus historias
• Búsqueda y filtros por categoría
• Galería de fotos de alta calidad
• Información de contacto directo

¡Descubre el trabajo de artesanos locales!
```

### 4.4 Revisar y Guardar

1. Revisa que toda la información sea correcta
2. Haz clic en **"Save"**
3. Haz clic en **"Review release"**

---

## Paso 5: Enviar para Revisión

### 5.1 Completar Checklist

Google Play Console mostrará un checklist de tareas pendientes:

- [ ] Main store listing (Paso 2)
- [ ] Content rating (Paso 3.1)
- [ ] Target audience (Paso 3.2)
- [ ] Data safety (Paso 3.5)
- [ ] App access (si tu app requiere login)
- [ ] Ads (si tu app muestra publicidad)
- [ ] App content (declaraciones adicionales)

### 5.2 Enviar para Revisión

Una vez completado el checklist:

1. Ve a **Dashboard** → **Production**
2. Haz clic en **"Send X changes for review"**
3. Confirma el envío

---

## Paso 6: Proceso de Revisión

### 6.1 Tiempos de Revisión

- **Revisión de Google**: 1-7 días (promedio 2-3 días)
- **Primera app**: Puede tomar más tiempo (hasta 2 semanas)

### 6.2 Estados Posibles

**In review**: Google está revisando tu app

**Approved**: ¡Aprobada! La app se publicará automáticamente

**Changes requested**: Google solicita cambios
- Revisa el email de Google
- Corrige los problemas
- Vuelve a enviar

**Rejected**: La app fue rechazada
- Revisa las razones en el email
- Corrige los problemas
- Apela si crees que es un error

### 6.3 Notificaciones

Recibirás emails en:
- Cuando la revisión comience
- Cuando la app sea aprobada/rechazada
- Cuando la app esté publicada

---

## Paso 7: App Publicada

### 7.1 Verificar Publicación

Una vez aprobada:

```
URL: https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
```

La app estará disponible en Google Play Store en 1-2 horas.

### 7.2 Compartir la App

**Link directo**:
```
https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app
```

**Badge de Google Play**:
Descarga desde: https://play.google.com/intl/en_us/badges/

---

## 📝 Información del Keystore

**⚠️ IMPORTANTE: Guarda esta información en un lugar seguro**

```
Keystore file: ~/manos-del-pueblo-upload-keystore.jks
Store password: manosdelpueblo2026
Key alias: upload
Key password: manosdelpueblo2026
```

**Backup del keystore**:
```bash
# Copiar a carpeta segura
cp ~/manos-del-pueblo-upload-keystore.jks ~/Proyectos/manos-del-pueblo-archivos/

# O subir a Google Drive / Dropbox (recomendado)
```

**⚠️ Si pierdes el keystore, NO podrás actualizar la app en el futuro.**

---

## 🔄 Actualizar la App (Futuras Versiones)

### 1. Actualizar versión en pubspec.yaml

```yaml
version: 1.0.1+2  # version+buildNumber
```

### 2. Compilar nuevo bundle

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### 3. Subir a Google Play Console

1. Ve a **Production** → **Create new release**
2. Sube el nuevo `.aab`
3. Agrega release notes
4. **Review release** → **Start rollout to Production**

### 4. Rollout Gradual (Recomendado)

Google Play permite rollout gradual:
- 20% de usuarios → Esperar 1-2 días
- 50% de usuarios → Esperar 1-2 días
- 100% de usuarios

Esto permite detectar problemas antes de afectar a todos.

---

## 🐛 Troubleshooting

### Error: "Upload failed - Duplicate version code"

**Causa**: Ya existe un bundle con ese versionCode

**Solución**:
1. Incrementa `versionCode` en `pubspec.yaml`
2. Recompila el bundle
3. Vuelve a subir

---

### Error: "You need to use a different package name"

**Causa**: El package name ya está en uso

**Solución**:
1. Cambia `applicationId` en `android/app/build.gradle.kts`
2. Actualiza en todos los archivos de configuración
3. Recompila

---

### Error: "This release is not compliant with Google Play policies"

**Causa**: Falta completar alguna sección obligatoria

**Solución**:
1. Revisa el checklist en Dashboard
2. Completa todas las secciones marcadas
3. Vuelve a enviar

---

### Error: "Your app contains code that may be used to harm users"

**Causa**: Google detectó código sospechoso

**Solución**:
1. Revisa los permisos en `AndroidManifest.xml`
2. Elimina permisos innecesarios
3. Explica en "App content" por qué necesitas ciertos permisos
4. Apela si es un falso positivo

---

## 📚 Recursos

- [Google Play Console](https://play.google.com/console)
- [Políticas de Google Play](https://play.google.com/about/developer-content-policy/)
- [Guía de Lanzamiento](https://developer.android.com/distribute/best-practices/launch)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

---

## ✅ Checklist Final

Antes de enviar para revisión:

- [ ] App Bundle compilado y firmado
- [ ] Keystore guardado en lugar seguro
- [ ] Main store listing completo (textos, imágenes)
- [ ] Content rating completado
- [ ] Target audience configurado
- [ ] Data safety completado
- [ ] Privacy policy URL configurada
- [ ] Screenshots subidos (mínimo 2)
- [ ] Feature graphic subido
- [ ] App icon subido
- [ ] Release notes escritos
- [ ] Toda la información revisada

---

**Última actualización**: 16 de febrero de 2026  
**Versión**: 1.0  
**Proyecto**: Manos del Pueblo
