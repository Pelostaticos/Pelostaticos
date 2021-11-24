#! /bin/bash

# =================================================================================================
#
#  	TITULO: Script Shell cliente principal para gestión general del servidor local (PI>SERVER)
#	AUTOR: Sergio García Butrón		
#	CREADO: 21-JUNIO-2021
#	ACTUALIZADO: 19-AGOSTO-2021
#	FUNCIONES: ¿Qué permite hacer este script?
#		>> Habilitar en equipo cliente el uso del servidor DNS local.
#		>> Conectar por terminal remoto al servidor local.
#		>> Acesso remoto al servidor local para su gestión.
#		>> Hacer copias de seguridad del servidor local.
#		>> Restaurar copias de seguridad del servidor local.
#		>> Gestionar copias de seguridad del servidor local.
#	CONFIGURACIÓN: ¿Que parametros se guardan en fichero? (Vease piserver-pc.conf)
#		>> Dirección IP del servidor DNS local en ubicación principal.
#		>> Dirección IP del servidor DNS local en ubicación alternativa.
#		>> Dominio del servidor local.
#		>> Usuario de acceso remoto al servidor local.
#		>> Directorio local de lamacenamiento de las copias de seguridad del servidor.
#		>> Dirección URL para testear funcionamiento del servidor DNS local.
#		>> Su usuario de trabajo local.
#		>> Su hash de usuario de trabajo local.
#	PARAMETROS: ¿Cuaĺes recibe el script en su llamada?
#		>> Ninguno
#	TODO:¿Que más se me ocurre hacer en un futuro?
#		>> Migrar almacenamiento a otro de mayor capacidad (optativo)
#		>> Añadir enlace simbolico a script en crontab para verificar inhahilitación del DNS local (optativo)
#		>> Revisar ejecución correcta de los alias definidos (pospuesto)
#
# =================================================================================================

clear
CNT=0
#AQUI=~/piserverpc
SCRIPT=$(readlink -f $0)
AQUI=`dirname $SCRIPT`
CFG="$AQUI"/"piserver-pc.conf"
TAG0="#>IPSERVER0: "
TAG1="#>IPSERVER1: "
TAG2="#>URLSERVER: "
TAG3="#>USERPI: "
TAG4="#>BCKDIR: "
TAG5="#>SCTDIR: "
TAG6="#>URLTEST: "
TAG7="#>USERPC: "
TAG8="#>HASHPC: "

# GESTION CONFIGURACIÓN BASICA DEL SCRIPT CLIENTE.
if  [[ -f "$CFG"  ]]; then

	# Establezco IP del servidor en ubicación primaria
	ipserver0=$(cat $CFG | grep $TAG0)
	ipserver0=$(echo "$ipserver0" | sed "s/${TAG0}//")

	# Establezco IP del servidor en ubicación alternativa
	ipserver1=$(cat $CFG | grep $TAG1)
	ipserver1=$(echo "$ipserver1" | sed "s/${TAG1}//")

	# Establezo url del acceso al servidor local
	urlserver=$(cat $CFG | grep $TAG2)
	urlserver=$(echo "$urlserver" | sed "s/${TAG2}//")

	# Establezco usuario de conexión remota
	userpi=$(cat $CFG | grep $TAG3)
	userpi=$(echo "$userpi" | sed "s/${TAG3}//")	

	# Establezco directorio de copias de seguridad
	bckdir=$(cat $CFG | grep $TAG4)
	bckdir=$(echo "$bckdir" | sed "s/${TAG4}//")

	# Establezco directorio trabajo del script lado servidor
	sctdir=$(cat $CFG | grep $TAG5)
	sctdir=$(echo "$sctdir" | sed "s/${TAG5}//")

	# Establezco url de test conexión DNS local
	urltest=$(cat $CFG | grep $TAG6)
	urltest=$(echo "$urltest" | sed "s/${TAG6}//")	

	# Establezco usuario de trabajo local
	userpc=$(cat $CFG | grep $TAG7)
	userpc=$(echo "$userpc" | sed "s/${TAG7}//")	

	# Establezco hash para usuario de trabajo local
	hashpc=$(cat $CFG | grep $TAG8)
	hashpc=$(echo "$hashpc" | sed "s/${TAG8}//")		

