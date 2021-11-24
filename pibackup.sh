#! /bin/bash

# =================================================================================================
#
#  	TITULO: Script Shell cliente para copias de seguridad del servidor local (PI>SERVER)
#	AUTOR: Sergio García Butrón		
#	CREADO: 20-JUNIO-2021
#	ACTUALIZADO: 19-AGOSTO-2021
#	FUNCIONES: ¿Qué permite hacer este script?
#		>> Copia de seguridad completa de la tarjeta micro SD o pendrive.
#		>> Copia de seguridad sólo de la partición BOOT de la tarjeta micro SD o pendrive.
#		>> Copia de seguridad sólo de la partición ROOFS de la tarjeta micro SD o pendrive.
#		>> Copia de seguridad sólo de la partición DATAFS de la tarjeta micro SD o pendrive.
#	PARAMETROS: ¿Cuaĺes recibe el script en su llamada?
#		>> $1 = Dispositivo de origen copia de seguridad.
#		>> $2 = Directorio de ubicación copias de seguridad.
#		>> $3 = Directorio de trabajo del módulo script.
#		>> $4 = Usuario de trabajo local.
#		>> $5 = Hash de usuario de trabajo local.
#	TODO:¿Que más se me ocurre hacer en un futuro?
#		>> Copia de seguridad del MBR/GPT de la tarjeta micro SD o pendrive. (optativo)
#
# =================================================================================================

AQUI="$3"
USERPC="$4"
HASHPC="$5"

# FUNCIONES ESENCIALES PARA EL FUNCIONAMIENTO DEL MODULO SCRIPT.

function portada {
	clear
	echo
	echo
	echo "		S C R I P T 	C L I E N T E			"
	echo "	=================================================="
	echo
	echo "		### ### ### ### ### #   # ### ###			"
	echo "		# #  #  #   #   # # #   # #   # #			"
	echo "		###  #  ### ### ### #   # ### ###			" 
	echo "		#    #    # #   ##   # #  #   ##			"
	echo "		#   ### ### ### # #   #   ### # #		"
	echo
	echo "	============================================PC===="
	echo
	modulo=$(echo "$0" | sed "s#${AQUI}/##")
	echo "		Bienvenido a $modulo!!!"
	echo 
	echo "		USERPC: $USERPC	"
}

# PORTADA PARA INICIO DE SESION.
OKPASS=0
HASHPASS=0
sudopass=0
while [ $OKPASS -eq 0 ]; do

	portada
	read -sp "		CONTRASEÑA: " sudopass
	HASHPASS=$(echo "$sudopass" | sha256sum -t | sed "s# ##g" | sed "s#-##")

	if [ "$HASHPASS" == "$HASHPC" ]; then
		echo
		echo
		echo "	=================================================="
		echo
		echo "	Accediendo..."
		sleep 1
		OKPASS=1 
	else
		echo
		echo
		echo "	=================================================="
		echo
		echo "	Incorrecto!"
		sleep 1
	fi

done

#MENÚ DEL MÓDULO SCRIPT CLIENTE

VOLVER=0
MODO=0
while [ $VOLVER -eq 0 ]; do
	sleep 1
	clear
	echo "Opcion 4 Crear copia de seguridad del servidor"
	echo "=========================================================="
	echo "		Origen copia de seguridad: $1"
	echo "=========================================================="
	echo
	echo "   0. Copia seguridad completa"
	echo "   1. Particion boot"
	echo "   2. Particion rootfs"
	echo "   3. Particion datafs"
	echo "   4. Volver atras"
	echo
	echo "=========================================================="
	echo "Inserte modo de resplado: "
	read MODO
	case $MODO in
		0)
			echo "Inserte fichero imagen de destino: (sin extensión)"
			read fileimg
			echo "Creando backup completo... ( $1 )"
			echo
			echo "$sudopass" | sudo -S dd bs=4k status=progress conv=fsync if=/dev/"$1" of="$2"/"$fileimg".img
			sleep 1
			echo "Completado!" ;;
		1)
			part=$(lsblk -o NAME,FSTYPE,LABEL | grep $1 | grep boot | cut -c10)
			if [ "$part" != "" ];then 
				echo "Inserte fichero imagen de destino: (sin extensión)"
				read fileimg
				echo "Creando backup partición boot... ( $1$part )"
				echo
				echo "$sudopass" | sudo -S  dd bs=4k status=progress conv=fsync if=/dev/"$1$part" of="$2"/$fileimg.img
				sleep 1
				echo "Completado!"
			else
				echo "Esta unidad no tiene particion boot!"
			fi ;;
		2)
			part=$(lsblk -o NAME,FSTYPE,LABEL | grep $1 | grep rootfs | cut -c10)
			if [ "$part" != "" ];then 
				echo "Inserte fichero imagen de destino: (sin extensión)"
				read fileimg
				echo "Creando backup partición rootfs... ( $1$part )"
				echo
				echo "$sudopass" | sudo -S dd bs=4k status=progress conv=fsync if=/dev/"$1$part" of="$2"/$fileimg.img
				sleep 1
				echo "Completado!"
			else
				echo "Esta unidad no tiene particion rootfs!"
			fi ;;
		3)
			part=$(lsblk -o NAME,FSTYPE,LABEL | grep $1 | grep datafs | cut -c10)
			if [ "$part" != "" ];then 
				echo "Inserte fichero imagen de destino: (sin extensión)"
				read fileimg
				echo "Creando backup partición datafs... ( $1$part )"
				echo
				echo "$sudopass" | sudo -S dd bs=4k status=progress conv=fsync if=/dev/"$1$part" of="$2"/$fileimg.img
				sleep 1
				echo "Completado!"
			else
				echo "Esta unidad no tiene particion datafs!"
			fi ;;
		4)
			VOLVER=1 ;;
		*)
			echo "Modo de respaldo desconocido!" ;;
	esac
done

