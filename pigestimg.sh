#! /bin/bash

# =================================================================================================
#
#  	TITULO: Script Shell cliente para gestionar las copias de seguridad del servidor local (PI>SERVER)
#	AUTOR: Sergio García Butrón		
#	CREADO: 20-JUNIO-2021
#	ACTUALIZADO: 19-AGOSTO-2021
#	FUNCIONES: ¿Qué permite hacer este script?
#		>> Comprimir un fichero de imagen de seguridad.
#		>> Comprimir imagen y eleminar fichero original para ahorrar espacio.
#		>> Descomprimir un fichero de imagen de seguridad.
# 		>> Verificar integridad fichero de imagen de seguridad.
#		>> Montar imagenes de seguridad para su manipulación.
#		>> Desmontar imagenes de seguridad montadas.
#		>> Eliminar una copia de seguridad completas (.img + .zip + .md5)
#		>> Eliminar fichero de imagen (sólo .img)
#	PARAMETROS: ¿Cuaĺes recibe el script en su llamada?
#		>> $1 = Directorio de trabajo del script
#		>> $2 = Directorio de ubicación copias de seguridad.
#		>> $3 = Usuario de trabajo en cliente
#		>> $4 = Hash de usuario de trabajo local.
#	TODO:¿Que más se me ocurre hacer en un futuro?
#		>> Cifrar ficheros de imagen comprimidos.
#
# =================================================================================================

AQUI="$1"
USERPC="$3"
HASHPC="$4"

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

