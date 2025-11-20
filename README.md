# manos_del_pueblo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

¡Felicitaciones! 🎉 Tener el dominio .ar registrado es el paso que transforma un "proyecto de estudiante" en algo oficial.

Ahora viene el paso técnico de conectar NIC Argentina (el dueño del nombre) con GitHub (donde están los archivos).

Como NIC.ar no te deja configurar los detalles técnicos directamente (registros A y CNAME) de forma sencilla, necesitamos un "puente" gratuito y seguro. El estándar de la industria es Cloudflare.

Sigue estos pasos con calma. Es un proceso de una sola vez.
Paso 1: Crear el "Puente" (Cloudflare)

Cloudflare gestionará tu dominio gratis y le dará el candadito de seguridad (HTTPS).

    Entra a cloudflare.com y crea una cuenta gratuita.

    Arriba a la derecha, haz clic en "Agregar sitio" (Add site).

    Escribe tu dominio: manos-del-pueblo.ar

    Selecciona el Plan Free (Gratuito) abajo del todo y dale a continuar.

    Cloudflare escaneará tu dominio. Dale a continuar.

    IMPORTANTE: Te mostrará dos nombres de servidores (Nameservers). Suelen llamarse algo como bob.ns.cloudflare.com y lola.ns.cloudflare.com. Cópialos o déjalos abiertos en una pestaña.

Paso 2: Configurar NIC Argentina

Vamos a decirle a NIC que Cloudflare manda ahora.

    Entra a nic.ar con tu clave fiscal o usuario.

    Ve a tu lista de dominios y selecciona manos-del-pueblo.ar.

    Busca el botón que dice "Delegar" (o gestionar DNS).

    Si hay servidores viejos, bórralos.

    Agrega los 2 servidores que te dio Cloudflare en el paso anterior.

    Guarda los cambios.

(Nota: NIC.ar puede tardar desde 1 hora hasta 24hs en impactar este cambio, aunque últimamente es rápido).
Paso 3: Conectar los cables en Cloudflare

Vuelve a la pestaña de Cloudflare.

    Dale a "Check nameservers" para confirmar que ya hiciste lo de NIC.

    Ve al menú de la izquierda: DNS -> Records (Registros).

    Tienes que crear (o editar) estos registros para que apunten a GitHub:

Registro A (Apunta a GitHub):

    Type (Tipo): A

    Name (Nombre): @ (o manos-del-pueblo.ar)

    IPv4 address: 185.199.108.153

    Proxy status: Proxied (Nube naranja)

    Dale a Guardar.

(Repite esto 3 veces más con estas IPs de GitHub para que nun[1]ca se caiga):

    185.199.109.153

    185.199.110.153

    185.199.111.153

Registro CNAME (Para el www):

    Type: CNAME

    Name: www

    Target: marsaiz.github.io (Tu usuario de GitHub + .github.io)

    Proxy status: Proxied

    Dale a [2]Guardar.

Paso 4: Avisarle a GitHub

Ahora G[1][2][3]itHub tiene que saber que debe responder a ese nombre.

    Ve a tu repositorio en GitHub -> Settings -> Pages.

    En el campo Custom domain, escribe: manos-del-pueblo.ar

    Dale a Save.

    GitHub hará una comprobación DNS (puede fallar al principio si NIC.ar todavía no actualizó, ten paciencia).

    Cuando funcione, marca la casilla "Enforce HTTPS" (para que sea seguro).

Paso 5: ¡CRUCIAL! Reconstruir Flutter

Este es el paso que la mayoría olvida y por eso la pantalla se queda en blanco.

Antes, construíamos la web con --base-href "/manos-del-pueblo/".
Ahora que tienes dominio propio, tu web ya no está en una subcarpeta, está en la raíz. Hay que cambiar el comando.

    Ve a tu terminal en VS Code.

    Ejecuta este comando (fíjate que ahora la base es solo una barra /):

code Bash

    
flutter build web --base-href "/" --release

  

    Sube los cambios a GitHub:

