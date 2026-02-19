# 🇦🇷 Guía de Configuración de Dominios .AR con Cloudflare y GitHub

Esta guía documenta el proceso paso a paso para conectar un dominio registrado en **NIC Argentina** con un hosting (en este caso **GitHub Pages**) utilizando **Cloudflare** como puente para gestionar los DNS y obtener certificado SSL (candado seguro) gratuito.

---

## 📋 Requisitos Previos
1.  Clave Fiscal Nivel 3 (AFIP) para operar en NIC Argentina.
2.  Cuenta gratuita en Cloudflare.
3.  Un repositorio en GitHub con una página web lista.

---

## 🔄 Flujo de Trabajo General
El orden lógico es: **Cloudflare (Obtener NS) ➔ NIC.ar (Delegar) ➔ Cloudflare (Apuntar DNS) ➔ GitHub (Recibir).**

---

## Paso 1: Cloudflare (Obtener Servidores)
Antes de tocar nada en NIC, necesitamos saber "a dónde" delegar el dominio.

1.  Ingresa a [Cloudflare](https://dash.cloudflare.com/).
2.  Haz clic en **"Connect a domain"** (o Add Site).
3.  Escribe tu dominio (ej: `miproyecto.com.ar`) y continúa.
4.  Selecciona el **Plan Free** (abajo del todo).
5.  Cloudflare escaneará los DNS. Dale a continuar hasta llegar a la pantalla que te muestra los **Nameservers**.
6.  Copia los dos nombres (suelen ser algo como `bob.ns.cloudflare.com` y `lola.ns.cloudflare.com`).

> **⚠️ NO CIERRES ESTA PESTAÑA AÚN.**

---

## Paso 2: NIC Argentina (Delegación)
Aquí le decimos al dominio que Cloudflare será su administrador.

1.  Ingresa a [Trámites a Distancia / NIC](https://nic.ar).
2.  Selecciona tu dominio y haz clic en **Delegar**.
3.  Si hay delegaciones viejas, bórralas (tacho de basura).
4.  Haz clic en **"Agregar una nueva delegación"**.
5.  En el campo **HOST**, pega el primer servidor de Cloudflare. **Deja las IPs vacías.** Guarda.
6.  Repite para el segundo servidor de Cloudflare.
7.  **🛑 CRÍTICO:** Una vez que veas los dos servidores en la lista, haz clic en el botón **"✔ EJECUTAR CAMBIOS"** abajo a la derecha. Si no lo haces, no se guarda nada.

---

## Paso 3: Cloudflare (Configurar DNS)
Volvemos a Cloudflare para conectar el dominio con el hosting (GitHub Pages).

1.  En Cloudflare, haz clic en "Check Nameservers" y espera (puede tardar horas en validarse, te llegará un email).
2.  Ve a la sección **DNS** > **Records**.
3.  Borra cualquier registro A o CNAME extraño que haya aparecido automáticamente.
4.  Crea los siguientes registros para GitHub Pages:

### A) Registros Tipo A (Apuntan a GitHub)
Debes crear 4 registros idénticos, uno para cada IP de GitHub:
*   **Type:** A
*   **Name:** @
*   **IPv4:** `185.199.108.153` (Proxied ☁️)
*   *(Repetir con: .109.153, .110.153, .111.153)*

### B) Registro CNAME (Para el www)
*   **Type:** CNAME
*   **Name:** www
*   **Target:** `tu_usuario.github.io`
*   **Proxy status:** Proxied ☁️

---

## Paso 4: GitHub (Configuración del Repo)
Finalmente, el hosting debe saber que responderá a ese nombre.

1.  Ve a tu repositorio > **Settings** > **Pages**.
2.  En **Custom domain**, escribe: `miproyecto.com.ar`.
3.  Haz clic en **Save**.
4.  Espera a que el "DNS Check" se ponga verde.
5.  Marca la casilla **"Enforce HTTPS"**.

### 💻 Configuración en el Código (Flutter Web)
Para que el despliegue no rompa el dominio, recuerda estos dos puntos al subir cambios:

1.  **Base Href:** Al compilar, usa la raíz.
    ```bash
    flutter build web --base-href "/" --release
    ```

2.  **Archivo CNAME:** En la carpeta de despliegue (`docs/` o raíz de la rama `gh-pages`), debe existir un archivo llamado `CNAME` (sin extensión) que contenga solo el nombre del dominio.
    ```bash
    echo "miproyecto.com.ar" > docs/CNAME
    ```

---

## ⏳ Tiempos de Espera
*   **NIC Argentina:** Tarda entre 1 y 24 horas en propagar la delegación.
*   **Certificado SSL:** GitHub puede tardar unos 15 minutos en generar el candado seguro una vez conectados los DNS.