else

	echo "Generando configuracion del script cliente..."
	echo
	echo "Inserte IP del servidor en su  ubicación primaria"
	read ipserver0
	echo "Inserte IP del servidor en su ubicación secundaria"
	read ipserver1
	echo "Inserte URL de acceso al servidor local"
	read urlserver
	echo "Inserte su usuario para gestión remota"
	read userpi
	echo "Inserte directorio para copias de seguridad"
	read bckdir
	echo "Inserte directorio de trabajo para script lado servidor"
	read cptdir
	echo "Inserte URL de test para conexión DNS local"
	read urltest
	echo "Inserte su nombre de usuario local:"
	read userpc
	echo "Inserte su contraseña de usuario local:"
	read sudopass
	hashpc=$(echo "$sudopass" | sha256sum -t | sed "s# ##g" | sed "s#-##")
	echo
	echo "Guardando datos de configuración en: $CFG"
	echo "$TAG0$ipserver0" > "$CFG"
	echo "$TAG1$ipserver1" >> "$CFG"
	echo "$TAG2$urlserver" >> "$CFG"
	echo "$TAG3$userpi" >> "$CFG"
	echo "$TAG4$bckdir" >> "$CFG"
	echo "$TAG5$sctdir" >> "$CFG"
	echo "$TAG6$urltest" >> "$CFG"
	echo "$TAG7$userpc" >> "$CFG"
	echo "$TAG8$hashpc" >> "$CFG"
	echo "Configurado!"

fi

# DEFINICION DE COMANDOS POR SSH
CMD0="ssh $userpi@$urlserver"
CMD1="ssh -t $userpi@$urlserver $sctdir/piserver.sh"
CMD2="$AQUI/pibackup.sh"
CMD3="$AQUI/pigestimg.sh"
CMD4="$AQUI/pirestore.sh"

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
	echo "		USERPC: $userpc	"
}

# PORTADA PARA INICIO DE SESION.
OKPASS=0
HASHPASS=0
sudopass=0
while [ $OKPASS -eq 0 ]; do

	portada
	read -sp "		CONTRASEÑA: " sudopass
	HASHPASS=$(echo "$sudopass" | sha256sum -t | sed "s# ##g" | sed "s#-##")

	if [ "$HASHPASS" == "$hashpc" ]; then
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

