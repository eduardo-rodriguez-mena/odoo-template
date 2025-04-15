# Instrucciones de Uso de plantillas de contenedores Odoo para YYOGestino

## Descripción general

Este contenedor esta creado para que pueda desplegar cual quiera de las 2 modalidades de Odoo:

1.  Todo en uno (AiO) con la Base de datos y Web juntos en el mismo recurso de computo (contenedor LXC o VM o VPS),
2.  Servidor de Base de Datos y Web en recursos de computo separados. Este caso la comunicación entre la Aplicación Web y la base de datos e obligatoriamente Cifrada via SSL. 

De los ficheros de presentados, solo los **.env** deben ser editados ajustando el valor de las variables a los requerimientos del desligue que se está realizando. **No se debe realizar modificaciones en ningún otro fichero**, si es necesario hacerlo es imperativo contactar con el responsable de TI para crear una nueva versión actualizada a estos requerimientos.

## Descripción de las Variantes

El contenedor puede ser personalizado según las distintas variantes explicadas anteriormente y utilizando para ellos los proyecto que se encuentran en la carpeta **/app**, no se deben cambiar los nombres estas carpetas:

* **odoo-web:** permite desplegar solo la parte web de Odoo y conectar está a un servidor Postgres que se desee utilizando SSL (obligatoriamente). Además, hace las configuraciones necesarias (Nginx y Certificado SSL LetsEncrypt) para que este pueda ser accedido desde internet vía Cloudflare y directamente por la Red Privada (VPN).simultáneamente. Solo se publican los puertosWeb (80 y 443)*. (las configuraciones de Public Name de cloudflare y el registro DNS en PFsense deben ser realizado manualmente por el momento).
* **odoo-db:** permite el despliegue de un servidor Postgres de la versión que se necesite, este además obtiene el certificado necesario para la publicación del servicio usando protocolos cifrados. Se publica únicamente el puerto 5432 y solo admite conexiones cifradas. (La creación del registro DNS en PFsense para el servicio debe ser realizado manualmente por el momento).
* **odoo-aio:** Permite el despliegue de una solución de Odoo que incluye Base de datos y Aplicación Web en un mismo recurso de cómputo. Solo se publican los puertos http y https del servidor Nginx. Así mismo cuenta con los recursos para obtener y renovar un certificado correspondiente al nombre seleccionado.  La comunicación entre los contenedores que confirman la solución es interna y no está cifrada. Solo se publican los puertos Web (80 y 443)*. 

\* El puerto 80 es solo para redireccionar al 443.

## Instrucciones para el despliegue, creación de los servicios y migración de los datos

Las siguientes acciones se deben realizar conectados a la VPN de Gestión de la plataforma. 

Para crear un nuevo cliente, este contenedor se puede desplegar (clonación completa) desde la Plantilla de Proxmox “T-Odoo-V3.X” ajustando el nombre de este contenedor de forma descriptiva que permita identificar a los clientes y los servicios.

Ejemplo si el cliente se llama “Panes Hoy” y se va a hacer un despliegue con todo en un solo contenedor, el nombre podría ser PanesHoy-AiO, si para el mismo negocio se fuera a hacer un despliegue separado, tendríamos 2 contenedores de Proxmox: PanesHoy-DB y PanesHoy-Web.

Durante el proceso anterior debemos definir el número de ID del contenedor en Proxmox, este debe coincidir con la dirección IP asignada.

Cuando esté listo el contenedor se deben realizar los siguientes ajustes:

* Ajustar la dirección IP a la asignada según planificación
* Cambiar la clave de root que por defecto es “1q2w3er”. 
* Planificar las copias de seguridad según corresponda para este tipo de cliente.

Luego iniciamos el contenedor e iniciamos sesión en este para:

1. Según el desligue que se desea hacer en la carpeta **/app** hay tres carpetas, entramos en la que corresponde con el despliegue y editamos el fichero **.env** que aparece en la raíz del proyecto.

2. Desde la raíz de cada proyecto buscamos y ajustamos a los requerimientos de cada uno el fichero **.env** con las variables de entorno necesarias para la inicialización y migración de los despliegues de Odoo remotos.

3. Si a este contenedor que se van .a migrar datos de un Odoo existente ejecutamos el comando:  **odoo\_migracion.sh** , este paso es importante porque además obtiene los certificados SSL y permite que los contenedores creen los volúmenes, la inicialización de las configuraciones de los contenedores y finalmente descarga y restaura los datos desde el antiguo servidor. 

Si todo termina bien en la ejecución del script anterior para comprobar el correcto funcionamiento del Odoo migrado podemos (Opcional):

1. Crear en el Servidor DNS interno (PFsense) el o los registros necesarios para acceder a este a través de la red privada
2. En un navegador comprobar el funcionamiento del sitio web visto desde la red interna.

Si la verificación anterior del sitio migrado fue satisfactoria, entonces podemos proceder con los siguientes pasos que buscan mover las solicitudes a este sitio, del despliegue anterior al nuevo que acabamos de crear.

1. Eliminar el/los registros asociados al sitio/servicio en la herramienta DNS del dominio.
2. Creamos el Nombre público en el Tunnel de CloudFlare correspondiente que apunte al puerto HTTPs de la IP privada del servidor/contenedor que se creo.
2.1. En Opciones Avanzadas habilitamos “ No TLS Verify”  en las opciones de configuración de TLS esto está pendiente por que Cloudflare no esta reconociendo los certificados Letsencrypt por esta vía (pendiente de resolver en próximas versiones).
2.2. Habilitamos el acceso HTTP2 a esta publicación  en las opciones de configuración de TLS.
3. Deshabilitamos la VPN y verificamos que el sitio sea accesible por Internet con el nombre de dominio que le asignamos, en ambos casos no debe haber ningún señalamiento de seguridad.
4. Si el sitio necesita controlar el acceso al...

## Documentación

Es muy importante mantener actualizado la información de los servicios desplegados, por eso es necesario actualizar:

1. El fichero de direcciones IPs, URLs y claves.
2. Las notas del Contenedor en Proxmox para que sea fácil recuperar estos datos.

En este debemos actualizar la información presentada y poner una X en el tipo de despliegue según corresponda: \[ \] Odoo Web, \[ \] Odoo DB, \[X] Odoo AiO (Web+DB)
```
