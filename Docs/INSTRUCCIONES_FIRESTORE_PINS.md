# Configuración de PINs en Firestore

## Paso 1: Crear la colección y documento en Firestore

Debes crear manualmente en tu consola de Firebase (Firestore Database) la siguiente estructura:

### Colección: `config`
### Documento ID: `pins`

### Campos del documento:

```
admin_access: "4628"
product_management: "1234"
artisan_delete: "919345"
```

## Paso 2: Cómo crear esto en Firebase Console

1. Ve a Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto "Manos del Pueblo"
3. En el menú lateral, haz clic en "Firestore Database"
4. Haz clic en "Iniciar colección" (o "Start collection")
5. ID de colección: `config`
6. ID de documento: `pins`
7. Agrega los siguientes campos:
   - Campo: `admin_access`, Tipo: string, Valor: `4628`
   - Campo: `product_management`, Tipo: string, Valor: `1234`
   - Campo: `artisan_delete`, Tipo: string, Valor: `919345`
8. Haz clic en "Guardar"

## Paso 3: Cambiar PINs en el futuro

Para cambiar cualquier PIN:

1. Ve a Firestore Database en Firebase Console
2. Navega a: `config` > `pins`
3. Haz clic en el campo que quieres modificar
4. Cambia el valor
5. Guarda

Los cambios se reflejarán automáticamente en la app en máximo 5 minutos (debido al cache).

## Tipos de PINs disponibles:

- **admin_access**: Para acceder a las pantallas de administración
- **product_management**: Para agregar, editar o eliminar productos
- **artisan_delete**: Para eliminar artesanos (acción más destructiva)

## Seguridad

Recuerda configurar las reglas de seguridad de Firestore para que solo administradores puedan modificar esta colección:

```javascript
match /config/{document=**} {
  allow read: if true;  // Todos pueden leer los PINs
  allow write: if false; // Nadie puede escribir desde la app (solo desde consola)
}
```

O si quieres permitir actualizaciones desde la app con autenticación:

```javascript
match /config/{document=**} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.token.admin == true;
}
```