# MENU PRINCIPAL DEL SCRIPT DE CLIENTE.
SALIR=0
OPCION=0
while [ $SALIR -eq 0 ]; do
	sleep 1
	clear
	echo
	echo "------ Menú cliente de gestion PI>SERVER ------"
	echo 
	echo "  1) Habilitar servidor DNS local."
	echo "  2) Conectar por terminal remoto."
	echo "  3) Gestionar el servidor local."
	echo "  4) Hacer copia de seguridad."
	echo "  5) Gestionar copia de seguridad."
	echo "  6) Restaurar copia de seguridad."
	echo "  7) Salir."
	echo
	echo "-----------------------------------------------"
	echo "Opción elegida: "
	read OPCION
	case $OPCION in
       1)
		clear 
		echo "Opcion 1 Habilitar servidor DNS local"
		echo "=========================================================="
		echo
		echo "Verificando conexión al DNS local en ubicación principal..."
		test0=$(ping -c 5 $urltest | grep $ipserver0); test0=${#test0}
		echo "Verificando conexión al DNS local en ubicación alternativa..."
		test1=$(ping -c 5 $urltest | grep $ipserver1); test1=${#test1}
		echo "Limpiando cache DNS local..."
		systemd-resolve --flush-caches
		if [ "${test0}" != "0" ] || [ "${test1}" != "0" ]; then
			echo "DNS local está habilitado!"			
		else
			echo "Habilitando DNS local..."
			echo
			echo "$sudopass" | sudo -S systemctl restart systemd-resolved
			echo
			echo "Verificando conexión al DNS local en ubicación principal..."
			test0=$(ping -c 5 $urltest | grep $ipserver0); test0=${#test0}
			echo "Verificando conexión al DNS local en ubicación alternativa..."
			test1=$(ping -c 5 $urltest | grep $ipserver1); test1=${#test1}
			if [ "${test0}" != "0" ] || [ "${test1}" != "0" ]; then
				echo "DNS local está habilitado!"
			else
				echo "No puedo habilitar el DNS local!!!"
				echo "Verifique que su servidor está encendido..."
				echo "Verifique que su configuración de red es correcta..."
				sleep 1
			fi
		fi ;;
       2)
		clear 
		echo "Opcion 2 Conectar por terminal remoto"
		echo "=========================================================="
		echo
		echo "Conectando al terminal remoto..."
		let CNT=CNT+1
		xfce4-terminal --tab --title="Terminal remoto de $urlserver... ($CNT)" -e "$CMD0"
		sleep 1
		echo "Conectado!"  ;;
       3) 
		clear 
		echo "Opcion 3 Gestionar el servidor local"
		echo "=========================================================="
		echo
		echo "Conectando para gestión remota..."
		xfce4-terminal --tab --title="Gestión del servidor $urlserver..." -e " $CMD1"
		sleep 1
		echo "Conectado!" ;;
	4)
		clear
		echo "Opcion 4 Crear copia de seguridad del servidor"
		echo "=========================================================="
		echo
		echo "Unidades extraibles disponibles:" 
		echo
		pendrives=$(lsblk -o NAME,FSTYPE,LABEL,RM -d | grep 1 | grep sd | cut -c1-3); existen=${#pendrives}
		if [ "$existen" != "0" ]; then
			for pen in $pendrives; do
				lsblk -o NAME,MODEL,FSTYPE,LABEL | grep $pen
			done
			echo
			echo "Inserte nombre unidad a respaldar: Ej > sdd (ENTER=SALIR)"
			read unidad
			if [ "$unidad" != "" ]; then
				existe=$(lsblk -o NAME,MODEL,FSTYPE,LABEL | grep $unidad)
				if [ "${#existe}" != "0"  ]; then 
					xfce4-terminal --tab --title="Crear copia seguridad  $urlserver... ($unidad)" -e "$CMD2 $unidad $bckdir $AQUI $userpc $hashpc"
				else
					echo "Unidad de origen incorrecta!"
				fi
			else
				echo "Cancelado!"
			fi 
		else 
				echo "Por favor, inserte una unidad flash en su equipo"
				echo "Ninguna unidad extraible disponible!"
				echo 
				sleep 1
		fi ;;
       5) 
		clear
		echo "Opcion 5 Gestionar copia de seguridad del servidor"
		echo "=========================================================="
		echo
		echo "Abriendo el gestor de copias de seguridad..."
		xfce4-terminal --tab --title="Gestor copias de seguridad  $urlserver... ($unidad)" -e "$CMD3 $AQUI $bckdir $userpc $hashpc"
		echo "Listo!"
		sleep 1 ;;
       6)
		clear
		echo "Opcion 6 Restaurar copia de seguridad del servidor"
		echo "=========================================================="
		echo
		pendrives=$(lsblk -o NAME,FSTYPE,LABEL,RM -d | grep 1 | grep sd | cut -c1-3); existen=${#pendrives}
		if [ "$existen" != "0" ]; then
			echo "Listado de imagenes disposibles:"
			echo
			cd "$bckdir"
			ls *.img
			cd "$AQUI"
			echo
			echo "Inserte fichero de imagen a restaurar: Copie y pegue (ENTER=SALIR)"
			read fileimg
			if [ "$fileimg" != "" ]; then
				echo
				echo "Unidades extraibles disponibles:" 
				echo
				for pen in $pendrives; do
					lsblk -o NAME,MODEL,FSTYPE,LABEL | grep $pen
				done
				echo
				echo "Inserte nombre unidad a restaurar: Ej > sdd"
				read unidad
				existe=$(lsblk -o NAME,MODEL,FSTYPE,LABEL | grep $unidad)
				if [ "${#existe}" != "0"  ]; then 
					xfce4-terminal --tab --title="Restaurar copia seguridad $urlserver... ($unidad)" -e "$CMD4 $unidad $bckdir $fileimg $AQUI $userpc $hashpc"
				else
					echo "Unidad de destino incorrecta!"
				fi
			else
				echo "Cancelado!"
			fi
		else
				echo "Por favor, inserte una unidad flash en su equipo!"
				sleep 1
		fi ;;
       7)
	    clear
           SALIR=1 ;;
       *)
         	 echo "Opcion erronea";;
	esac	
done