MONTAJE="Ninguna"
DIRMONTAJE="/media/$3"
VOLVER=0
MODO=0
while [ $VOLVER -eq 0 ]; do
	sleep 1
	clear
	echo "Opcion 5 Gestionar copias de seguridad del servidor"
	echo "=========================================================="
	echo
	echo "   0. Comprimir fichero de imagen"
	echo "   1. Comprimir imagen y borrar fichero original"
	echo "   2. Descomprimir fichero de imagen"
	echo "   3. Verificar integridad fichero de imagen"
	echo "   4. Montar imagenes."
	echo "   5. Desmontar imagenes."
	echo "   6. Eliminar copia de seguridad completa"
	echo "   7. Eliminar fichero de imagen"
	echo "   8. Volver atras"
	echo
	echo "=========================================================="
	echo "  Copia de seguridad montada: $MONTAJE"
	echo "=========================================================="
	echo "Inserte modo de gestion: "
	read MODO
	case $MODO in
		0)
			clear
			echo "Modo 0 Comprimir fichero de imagen"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep -v '(7z|zip|md5)'); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen disponibles:"
				ls | egrep -v '(7z|zip|md5)'				
				echo 
				echo "Inserte nombre de fichero de imagen: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo "Comprimiendo fichero de imagen... ( $fileimg )"
					zip -v "$fileimg".zip "$fileimg"
					echo "Generando código de integridad... ( $fileimg.zip )"
					md5sum -b "$fileimg".zip > "$fileimg".zip.md5
					echo "Listo!"
					sleep 1
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		1)
			clear
			echo "Modo 1 Comprimir fichero de imagen y borrar fichero original"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep -v '(7z|zip|md5)'); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen disponibles:"
				ls | egrep -v '(7z|zip|md5)'				
				echo 
				echo "Inserte nombre de fichero de imagen: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo "Comprimiendo fichero de imagen... ( $fileimg.zip )"
					zip -v "$fileimg".zip "$fileimg"
					echo "Generando código de integridad... ( $fileimg.zip.md5 )"
					md5sum -b "$fileimg".zip > "$fileimg".zip.md5
					echo "Eliminando fichero de imagen original... ( $fileimg )"
					rm -rf $fileimg
					echo "Listo!"
					sleep 1
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		2)
			clear
			echo "Modo 2 Descomprimir fichero de imagen"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep '(7z|zip)' | egrep -v md5); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen comprimidas disponibles:"
				ls | egrep '(7z|zip)' | egrep -v md5
				echo 
				echo "Inserte nombre de fichero de comprimido: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo "Verificandio código de integridad... ( $fileimg.md5 )"
					checksum=$(md5sum -c "$fileimg".md5)
					if [[ "${checksum}" == *"OK"* ]]; then
						echo $checksum
						echo "Descomprimiendo fichero de imagen... ( $fileimg )"
						echo "$sudopass" | sudo -S unzip -D "$fileimg"
						echo "Listo!"
						sleep 1
					else 
						echo "La imagen comprimida es corrupta!!!"
						sleep 1
					fi
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		3)
			clear
			echo "Modo 3 Verificar integridad del fichero de imagen"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep '(7z|zip)' | egrep -v md5); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen comprimidas disponibles:"
				ls | egrep '(7z|zip)' | egrep -v md5
				echo 
				echo "Inserte nombre de fichero de comprimido: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo "Verificandio código de integridad... ( $fileimg.md5 )"
					checksum=$(md5sum -c "$fileimg".md5)
					if [[ "${checksum}" == *"OK"* ]]; then
						echo $checksum
						sleep 1
					else 
						echo "La imagen comprimida es corrupta!!!"
						sleep 1
					fi
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		4)
			clear
			echo "Modo 4 Montar fichero de imagen de seguridad"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep -v '(7z|zip|md5)'); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen disponibles:"
				ls | egrep -v '(7z|zip|md5)'				
				echo 
				echo "Inserte nombre de fichero de imagen: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					fileimg=$(echo $fileimg | sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d; s/^\t*//; s/\t*$//;')
					echo "Montando fichero de imagen... ( $fileimg )"
					echo "$sudopass" | sudo -S kpartx -av "$2"/"$fileimg"
					MONTAJE="$fileimg"
					echo "Listo!"
					sleep 1
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		5) 
			clear
			echo "Modo 5 Desmontar fichero de imagen de seguridad"
			echo "=========================================================="
			echo
			if [ "$MONTAJE" == "Ninguna" ]; then
				echo "No hay imagen de seguridad montada!!"
				sleep 1
			else
				montajes=$(ls "$DIRMONTAJE")
				for punto in $montajes; do
					if [ "$punto" == "boot" ] || [ "$punto" == "rootfs" ] || [ "$punto" == "datafs" ]; then 
						existe=$(mount | grep "$DIRMONTAJE/$punto"); existe=${#existe}
						if [ "$existe" != "0" ]; then
							echo "Desmontando unidad/particion... ( $punto )"
							umount "$DIRMONTAJE/$punto"
							echo "$punto desmontado!"
						else
							echo "La unidad/partición $punto ya está desmontada!"
						fi
					else
						echo "Saltando punto de montaje... ( $punto )"						
					fi
				done
				echo "Desmontando fichero de imagen... ( $MONTAJE )"
				echo "$sudopass" | sudo -S kpartx -d "$2"/"$MONTAJE"
				MONTAJE="Ninguna"
				echo "Listo!"
			fi ;;
	       6)
			clear
			echo "Modo 6 Eliminar copia de seguridad completa"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep '(7z|zip)' | egrep -v md5); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen comprimidas disponibles:"
				ls | egrep '(7z|zip)' | egrep -v md5
				echo 
				echo "Inserte nombre copia a eliminar: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo
					echo "Eliminando fichero de copia comprimida... ( $fileimg )"
					rm -rfi "$fileimg"
					echo "Eliminando fichero de integridad... ( $fileimg.md5 )"
					rm -rfi "$fileimg.md5"
					fileimg=$(echo $fileimg | sed 's/.img.zip//; s/.img.7z//')
					echo "Eliminando fichero de imagen... ( $fileimg.img )"
					rm -rfi "$fileimg.img"
					echo "Copia de seguridad completa [$fileimg] eliminada!"
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
	       7)
			clear
			echo "Modo 7 Eliminar fichero de imagen"
			echo "=========================================================="
			echo
			cd "$2"
			img0=$(ls | egrep -v '(7z|zip|md5)'); img0=${#img0}
			if [ "$img0" == "0" ]; then
				echo "No hay ficheros de imagenes disponibles!"
			else
				echo "Listado de ficheros de imagen disponibles:"
				ls | egrep -v '(7z|zip|md5)'
				echo 
				echo "Inserte nombre copia a eliminar: Copie y pegue (ENTER=SALIR)"
				read fileimg
				if [ "$fileimg" != "" ]; then
					echo "Eliminando fichero de imagen... ( $fileimg )"
					rm -rfi "$fileimg"
					echo "Fichero de imagen [$fileimg] eliminado!"
				else
					echo "Cancelado!"
				fi
			fi 
			cd "$1" ;;
		8)
			if [ "$MONTAJE" == "Ninguna" ]; then
				VOLVER=1
			else
				echo
				echo "Por favor, desmonte la imagen [$MONTAJE] antes de salir..."
				sleep 1
			fi ;;
		*)
			echo "Modo de gestión desconocido!" ;;
	esac
done

