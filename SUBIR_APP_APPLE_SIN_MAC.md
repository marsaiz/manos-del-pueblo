# 📱 Guía Completa: Subir App a Apple Store sin Mac

**Proyecto**: Manos del Pueblo  
**Bundle ID**: `ar.manosdelpueblo.app`  
**Plataforma**: iOS usando Codemagic CI/CD  
**Requisitos**: Cuenta Apple Developer ($99/año)

---

## ✅ Estado Actual

- ✅ Compilación exitosa con `ios-dry-run` (sin firma)
- ✅ Código Flutter sin errores
- ✅ CocoaPods configurado correctamente
- ✅ Integración de App Store Connect API configurada en Codemagic
- ⏳ Pendiente: Configurar code signing y subir a TestFlight

---

## 📋 Índice

1. [Prerequisitos](#prerequisitos)
2. [Paso 1: Verificar App ID en Apple Developer](#paso-1-verificar-app-id)
3. [Paso 2: Limpiar Provisioning Profiles Manuales](#paso-2-limpiar-provisioning-profiles)
4. [Paso 3: Configurar App en App Store Connect](#paso-3-configurar-app-store-connect)
5. [Paso 4: Actualizar codemagic.yaml](#paso-4-actualizar-codemagic)
6. [Paso 5: Ejecutar Build de Producción](#paso-5-ejecutar-build)
7. [Paso 6: Verificar en TestFlight](#paso-6-testflight)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisitos

### Cuentas y Accesos

- [ ] Cuenta Apple Developer activa ($99/año)
- [ ] Acceso a [developer.apple.com](https://developer.apple.com)
- [ ] Acceso a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Cuenta Codemagic con repositorio conectado
- [ ] Integración "codemagic" de App Store Connect API configurada

### Información Necesaria

- [ ] **Bundle ID**: `ar.manosdelpueblo.app`
- [ ] **Team ID**: `S2668973BN`
- [ ] **App Store Connect Issuer ID**: `56ae558b-a2e0-4e17-9574-70197f224ca4`
- [ ] **App Store Connect Key ID**: `N33443FRDZ` (integración "codemagic")

---

## Paso 1: Verificar App ID

### 1.1 Acceder a Apple Developer

```
URL: https://developer.apple.com/account/resources/identifiers/list
```

### 1.2 Verificar que existe el App ID

Busca en la lista:
- **Identifier**: `ar.manosdelpueblo.app`
- **Name**: Manos del Pueblo
- **Type**: App

### 1.3 Si NO existe, créalo

1. Haz clic en el botón **+** (arriba a la derecha)
2. Selecciona **App IDs** → **Continue**
3. Selecciona **App** → **Continue**
4. Completa:
   - **Description**: `Manos del Pueblo`
   - **Bundle ID**: Explicit → `ar.manosdelpueblo.app`
   - **Capabilities**: 
     - ✅ Push Notifications (si usas Firebase)
     - ✅ Associated Domains (si usas deep links)
     - Deja las demás por defecto
5. **Continue** → **Register**

**✅ Checkpoint**: El App ID `ar.manosdelpueblo.app` debe aparecer en la lista

---

## Paso 2: Limpiar Provisioning Profiles

### 2.1 ¿Por qué este paso?

El provisioning profile actual fue creado con un certificado manual que Codemagic no puede usar. Necesitamos eliminarlo para que Codemagic cree uno nuevo automáticamente.

### 2.2 Eliminar Provisioning Profile Manual

```
URL: https://developer.apple.com/account/resources/profiles/list
```

1. Busca: **"Manos del Pueblo AppStore"**
2. Haz clic en él
3. Haz clic en **"Delete"** (eliminar)
4. Confirma la eliminación

**⚠️ Nota**: Esto NO afectará a GulApp ni a otras apps. Solo elimina el profile de Manos del Pueblo.

### 2.3 Verificar Certificados (Opcional)

```
URL: https://developer.apple.com/account/resources/certificates/list
```

Deberías ver:
- Certificado(s) de distribución existentes (pueden quedar, no hay problema)
- Codemagic creará uno nuevo si es necesario

**Apple permite hasta 3 certificados de distribución activos simultáneamente.**

**✅ Checkpoint**: El provisioning profile "Manos del Pueblo AppStore" ya no debe aparecer en la lista

---

## Paso 3: Configurar App Store Connect

### 3.1 Crear la App en App Store Connect

```
URL: https://appstoreconnect.apple.com/apps
```

1. Haz clic en el botón **+** → **New App**
2. Completa el formulario:

**Platforms**: ✅ iOS

**Name**: `Manos del Pueblo`  
(Este es el nombre que verán los usuarios en la App Store)

**Primary Language**: Spanish (Spain) o Spanish (Latin America)

**Bundle ID**: Selecciona `ar.manosdelpueblo.app` del dropdown

**SKU**: `manosdelpueblo001`  
(Identificador interno único, puede ser cualquier string)

**User Access**: Full Access

3. Haz clic en **Create**

### 3.2 Anotar el App Store ID

Una vez creada la app, verás una URL como:
```
https://appstoreconnect.apple.com/apps/1234567890/appstore
```

El número `1234567890` es tu **App Store Apple ID**. Anótalo.

**✅ Checkpoint**: La app "Manos del Pueblo" debe aparecer en App Store Connect con estado "Prepare for Submission"

---

## Paso 4: Actualizar codemagic.yaml

### 4.1 Actualizar App Store Apple ID

Abre el archivo `codemagic.yaml` y busca esta línea:

```yaml
APP_STORE_APPLE_ID: 1234567890  # Reemplazar con tu App Store ID
```

Reemplázala con el ID real que anotaste en el paso 3.2:

```yaml
APP_STORE_APPLE_ID: 1234567890  # Reemplazar con el ID real
```

### 4.2 Actualizar Email de Notificaciones

Busca:

```yaml
recipients:
  - tu-email@ejemplo.com  # Reemplazar con tu email
```

Reemplaza con tu email real:

```yaml
recipients:
  - tu-email-real@gmail.com
```

### 4.3 Hacer Commit y Push

```bash
git add codemagic.yaml
git commit -m "Configurar App Store ID y email para iOS release"
git push origin main
```

**✅ Checkpoint**: Los cambios deben estar en GitHub/repositorio remoto

---

## Paso 5: Ejecutar Build de Producción

### 5.1 Acceder a Codemagic

```
URL: https://codemagic.io/apps
```

1. Selecciona el proyecto **manos-del-pueblo**
2. Haz clic en **Start new build**

### 5.2 Seleccionar Workflow

En el diálogo de configuración:
- **Branch**: `main`
- **Workflow**: Selecciona **`ios-release (iOS Release)`**
- Haz clic en **Start new build**

### 5.3 Monitorear el Build

El build pasará por estas fases (15-25 minutos):

```
1. ✅ Checkout repository
2. ✅ Install Flutter SDK
3. ✅ Flutter pub get
4. ✅ Install CocoaPods dependencies
5. ✅ Flutter analyze
6. 🔑 Add certificates to keychain
   → Codemagic descargará/creará certificados automáticamente
7. 🔑 Set up code signing
   → Codemagic creará provisioning profile si no existe
8. ✅ Flutter build ipa
9. 📦 Upload to App Store Connect
10. ✅ Submit to TestFlight
```

### 5.4 Qué Esperar en el Paso de Code Signing

**Primera vez (sin certificado previo de Codemagic):**
```
→ Creating new distribution certificate...
→ Registering certificate with Apple...
→ Creating provisioning profile for ar.manosdelpueblo.app...
→ Downloading provisioning profile...
✅ Code signing configured successfully
```

**Builds subsecuentes:**
```
→ Using existing distribution certificate...
→ Downloading provisioning profile...
✅ Code signing configured successfully
```

### 5.5 Build Exitoso

Si todo va bien, verás al final:

```
✅ Build succeeded
✅ IPA generated: build/ios/ipa/manos_del_pueblo.ipa
✅ Uploaded to App Store Connect
✅ Submitted to TestFlight
📧 Email notification sent
```

**✅ Checkpoint**: El build debe completarse sin errores y mostrar "Build succeeded"

---

## Paso 6: Verificar en TestFlight

### 6.1 Acceder a TestFlight

```
URL: https://appstoreconnect.apple.com/apps
```

1. Selecciona **Manos del Pueblo**
2. Ve a la pestaña **TestFlight**

### 6.2 Esperar Procesamiento

Verás el build con estado:
```
Processing... ⏳
```

Esto puede tomar **10-30 minutos**. Apple está:
- Verificando el IPA
- Escaneando por malware
- Generando screenshots automáticos
- Preparando para distribución

### 6.3 Build Listo para Probar

Una vez procesado, el estado cambiará a:
```
Ready to Submit ✅
```

### 6.4 Agregar Información de Prueba (Primera vez)

Si es la primera vez que subes un build, Apple pedirá:

1. **What to Test**: Descripción de qué probar en esta versión
   ```
   Primera versión de Manos del Pueblo. 
   Probar navegación, visualización de productos y perfiles de artesanos.
   ```

2. **Export Compliance**: ¿Usa encriptación?
   - Si solo usas HTTPS: **No** (la encriptación estándar no cuenta)
   - Si usas encriptación custom: **Yes** (y completa formulario)

3. **Advertising Identifier (IDFA)**: ¿Usa publicidad?
   - Si no usas ads: **No**
   - Si usas Google Ads, Facebook Ads, etc: **Yes**

### 6.5 Invitar Testers

1. Ve a **TestFlight** → **Internal Testing**
2. Haz clic en **+** para crear un grupo de testers
3. Nombre del grupo: `Equipo Manos del Pueblo`
4. Agrega emails de testers
5. Los testers recibirán un email con link para instalar TestFlight

**✅ Checkpoint**: El build debe estar disponible en TestFlight y los testers pueden instalarlo

---

## Paso 7: Subir a App Store (Producción)

### 7.1 Completar Información de la App

En App Store Connect → **Manos del Pueblo** → **App Store**:

**Información Requerida:**

1. **Screenshots**: 
   - iPhone 6.7" (obligatorio): 1290 x 2796 px
   - iPhone 6.5" (obligatorio): 1242 x 2688 px
   - Mínimo 3 screenshots por tamaño

2. **App Preview** (opcional): Videos de demostración

3. **Description**: Descripción de la app (4000 caracteres max)

4. **Keywords**: Palabras clave para búsqueda (100 caracteres max)
   ```
   artesanos,artesanías,productos locales,comercio justo,hecho a mano
   ```

5. **Support URL**: URL de soporte
   ```
   https://manosdelpueblo.ar/soporte
   ```

6. **Marketing URL** (opcional): URL de marketing

7. **Privacy Policy URL**: URL de política de privacidad (obligatorio)
   ```
   https://manosdelpueblo.ar/privacidad
   ```

8. **Category**: 
   - Primary: Shopping
   - Secondary: Lifestyle (opcional)

9. **Age Rating**: Completar cuestionario

10. **App Icon**: 1024 x 1024 px (sin transparencia, sin bordes redondeados)

### 7.2 Seleccionar Build

1. En la sección **Build**, haz clic en **+ Select a build**
2. Selecciona el build que subiste a TestFlight
3. Guarda los cambios

### 7.3 Enviar para Revisión

1. Haz clic en **Submit for Review**
2. Responde las preguntas de Apple:
   - Export Compliance
   - Advertising Identifier
   - Content Rights
3. Haz clic en **Submit**

### 7.4 Tiempos de Revisión

- **Revisión de Apple**: 24-48 horas (promedio)
- **Estados posibles**:
  - Waiting for Review
  - In Review
  - Pending Developer Release (aprobada, esperando que la publiques)
  - Ready for Sale (publicada)
  - Rejected (con razones y posibilidad de apelar)

**✅ Checkpoint**: La app debe estar en estado "Waiting for Review" o posterior

---

## Troubleshooting

### Error: "No matching profiles found"

**Causa**: El provisioning profile no existe o no es compatible

**Solución**:
1. Verifica que eliminaste el provisioning profile manual (Paso 2)
2. Verifica que el App ID existe en Apple Developer (Paso 1)
3. Verifica que la integración de App Store Connect está activa en Codemagic
4. Reintenta el build

---

### Error: "Certificate not found"

**Causa**: Codemagic no puede crear certificados automáticamente

**Solución**:
1. Verifica que la API Key tiene permisos de "Certificates, Identifiers & Profiles"
2. Ve a Apple Developer → Keys → Verifica permisos de la clave
3. Si no tiene permisos, crea una nueva clave con permisos completos
4. Actualiza la integración en Codemagic con la nueva clave

---

### Error: "Export options plist not found"

**Causa**: Codemagic no pudo generar el archivo de configuración de exportación

**Solución**:
1. Verifica que `ios_signing` está configurado en `codemagic.yaml`
2. Verifica que `distribution_type: app_store` está presente
3. Verifica que `bundle_identifier` coincide con el App ID

---

### Error: "Build processing failed" en TestFlight

**Causa**: El IPA tiene problemas de configuración

**Soluciones comunes**:
1. **Missing Info.plist keys**: Agrega keys faltantes en `ios/Runner/Info.plist`
2. **Invalid bundle identifier**: Verifica que coincide en todos lados
3. **Missing icons**: Verifica que todos los tamaños de íconos existen
4. **Invalid provisioning profile**: Elimina y deja que Codemagic lo recree

---

### Build exitoso pero no aparece en TestFlight

**Causa**: El build está en procesamiento o falló validación

**Solución**:
1. Espera 30 minutos (procesamiento puede ser lento)
2. Revisa tu email por notificaciones de Apple
3. Ve a App Store Connect → Activity → Busca el build
4. Si dice "Invalid Binary", revisa los logs de Codemagic

---

### Error: "App Store Connect API authentication failed"

**Causa**: La integración de App Store Connect no está configurada correctamente

**Solución**:
1. Ve a Codemagic → Teams → Integrations
2. Verifica que la integración "codemagic" está activa
3. Verifica que el Issuer ID y Key ID son correctos
4. Si es necesario, recrea la integración con una nueva API key

---

## 📝 Checklist Final

Antes de ejecutar el build de producción:

- [ ] App ID `ar.manosdelpueblo.app` existe en Apple Developer
- [ ] Provisioning profile manual eliminado
- [ ] App creada en App Store Connect
- [ ] App Store Apple ID anotado y actualizado en `codemagic.yaml`
- [ ] Email actualizado en `codemagic.yaml`
- [ ] Cambios commiteados y pusheados a GitHub
- [ ] Integración "codemagic" activa en Codemagic
- [ ] Build `ios-dry-run` completado exitosamente

---

## 🎯 Flujo de Trabajo Recomendado

### Para cada nueva versión:

1. **Desarrollo local**:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

2. **Probar compilación** (sin firma):
   - Ejecutar workflow `ios-dry-run` en Codemagic
   - Verificar que no hay errores de compilación

3. **Actualizar versión** en `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+build_number
   ```

4. **Commit y push**:
   ```bash
   git add .
   git commit -m "Bump version to 1.0.1"
   git push
   ```

5. **Build de producción**:
   - Ejecutar workflow `ios-release` en Codemagic
   - Esperar a que suba a TestFlight

6. **Probar en TestFlight**:
   - Instalar en dispositivos reales
   - Verificar funcionalidad

7. **Enviar a revisión**:
   - Seleccionar build en App Store Connect
   - Submit for Review

---

## 📚 Referencias

- [Apple Developer Portal](https://developer.apple.com)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## 🆘 Soporte

Si encuentras problemas:

1. **Revisa los logs** en Codemagic (pestaña "Build logs")
2. **Busca el error específico** en esta guía de troubleshooting
3. **Verifica la configuración** paso a paso
4. **Consulta la documentación** de Codemagic para iOS

---

**Última actualización**: 16 de febrero de 2026  
**Versión**: 1.0  
**Proyecto**: Manos del Pueblo
