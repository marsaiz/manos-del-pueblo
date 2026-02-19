# 🚀 Configurar Codemagic para iOS

## ❌ Error Actual

```
1 validation error in codemagic.yaml: ios-release -> publishing -> app_store_connect -> 
For authentication using App Store Connect API the API key, key identifier and issuer 
identifier are all required.
```

## ✅ Solución

El archivo `codemagic.yaml` está correcto, pero necesitas configurar la **clave privada** en la interfaz web de Codemagic.

---

## 📋 Pasos para Configurar

### 1. Obtener la Clave de App Store Connect API

Si aún no tienes la clave:

1. Ve a [App Store Connect](https://appstoreconnect.apple.com/)
2. Inicia sesión con tu cuenta de Apple Developer
3. Ve a **Users and Access** (Usuarios y Acceso)
4. Haz clic en la pestaña **Keys** (Claves)
5. Haz clic en el botón **+** para generar una nueva clave
6. Dale un nombre (ej: "Codemagic CI/CD")
7. Selecciona el rol: **App Manager** o **Admin**
8. Haz clic en **Generate** (Generar)
9. **Descarga la clave** (archivo .p8) - Solo puedes descargarla una vez
10. Anota el **Key ID** y el **Issuer ID**

### 2. Configurar en Codemagic

1. Ve a [Codemagic](https://codemagic.io/)
2. Selecciona tu proyecto "Manos del Pueblo"
3. Ve a **Settings** (Configuración)
4. Haz clic en **Environment variables** (Variables de entorno)
5. Agrega la siguiente variable:

   **Nombre**: `APP_STORE_CONNECT_PRIVATE_KEY`
   
   **Valor**: Abre el archivo .p8 descargado y copia todo su contenido (incluyendo las líneas `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`)
   
   **Grupo**: `appstore` (debe coincidir con el grupo en codemagic.yaml)
   
   **Secure**: ✅ Marca esta opción (para que sea una variable segura)

6. Haz clic en **Add** (Agregar)

### 3. Verificar las Variables

Asegúrate de que estas variables estén configuradas en tu archivo `codemagic.yaml`:

```yaml
vars:
  APP_STORE_CONNECT_ISSUER_ID: "56ae558b-a2e0-4e17-9574-70197f224ca4"
  APP_STORE_CONNECT_KEY_ID: "N33443FRDZ"
```

✅ Estas ya están en tu archivo, así que no necesitas cambiar nada.

---

## 🔧 Archivo codemagic.yaml Actual

Tu archivo está **correcto**. La configuración es:

```yaml
publishing:
  app_store_connect:
    api_key:
      key_id: "$APP_STORE_CONNECT_KEY_ID"           # ✅ Definido en vars
      issuer_id: "$APP_STORE_CONNECT_ISSUER_ID"     # ✅ Definido en vars
      private_key: "$APP_STORE_CONNECT_PRIVATE_KEY" # ⚠️ Debe estar en Codemagic web
    submit_to_testflight: true
```

---

## 📝 Resumen de Variables

| Variable | Ubicación | Valor |
|----------|-----------|-------|
| `APP_STORE_CONNECT_KEY_ID` | codemagic.yaml | `N33443FRDZ` |
| `APP_STORE_CONNECT_ISSUER_ID` | codemagic.yaml | `56ae558b-a2e0-4e17-9574-70197f224ca4` |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Codemagic Web UI | Contenido del archivo .p8 |

---

## 🎯 Alternativa: Usar Grupo de Variables

Si prefieres, puedes mover todas las variables a la interfaz web de Codemagic:

### En Codemagic Web UI:

Crea un grupo llamado `appstore` con estas 3 variables:

1. **APP_STORE_CONNECT_KEY_ID**
   - Valor: `N33443FRDZ`
   - Secure: No

2. **APP_STORE_CONNECT_ISSUER_ID**
   - Valor: `56ae558b-a2e0-4e17-9574-70197f224ca4`
   - Secure: No

3. **APP_STORE_CONNECT_PRIVATE_KEY**
   - Valor: Contenido del archivo .p8
   - Secure: ✅ Sí

### En codemagic.yaml:

Elimina la sección `vars` y deja solo:

```yaml
environment:
  flutter: stable
  xcode: latest
  groups:
    - appstore  # Esto cargará todas las variables del grupo
  ios_signing:
    distribution_type: app_store
    bundle_identifier: ar.manosdelpueblo.app
```

---

## 🔍 Verificación

Después de configurar la clave privada:

1. Guarda los cambios en Codemagic
2. Haz un nuevo commit en tu repositorio
3. Codemagic debería iniciar el build automáticamente
4. Verifica que el build pase sin errores

---

## 🐛 Troubleshooting

### Error: "Invalid API Key"

- Verifica que hayas copiado todo el contenido del archivo .p8
- Asegúrate de incluir las líneas `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`
- Verifica que el Key ID y el Issuer ID sean correctos

### Error: "Insufficient permissions"

- La clave de API debe tener rol de **App Manager** o **Admin**
- Regenera la clave con los permisos correctos

### Error: "Key not found"

- Verifica que el nombre de la variable sea exactamente `APP_STORE_CONNECT_PRIVATE_KEY`
- Verifica que esté en el grupo `appstore`

---

## 📚 Referencias

- [Codemagic - App Store Connect API](https://docs.codemagic.io/yaml-publishing/app-store-connect/)
- [Apple - Creating API Keys](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)

---

## ✅ Checklist

- [ ] Generar clave de App Store Connect API (.p8)
- [ ] Anotar Key ID y Issuer ID
- [ ] Agregar `APP_STORE_CONNECT_PRIVATE_KEY` en Codemagic web
- [ ] Marcar la variable como "Secure"
- [ ] Asignar al grupo `appstore`
- [ ] Hacer commit y verificar el build

---

¡Listo! Una vez que agregues la clave privada en Codemagic, el error desaparecerá. 🎉
