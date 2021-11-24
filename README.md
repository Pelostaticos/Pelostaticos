ME PRESENTO: Quién soy y un poco sobre mí.

- 👋 Hi, I’m @Pelostaticos
- 👀 I’m interested in technologies and programming
- 🌱 I’m currently learning about WordPress and web servers on Raspberry Pi
- 💞️ I’m looking to collaborate on technologies and programming projects
- 📫 How to reach me on sergio.garciabutron@bitgarcia.es

EL SCRIPT CLIENTE PARA GESTIÓN DE PISERVER EN PC: ¿Qué módulos lo compone?

+ piserver-pc.sh    => Módulo principal del script cliente.
+ pibackup.sh       => Módulo auxiliar para la creación de copias de seguridad.
+ pirestore.sh      => Módulo auxiliar para la restauración de copias de seguridad.
+ pigestimg.sh      => Módulos auxiliar para la gestión de copias de seguridad.

PISERVERPC: ¿Qué me permite hacer este módulo?

+ Habilitar en equipo cliente el uso del servidor DNS local.
+ Conectar por terminal remoto al servidor local.                 (Permite el acceso remoto a su Raspberry Pi mediante SSH)
+ Acesso remoto al servidor local para su gestión.                (Sólo funciona si PiServer tiene instalado el script servidor)
+ Hacer copias de seguridad del servidor local.
+ Restaurar copias de seguridad del servidor local.
+ Gestionar copias de seguridad del servidor local.

PIBACKUP: ¿Qué funciones adicionales aporta este modulo?

  + Copia de seguridad completa de la tarjeta micro SD o pendrive.
  + Copia de seguridad sólo de la partición BOOT de la tarjeta micro SD o pendrive.
  + Copia de seguridad sólo de la partición ROOFS de la tarjeta micro SD o pendrive.
  + Copia de seguridad sólo de la partición DATAFS de la tarjeta micro SD o pendrive.

PIRESTORE: ¿Qué funciones adicionales aporta este modulo?

  + Restaura copia de seguridad completa de la tarjeta micro SD o pendrive.
  + Restaura copia de seguridad de sólo la partición BOOT de la tarjeta micro SD o pendrive.
  + Restaura copia de seguridad de sólo la partición ROOFS de la tarjeta micro SD o pendrive.
  + Restaura copia de seguridad de sólo la partición DATAFS de la tarjeta micro SD o pendrive.

      NOTA: Recomendable que la unidad de destino sea de igual capacidad que el origen.

PIGESTIMG: ¿Qué funciones adicionales aporta este modulo?

  + Comprimir un fichero de imagen de seguridad.
  + Comprimir imagen y eleminar fichero original para ahorrar espacio.
  + Descomprimir un fichero de imagen de seguridad.
  + Verificar integridad fichero de imagen de seguridad.
  + Montar imagenes de seguridad para su manipulación.
  + Desmontar imagenes de seguridad montadas.
  + Eliminar una copia de seguridad completas (.img + .zip + .md5)
  + Eliminar fichero de imagen (sólo .img)

CONFIGURACIÓN: ¿Qué datos me pide las primera vez?

+ Dirección IP del servidor DNS local en ubicación principal.
+ Dirección IP del servidor DNS local en ubicación alternativa.                   (Si no utiliza ubicación alternativa ponga la IP principal)
+ Dominio del servidor local.                                                     (Si no utiliza dominio ponga la IP del servidor local)
+ Usuario de acceso remoto al servidor local.                                     (Su usuario en el servidor local)
+ Directorio local de almacenamiento de las copias de seguridad del servidor.     (Donder quiere guardar en su equipo las copias de seguridad)
+ Dirección URL para testear funcionamiento del servidor DNS local.               (Si utiliza una Raspberry Pi normal ponga su IP principal)
+ Su usuario de trabajo local.                                                    (Su usuario en el equipo local de trabajo)

INSTRUCIONES: ¿Cómo utilizo este script?

  + 0º) Descar

<!---
Pelostaticos/Pelostaticos is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->
