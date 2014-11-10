##################################
## Utilidad de cifrado para usuarios ##
##################################

Script para facilitar el uso de luks al usuario, en tareas como: cifrar, montar, desmontar y cambiar la contraseña del disco cifrado sin tener que usar la linea de comandos. Haciendo todo de manera automatica.

---------------------------------------------------------------------------------------------------------

Encrypt Disk.desktop -- Acceso directo para ejecutar el Script
Descripción: ENCRYPT DISK UTILITY WITH LUKS
Comando: '/usr/bin/encryptdisk' 
Avanced Options: konsole --noresize --vt_sz 122x38 -T "ENCRYPT DISK UTILITY WITH LUKS" --schema LightPaper.schema --nomenubar

---------------------------------------------------------------------------------------------------------

Crear un fichero en:    con:
/usr/bin/encryptdisk -- sudo /sbin/cifrarLUKS.sh -- llama al script ejecutandolo como SUDO

---------------------------------------------------------------------------------------------------------

Copiar el fichero cifrarLUKS.sh en
/sbin/cifrarLUKS.sh -- Script para cifrar

---------------------------------------------------------------------------------------------------------

/etc/sudoers -- Añadir las siguientes lineas.

ALL ALL=NOPASSWD: /usr/bin/encryptdisk, /sbin/cifrarLUKS.sh

---------------------------------------------------------------------------------------------------------

Ficheros de Desbloqueo en caso de olvido de la contraseña

Es almacenada en "la ruta que le indiques en la variable $RUTALLAVE", 
Solo el usuario que cifra el disco puede ver ese fichero.

---------------------------------------------------------------------------------------------------------