code Bash

    
rm -rf docs
mkdir docs
cp -r build/web/* docs/
# IMPORTANTE: GitHub crea un archivo CNAME automáticamente, 
# pero al borrar docs lo perdiste. Créalo de nuevo así:
echo "manos-del-pueblo.ar" > docs/CNAME

git add .
git commit -m "Actualizo dominio a manos-del-pueblo.ar"
git push

  

Resumen de la espera

Ahora toca esperar.

    NIC.ar tarda un rato en decirle al mundo que tu dominio existe.

    Cloudflare tarda un rato en recibir esa info.

    GitHub tarda unos minutos en generar el certificado de seguridad SSL.

Vete a tomar unos mates 🧉. En un rato, cuando entres a https://manos-del-pueblo.ar, verás tu obra maestra.
Sources help

    stfalcon.com
    flutter.dev
    mantraideas.com

¡Excelente observación! Cloudflare actualizó su diseño recientemente y cambió el nombre de ese botón.

En la captura que me mandaste, la opción correcta es la primera de la lista:

👉 Connect a domain
(Fíjate que abajo dice en gris "Optimize web traffic speed and security", que es justamente lo que queremos).

Pasos corregidos con tu pantalla actual:

Haz clic en Connect a domain.

Te pedirá el nombre del dominio: escribe manos-del-pueblo.ar y dale a Continue.

Te ofrecerá planes. Elige el Free (Gratuito) que suele estar abajo del todo.

Cloudflare escaneará tus DNS. Dale a Continue.

Llegarás a la pantalla importante: Te dará 2 "Nameservers" (Servidores de nombres).

Suelen ser nombres de personas, tipo bob.ns.cloudflare.com y lola.ns.cloudflare.com.

¡No cierres esa pestaña! Copia esos dos nombres.

Ahora sí: ¿Cómo conectar todo? (El orden exacto)

Tienes que hacer un "teléfono descompuesto" en este orden:
Tú ➔ le dices a NIC.ar ➔ que le diga a Cloudflare ➔ que le diga a GitHub.

Aquí tienes la hoja de ruta:

1. NIC Argentina (El dueño del nombre)

Entra a nic.ar con tu clave fiscal.

Ve a tu dominio manos-del-pueblo.ar -> Delegar.

Borra cualquier servidor que haya viejo.

Pega los 2 Nameservers que te acaba de dar Cloudflare (los de los nombres de personas).

Guarda.
(Esto tarda un rato en impactar, pero Cloudflare te avisará por email cuando esté listo).

2. Cloudflare (El puente)

Vuelve a Cloudflare, ve a la sección DNS (en el menú de la izquierda) y asegúrate de crear los registros que apuntan a GitHub (como te expliqué antes):

Tipo A: @ apuntando a 185.199.108.153

Tipo CNAME: www apuntando a marsaiz.github.io

3. GitHub (El destino final)

Aquí es donde respondo tu pregunta: "¿Cómo le digo a GitHub la nueva dirección?"

Esto se hace al final, cuando ya configuraste lo anterior:

Ve a tu repositorio en GitHub.

Entra en la pestaña Settings (arriba).

En el menú lateral izquierdo, busca Pages.

Donde dice Custom domain, escribe: manos-del-pueblo.ar

Haz clic en el botón Save.

GitHub comprobará si l[1]a conexión con Cloudflare funciona. Si te sale un error de DNS, espera 15 minutos y vuelve a intentar (es normal que tarde).

Cuando se ponga verde, marca la casilla Enforce HTTPS.

¡Dale clic a "Connect a domain" y avísame cuando tengas los nombres [2]
2. Te pedirá el nombre del dominio: escribe manos-del-pueblo.ar y dale a Continue.
3. Te ofrecerá planes. Elige el Free (Gratuito) que suele estar abajo del todo.
4. Cloudflare escaneará tus DNS. Dale a Continue.
5. Llegarás a la pantalla importante: Te dará 2 "Nameservers" (Servidores de nombres).
* Suelen ser nombres de personas, tipo bob.ns.cloudflare.com y lola.ns.cloudflare.com.
* ¡No cierres esa pestaña! Copia esos dos nombres.

Ahora sí: ¿Cómo conectar todo? (El orden exacto)

Tienes que hacer un "teléfono descompuesto" en este orden:
Tú ➔ le dices a NIC.ar ➔ que le diga a Cloudflare ➔ que le diga a GitHub.

Aquí tienes la hoja de ruta:

1. NIC Argentina (El dueño del nombre)

Entra a nic.ar con tu clave fiscal.

Ve a tu dominio manos-del-pueblo.ar -> Delegar.

Borra cualquier servidor que haya viejo.

Pega los 2 Nameservers que te acaba de dar Cloudflare (los de los nombres de personas).

Guarda.
(Esto tarda un rato en impactar, pero Cloudflare te avisará por email cuando esté listo).

2. Cloudflare (El puente)

Vuelve a Cloudflare, ve a la sección DNS (en el menú de la izquierda) y asegúrate de crear los registros que apuntan a GitHub (como te expliqué antes):

Tipo A: @ apuntando a 185.199.108.153

Tipo CNAME: www apuntando a marsaiz.github.io

3. GitHub (El destino final)

Aquí es donde respondo tu pregunta: "¿Cómo le digo a GitHub la nueva dirección?"

Esto se hace al final, cuando ya configuraste lo anterior:

Ve a tu repositorio en GitHub.

Entra en la pestaña Settings (arriba).

En el menú lateral izquierdo, busca Pages.

Donde dice Custom domain, escribe: manos-del-pueblo.ar

Haz clic en el botón Save.

GitHub comprobará si la conexión con Cloudflare funciona. Si te sale un error de DNS, espera 15 minutos y vuelve a intentar (es normal que tarde).

Cuando se ponga verde, marca la casilla Enforce HTTPS.

¡Dale clic a "Connect a domain" y avísame cuando tengas los nombres [1]
2. Te pedirá el nombre del dominio: escribe manos-del-pueblo.ar y dale a Continue.
3. Te ofrecerá planes. Elige el Free (Gratuito) que suele estar abajo del todo.
4. Cloudflare escaneará tus DNS.[1][2][3][4] Dale a Continue.
5. Llegarás a la pantalla importante: Te dará 2 "Nameservers" (Servidores de nombres).
* Suelen ser nombres de personas, tipo bob.ns.cloudflare.com y lola.ns.cloudflare.com.
* ¡No cierres esa pestaña! Copia esos dos nombres.

Ahora sí: ¿Cómo conectar todo? (El orden exacto)

Tienes que hacer un "teléfono descompuesto" en este orden:
Tú ➔ le dices a NIC.ar ➔ que le diga a Cloudflare ➔ que le diga a GitHub.

Aquí tienes la hoja de ruta:

1. NIC Argentina (El dueño del nombre)

Entra a nic.ar con tu clave fiscal.

Ve a tu dominio manos-del-pueblo.ar -> Delegar.

Borra cualquier servidor que haya viejo.

Pega los 2 Nameservers que te acaba de dar Cloudflare (los de los nombres de personas).

Guarda.
(Esto tarda un rato en impactar, pero Cloudflare te avisará por email cuando esté listo).

2. Cloudflare (El puente)

Vuelve a Cloudflare, ve a la sección DNS (en el menú de la izquierda) y asegúrate de crear los registros que apuntan a GitHub (como te expliqué antes):

Tipo A: @ apuntando a 185.199.108.153

Tipo CNAME: www apuntando a marsaiz.github.io

3. GitHub (El destino final)

Aquí es donde respondo tu pregunta: "¿Cómo le digo a GitHub la nueva dirección?"

Esto se hace al final, cuando ya configuraste lo anterior:

Ve a tu repositorio en GitHub.

Entra en la pestaña Settings (arriba).

En el menú lateral izquierdo, busca Pages.

Donde dice Custom domain, escribe: manos-del-pueblo.ar

Haz clic en el botón Save.

GitHub comprobará si la conexión con Cloudflare funciona. Si te sale un error de DNS, espera 15 minutos y vuelve a intentar (es normal que tarde).

Cuando se ponga verde, marca la casilla Enforce HTTPS.

¡Dale clic a "Connect a domain" y avísame cuando tengas los nombres de los servidores para poner en NIC!

    