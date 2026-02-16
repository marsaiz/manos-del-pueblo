# 🚀 Pasos Rápidos: iOS a App Store sin Mac

**Para**: Manos del Pueblo  
**Estado**: ✅ ios-dry-run compiló exitosamente

---

## Checklist Rápido

### 1. Apple Developer (5 min)

```
URL: https://developer.apple.com/account/resources/profiles/list
```

- [ ] Eliminar provisioning profile "Manos del Pueblo AppStore"
- [ ] Verificar que App ID `ar.manosdelpueblo.app` existe

### 2. App Store Connect (10 min)

```
URL: https://appstoreconnect.apple.com/apps
```

- [ ] Crear nueva app "Manos del Pueblo"
- [ ] Bundle ID: `ar.manosdelpueblo.app`
- [ ] SKU: `manosdelpueblo001`
- [ ] Anotar App Store Apple ID (número de la URL)

### 3. Actualizar codemagic.yaml (2 min)

```yaml
# Línea ~12
APP_STORE_APPLE_ID: 1234567890  # ← Reemplazar con ID real

# Línea ~58
recipients:
  - tu-email@ejemplo.com  # ← Reemplazar con email real
```

```bash
git add codemagic.yaml
git commit -m "Configurar App Store ID para iOS"
git push
```

### 4. Ejecutar Build (20 min)

```
URL: https://codemagic.io/apps
```

- [ ] Seleccionar proyecto "manos-del-pueblo"
- [ ] Start new build
- [ ] Workflow: **ios-release**
- [ ] Branch: main
- [ ] Esperar a que termine

### 5. Verificar TestFlight (30 min)

```
URL: https://appstoreconnect.apple.com/apps
```

- [ ] Ver build en TestFlight
- [ ] Esperar "Processing" → "Ready to Submit"
- [ ] Completar "What to Test"
- [ ] Invitar testers

---

## ⚠️ Si algo falla

**Error: "No matching profiles"**
→ Verifica que eliminaste el provisioning profile en Paso 1

**Error: "Certificate not found"**
→ Verifica integración "codemagic" en Codemagic → Teams → Integrations

**Build no aparece en TestFlight**
→ Espera 30 min, revisa email de Apple

---

## 📖 Guía Completa

Para detalles completos, troubleshooting y explicaciones:
→ Ver `SUBIR_APP_APPLE_SIN_MAC.md`

---

**Tiempo total estimado**: 1-2 horas (incluyendo esperas)
