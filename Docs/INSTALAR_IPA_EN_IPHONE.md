# Guía: Instalar IPA en iPhone desde Linux

Esta guía explica cómo compilar y instalar una app Flutter en tu iPhone físico usando Codemagic y Linux.

## Requisitos Previos

- Cuenta de Apple Developer
- iPhone conectado por USB a tu máquina Linux
- `ideviceinstaller` instalado en Linux
- Proyecto configurado en Codemagic

## Parte 1: Configuración en Apple Developer

### 1.1 Registrar tu iPhone

1. Conecta tu iPhone y obtén el UDID:
   ```bash
   idevice_id -l
   ```

2. Ve a https://developer.apple.com/account/resources/devices
3. Haz clic en "+" para agregar un nuevo dispositivo
4. Ingresa:
   - Nombre: "iPhone [modelo] - [tu nombre]"
   - UDID: el que obtuviste del comando anterior
5. Registra el dispositivo

### 1.2 Crear Certificado de Desarrollo

1. Genera el CSR desde Linux:
   ```bash
   ./generar_csr_apple.sh
   ```
   - Completa la información solicitada
   - Guarda el archivo `.key` (clave privada) en lugar seguro

2. Ve a https://developer.apple.com/account/resources/certificates
3. Haz clic en "+" para crear un certificado
4. Selecciona "iOS App Development"
5. Sube el archivo `.certSigningRequest` generado
6. Descarga el certificado `.cer`

7. Convierte el certificado a formato P12:
   ```bash
   ./convertir_certificado_apple.sh
   ```
   - Crea una contraseña (la necesitarás para Codemagic)
   - Guarda el archivo `.p12` generado

### 1.3 Crear Provisioning Profile de Development

1. Ve a https://developer.apple.com/account/resources/profiles
2. Haz clic en "+" para crear un perfil
3. Selecciona "iOS App Development"
4. Selecciona tu App ID (ej: `ar.manosdelpueblo.app`)
5. Selecciona el certificado de desarrollo que creaste
6. Selecciona tu iPhone registrado
7. Dale un nombre descriptivo (ej: "Mi App Dev Profile")
8. Descarga el archivo `.mobileprovision`

## Parte 2: Configuración en Codemagic

### 2.1 Subir Certificados y Perfiles

1. Ve a tu proyecto en Codemagic
2. Settings → Code signing identities
3. En la pestaña "iOS certificates":
   - Sube el archivo `.p12`
   - Ingresa la contraseña que creaste
4. En la pestaña "iOS provisioning profiles":
   - Sube el archivo `.mobileprovision`

### 2.2 Configurar Workflow de Development

En tu archivo `codemagic.yaml`, asegúrate de tener un workflow con:

```yaml
ios-development:
  name: iOS Development
  environment:
    ios_signing:
      distribution_type: development  # ← Importante: development, no app_store
      bundle_identifier: tu.bundle.id
```

### 2.3 Ejecutar el Build

1. En Codemagic, selecciona el workflow "iOS Development"
2. Haz clic en "Start new build"
3. Espera a que compile
4. Descarga el archivo `.ipa` generado

## Parte 3: Instalar en iPhone desde Linux

### 3.1 Verificar Conexión

```bash
# Ver dispositivos conectados
idevice_id -l

# Ver información del dispositivo
ideviceinfo -k DeviceName
ideviceinfo -k ProductVersion
```

### 3.2 Instalar el IPA

Opción A - Usando el script:
```bash
./instalar_ipa_iphone.sh
```

Opción B - Comando directo:
```bash
ideviceinstaller install tu_app.ipa
```

### 3.3 Verificar Instalación

```bash
# Ver apps instaladas
ideviceinstaller list --user
```

## Comandos Útiles

```bash
# Desinstalar una app
ideviceinstaller uninstall com.tu.bundle.id

# Actualizar una app existente
ideviceinstaller upgrade tu_app.ipa

# Emparejar dispositivo (primera vez)
idevicepair pair
```

## Solución de Problemas

### Error: "ApplicationVerificationFailed"
- El UDID del iPhone no está en el provisioning profile
- El certificado ha expirado
- El IPA no está firmado correctamente
- **Solución:** Verifica que el dispositivo esté registrado y el provisioning profile lo incluya

### Error: "No se detectó ningún dispositivo"
- iPhone no conectado o bloqueado
- No has aceptado "Confiar en este ordenador"
- **Solución:** Conecta el iPhone, desbloquéalo y ejecuta `idevicepair pair`

### Error: "could not locate iTunesMetadata.plist"
- Es solo una advertencia, no afecta la instalación
- El IPA se instalará correctamente de todas formas

## Diferencias entre Distribution Types

| Type | Uso | Requiere Dispositivo Registrado |
|------|-----|--------------------------------|
| `development` | Instalar en dispositivos físicos de prueba | ✅ Sí |
| `app_store` | Subir a App Store / TestFlight | ❌ No |
| `ad_hoc` | Distribución limitada sin App Store | ✅ Sí |
| `enterprise` | Distribución interna empresarial | ❌ No |

## Resumen del Flujo Completo

1. **Apple Developer:**
   - Registrar dispositivo (UDID)
   - Crear certificado de desarrollo
   - Crear provisioning profile con el dispositivo

2. **Codemagic:**
   - Subir certificado (.p12)
   - Subir provisioning profile (.mobileprovision)
   - Configurar workflow con `distribution_type: development`
   - Compilar y descargar IPA

3. **Linux:**
   - Conectar iPhone
   - Instalar IPA con `ideviceinstaller`
   - Verificar instalación

## Scripts Incluidos

- `generar_csr_apple.sh` - Genera Certificate Signing Request
- `convertir_certificado_apple.sh` - Convierte .cer a .p12
- `instalar_ipa_iphone.sh` - Instala IPA en iPhone
- `redimensionar_para_apple.py` - Redimensiona capturas para App Store

## Notas Importantes

- Los certificados de desarrollo expiran en 1 año
- Los provisioning profiles expiran cuando expira el certificado
- Puedes registrar hasta 100 dispositivos por año por tipo (iPhone, iPad, etc.)
- La clave privada (.key) es crítica - guárdala en lugar seguro
- Sin la clave privada, el certificado es inútil
