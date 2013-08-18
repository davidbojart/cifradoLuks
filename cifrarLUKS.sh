#!/bin/bash
############################################################################
# Name       : cifrarLUKS.sh
# Author     : David Bojart Rosa 
# Explanation: Script para el Cifrado/Montaje/Desmontaje/Cambio de contraseña 
#   	       de discos con el programa LUKS           
#              Requiere la ejecucion con permisos de administracion. 
# Date       : 20130613
############################################################################
USUARIO=$1
GRUPO=$2
PATH=$PATH:/sbin:/usr/sbin
VOLVER="VOLVER"
rojo="\E[31m"
def="\033[0m"
cian="\E[36m"
verde="\E[32m"
MENSAJES_1="Are you sure to continue?"" Type uppercase: [YES|NO]"
MENSAJES_2="$rojo NOT DONE ANYTHING\n $def"
MENSAJES_5="****PRESS ENTER TO CONTINUE**** \n"
MENSAJES_6="****RETURN TO MAIN MENU**** \n"
MENSAJES_7="Password is wrong or you don't type uppercase YES.\n$rojo\n NOT DONE ANYTHING.$def\n"
MENSAJES_8="$rojo\nPassword is wrong. Please, rerun the program.$def\n"
RUTALLAVE=/tmp/ 	# Cambia por tu ruta donde quieres que se almacene la llave
#FUNCION DE PREGUNTA SI/NO.
funcion1 () 
{ 
  VBLENO=SI
  RESPUESTA_P=error
  while [ $RESPUESTA_P = "error" ]
   do
	 echo -e "$2\n"
	 echo -e "$1\n"
	 echo -n " > "
         read RESPUESTA_P
         case $RESPUESTA_P in
           "YES") break;;
           "NO") break;;
           *) clear ;  RESPUESTA_P="error";;
         esac
  done
  if [ $RESPUESTA_P = "NO" ] ; then
	 echo -e "\n$rojo$MENSAJES_2\n$def"
	 echo -e $MENSAJES_5
	 read
	 echo -e $MENSAJES_6
	 sleep 3
	 continue
  fi
}
#Funcion que controla el comando de error de LUKS al introducir la contraseña.
funcion2 ()
{ 
	if [ $? != 0 ] ; then
			clear
			echo -e $1
			echo -e $2
			read
			continue 
	fi
}

funcion3 ()
{ 
	if [ ${#arraydispo[@]} == 0 ] ; then 
		echo -e "$rojo THERE AREN'T CONNECTED DEVICES, PLEASE, CONNECT SOME DEVICE AND RERUN THE PROGRAM.\n$def" 
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 3
		continue
	fi
}

while [ $VOLVER="VOLVER" ] ; do
cd /tmp
ERROR="error"
let CONTADOR=0
TABLA="NUMBER---------MODEL------------DEVICE------SIZE"
clear
echo -e "#########################################################################"
echo -e "#                                                                       #"
echo -e "#                  ENCRYPT DISK UTILITY WITH LUKS                       #"
echo -e "#                                                                       #"
echo -e "#########################################################################"
echo -e "\nSelect an option:\n
          1)	Encrypt disk
	  2) 	Mount encrypted disk
	  3) 	Umount encrypted disk
	  4)	Change password
	  5) 	Exit"

read NUM
	case $NUM in 
	1) #OPCION CIFRAR DISCO
      
	DISPO=`/usr/bin/find /dev -mindepth 1 -maxdepth 1 -name "*[sh]d[b-z][0-9]" | sort` #LISTA DE LOS DISCOS Y PENDRIVE CONECTADOS CON SU NUMERO DE PARTICIÓN EXCLUYE el SDA
	declare -a arraydispo=($DISPO)  #array con la cadena DISPO
	DISPO2=`find /dev -mindepth 1 -maxdepth 1 -name "*[sh]d[b-z]" | sort | gawk -F / '{print $3}'` #LISTA DE LOS DISCOS Y PENDRIVE CONECTADOS EXCLUYE EL SDA Y EL NUMERO DE PARTICIÓN y el /dev/ , se queda solo con sdx
	declare -a arraydispo2=($DISPO2) #ARRAY con la cadena DISPO2
	DISPO3=`find /dev -mindepth 1 -maxdepth 1 -name "*[sh]d[b-z]" | sort` #LISTA DE LOS DISCOS Y PENDRIVE CONECTADOS EXCLUYE EL SDA Y EL NUMERO DE PARTICIÓN
	declare -a arraydispo3=($DISPO3) #array con la cadena DISPO3
	declare -a arrayTAMANO=() #ARRAY de los tamaños de los discos (esta vacio al principio)
	declare -a arrayMODELO=() #ARRAY de los modelos de los discos (esta vacio al principio)
	declare -a arrayLUKS=() #ARRAY DISPOSITIVOS LUKS (esta vacio al principio)
	dispoLUKSUUID=`blkid | grep -i LUKS | sort | awk -F '"' '{print $2}'` #cadena con el UUID de los dispositivos
	declare -a arraydispoLUKSUUID=($dispoLUKSUUID) #ARRAY con los UUID de los dispositivos.


#Bucle que crea la tabla que mostrará los dispositivos que tenemos conectados. También almacena en los arrays definidos arriba los datos: MODELO, TAMAÑO, DISPOSITIVO, para usarlos cuando se seleccione el disco a cifrar.
	while [ $CONTADOR -lt ${#arraydispo[@]} ] ; do
		MODELO=`udevinfo -a -p /sys/block/${arraydispo2[$CONTADOR]} | grep -i model | awk -F '==' '{printf $2}' | sed 's/ /_/g'` # SACA EL MODELO DEL DISCO
		arrayMODELO=("${arrayMODELO[@]}" $MODELO) #array con el MODELO DE LOS DISCOS
		TAMANO=`fdisk -l  ${arraydispo3[$CONTADOR]}  | grep -i disk | grep -i ${arraydispo3[$CONTADOR]} | awk '{printf $3 $4}'` #SACA EL TAMAÑO DEL DISCO
		arrayTAMANO=("${arrayTAMANO[@]}" $TAMANO) #array con los TAMAÑOS DE LOS DISCOS
		TABLAP=" $CONTADOR------$MODELO------${arraydispo[$CONTADOR]}------$TAMANO"
		TABLA=$TABLA$TABLAP
		let CONTADOR=CONTADOR+1	  
	done

#MENSAJE DE ERROR: NO HAY DISPOSITIVOS CONECTADOS Y VUELVE AL MENU PRINCIPAL
	funcion3

#SELECCIONAR DISCO verifica que el numero indicado es correcto, sino vuelve a pedir que indiques un número válido, mostrando de nuevo la tabla de seleccion de disco y dando opcion de salir.

	while [ "$ERROR" == "error" ] ; do
		SEMFENTRADA=NO
		clear
		echo -e "${#arraydispo[@]} CONNECTED DEVICES\n"
		for TABLAFOR in $TABLA ; do echo -e $TABLAFOR ;  done
			echo -e "\n$rojo**** SELECT NUMBER DISK TO ENCRYPT ****\n$def" 
			echo -e	"$rojo(to return to main menu, type Q and press ENTER.)\n$def"
			read NUMDISCO
			case $NUMDISCO in
				Q)
				    echo -e "$MENSAJES_2"
				    echo -e "$MENSAJES_6"
				    sleep 3
				    continue 2 ;;
				*)
				for AA in {0..100} ; do
					if [ $AA == $NUMDISCO ] ; then  
						SEMFENTRADA=SI
						break
					fi 
				done 
				if [ $SEMFENTRADA == SI ] ; then   
					if [ "${arraydispo[$NUMDISCO]}" != "" ] && [ "$NUMDISCO" != "" ] ; then
						ERROR="OK"
						else 
						echo -e "\n $rojo**** THIS NUMBER IS WRONG ****$def\n"
						echo -e $MENSAJES_5
						ERROR="error"
						read
					fi
				fi ;; 		
			esac
	done
	
#Confirma que el usuario desea continuar cifrando el disco y se le indica el disco ha seleccionado dandole la opcion de salir.
	CADENA_MENSAJES_3=`echo ${arrayMODELO[$NUMDISCO]} | sed "s/_/ /g"`
	MENSAJES_3="$verde\nDisk $NUMDISCO selected $CADENA_MENSAJES_3 ${arraydispo[$NUMDISCO]} ${arrayTAMANO[$NUMDISCO]} $def "
	funcion1 "$MENSAJES_1" "$MENSAJES_3"
	
#Si el disco está montado avisa al usuario y le indica que lo desmonte, saliendo del programa ya que el disco debe estar desmontado para poder cifrarlo.
	MONTADO=`mount | grep  ${arraydispo[$NUMDISCO]}`
	MONTADO2=`mount | grep /dev/mapper/${arraydispoLUKSUUID[$NUMDISCO]}`
	if [ "$MONTADO" != "" ] || [ "$MONTADO2" != "" ]; then 
		echo -e "$rojo\nTHIS DISK IS MOUNTED, PLEASE, YOU SHOULD DISMOUNT MANUALLY.$def\n"
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 3
		continue
	else 
		echo -e "$rojo\t#########################################################################################################"                                      
		echo -e "\t#                                        -- WARNING  --                                                 #" 
		echo -e "\t#          ¡ ALL DATA WILL BE ERASED. PLEASE, CHECK IF YOU HAVE BACKUP BEFORE CONTINUE.!                #"
		echo -e "\t#                        To continue type YES ..... (To EXIT type NO)                                   #" 
		echo -e "\t#########################################################################################################$def"
		funcion1 "$MENSAJES_1"
		
		echo -e "d\n1\nd\n2\nd\n3\n\nn\np\n1\n\n\nw" | fdisk ${arraydispo3[$NUMDISCO]} 2>/dev/null
		echo -e "$rojo \nType uppercase YES to continue and type your new disk password.$def"
		cryptsetup --verbose --verify-passphrase luksFormat ${arraydispo[$NUMDISCO]}
		funcion2 "$MENSAJES_7" "$MENSAJES_5"
		echo -e "$rojo \nType your password to open and format disk.$def"
		LUKSUUID=`cryptsetup luksUUID ${arraydispo[$NUMDISCO]}`
		cryptsetup luksOpen ${arraydispo[$NUMDISCO]} $LUKSUUID
		funcion2 "$MENSAJES_7"
		mkfs.ext3 /dev/mapper/$LUKSUUID
		sleep 4
		cryptsetup luksClose $LUKSUUID # Cierra el dispositivo virtual creado
		#Creacion del fichero de desbloqueo
		FECHA=`date +%Y%m%d`
		KEY=$LUKSUUID.$USUARIO.$FECHA.key # nombre del fichero. con el UUID y la fecha actual
		head -c 2880 /dev/urandom | uuencode -m - | head -n 65 | tail -n 64 > /tmp/$KEY #creación del fichero de desbloqueo que se guardara en el servidor.
		chmod 400 /tmp/$KEY 
		chown $USUARIO:$GRUPO /tmp/$KEY
		
		SEMF=SI
		while [ $? != 0 ] || [ $SEMF == SI ] ; do
			SEMF=NO
			echo -e "$rojo\nType your password to unmount device.$def\n"
			cryptsetup luksAddKey ${arraydispo[$NUMDISCO]} /tmp/$KEY >/dev/null 2>&1 # Añade el fichero creado como llave de desbloqueo.
		done

		DIR= $RUTALLAVE

		if [ -d "$DIR" ] ; then
			runuser -l $USUARIO -c "mv /tmp/$KEY $DIR" # Control will enter here if $DIRECTORY exists.
		else 
			mv /tmp/$KEY /root
		fi
		echo -e "$verde\n**** ENCRYPTED DISK CORRECTLY, FOR MOUNT, YOU MUST USE OPTION 2 IN MAIN MENU. ****$def\n"
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 3
	fi
	VOLVER="VOLVER"
	;;

	2)  #OPCION MONTAR DISCO
	
	dispoLUKSUUID=`blkid | grep -i LUKS | sort | awk  -F '"' '{print $2}'` #cadena con el UUID de los dispositivos
	declare -a arraydispoLUKSUUID=($dispoLUKSUUID) #array con los UUID de los dispositivos.
	dispoLUKS=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g'` #cadena con los dispositivos "/dev/sdb1"......
	declare -a arraydispoLUKS=($dispoLUKS)
	dispoLUKS2=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g' |  sed 's/1//g'`  #cadena con los dispositvos sin numero "/dev/sdb" ...
	declare -a arraydispoLUKS2=($dispoLUKS2)
 	dispoLUKS3=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g' |  sed 's/1//g'| gawk -F / '{print $3}'` #cadena con los dispositivos sin numero y sin /dev/ "sdb"....
	declare -a arraydispoLUKS3=($dispoLUKS3)
#Bucle que crea la tabla que mostrará los dispositivos que tenemos conectados Y QUE ESTAN CIFRADOS. También almacena en los arrays definidos arriba los datos: MODELO, TAMAÑO, DISPOSITIVO, para usarlos cuando se seleccione el disco a cifrar.
		while [ $CONTADOR -lt ${#arraydispoLUKS[@]} ] ; do
			MODELO=`udevinfo -a -p /sys/block/${arraydispoLUKS3[$CONTADOR]} | grep -i model | awk -F '==' '{printf $2}' | sed 's/ /_/g'`	
			arrayMODELO=("${arrayMODELO[@]}" $MODELO) #array con el MODELO DE LOS DISCOS
			TAMANO=`fdisk -l ${arraydispoLUKS2[$CONTADOR]} | grep -i disk | grep -i ${arraydispoLUKS2[$CONTADOR]} | awk '{printf $3 $4}'`
			arrayTAMANO=("${arrayTAMANO[@]}" $TAMANO) #array con los TAMAÑOS DE LOS DISCOS
			TABLAP=" $CONTADOR------$MODELO------${arraydispoLUKS[$CONTADOR]}------$TAMANO"
			TABLA=$TABLA$TABLAP
			let CONTADOR=CONTADOR+1 
		done
	clear
#MENSAJE QUE INFORMA QUE NO HAY DISPOSITIVOS CONECTADOS
	if [ ${#arraydispoLUKS[@]} == 0 ] ; then 
		echo -e "$rojo\nTHERE AREN'T ENCRYPTED DEVICES CONNECTED, PLEASE, CONNECT SOME DEVICE AND RERUN THE PROGRAM. \n $def "
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 5
		continue
	fi
#SELECCIONAR DISCO verifica que el numero indicado es correcto, sino vuelve a pedir que indiques un número válido, mostrando de nuevo la tabla de seleccion de disco y dando opcion de salir.
	while [ "$ERROR" == "error" ] ; do
		SEMFENTRADA=NO
		clear
		echo -e "${#arraydispoLUKS[@]} ENCRYPTED CONNECTED DEVICES\n"
		for TABLAFOR in $TABLA ; do echo -e $TABLAFOR ;  done
			echo -e "\n $rojo**** SELECT NUMBER DISK TO MOUNT **** $def"
			echo -e	"$rojo(to return to main menu, type Q and press ENTER.)\n$def"
			read NUMDISCO
			case $NUMDISCO in
				Q)
				  echo -e "$MENSAJES_2"
				  echo -e "$MENSAJES_6"
                		  sleep 3
				  continue 2 ;;
				*)
			
				   for AA in {0..100} ; do
					if [ $AA == $NUMDISCO ] ; then  
						SEMFENTRADA=SI
						break
					fi 
				done
			if [ $SEMFENTRADA == SI ] ; then 
				if [ "${arraydispoLUKS[$NUMDISCO]}" != "" ] && [ "$NUMDISCO" != "" ] ; then
					ERROR="OK"
					else 
					echo -e "\n $rojo**** THIS NUMBER IS WRONG ****$def\n"
					echo -e $MENSAJES_5
					ERROR="error"
					read
				fi
			fi  ;;
			esac
		done
	MENSAJES_3="$verde Disk $NUMDISCO selected ${arrayMODELO[$NUMDISCO]} ${arraydispo[$NUMDISCO]} ${arrayTAMANO[$NUMDISCO]} $def "
	funcion1 "$MENSAJES_1"
	MONTADO=`mount | grep /dev/mapper/${arraydispoLUKSUUID[$NUMDISCO]}`
	if [ "$MONTADO" != "" ] ; then 
		echo -e "$rojo\nTHIS DISK IS MOUNTED, NOT DONE ANYTHING.$def\n"
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 3
		continue
	  else
		LUKSUUID=`cryptsetup luksUUID ${arraydispoLUKS[$NUMDISCO]}`
		mkdir /media/$LUKSUUID 2>/dev/null
		echo -e "$rojo \nType your password to unlock device.$def"
		cryptsetup luksOpen ${arraydispoLUKS[$NUMDISCO]} $LUKSUUID
		funcion2 "$MENSAJES_8"
		mount /dev/mapper/$LUKSUUID /media/$LUKSUUID
		chmod 777 /media/$LUKSUUID
		echo -e "\n$verde DISK IS MOUNTED IN /media/$LUKSUUID $def\n"
		/sbin/runuser -l $USER -c "konqueror /media/${LUKSUUID} >/dev/null 2>&1 &"  # Lanza una ventana en la ruta del dispositivo.
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
	fi
	sleep 5  ;;
	    
	3) #OPCION DESMONTAR DISCO CIFRADO

	MONTADOC=`mount | grep -i /dev/mapper/ | awk '{print $1}'` #Dispositivos Montados que ya estan cifrados.
	declare -a arrayMONTADOS=($MONTADOC)
	MONTADOSLUKSUUID=`mount | grep -i /dev/mapper/ | awk '{print $1}' |  awk -F "/" '{print $4}'`
	declare -a arrayMONTADOSUUID=($MONTADOSLUKSUUID)	
	MONTADOLUKS2=`blkid | grep -i luks | grep -i /dev/sd | sort | awk '{print $1}' | sed 's/:/ /g' |  sed 's/1//g'`
	declare -a arrayMONTADOLUKS2=($MONTADOLUKS2)
	MONTADOLUKS3=`blkid | grep -i luks | grep -i /dev/sd | sort | awk '{print $1}' |  sed 's/:/ /g' |  sed 's/1//g'| gawk -F / '{print $3}'`
	declare -a arrayMONTADOLUKS3=($MONTADOLUKS3)
	declare -a arrayMONTADOLUKS=()
	declare -a arrayTAMANOMONT=()
	declare -a arrayMODELOMONT=()

#Bucle que crea la tabla que mostrará los dispositivos CIFRADOS que tenemos MONTADOS . También almacena en los arrays definidos arriba los datos: MODELO, TAMAÑO, DISPOSITIVO, para usarlos cuando se seleccione el disco a cifrar.	  
	while [ $CONTADOR -lt ${#arrayMONTADOS[@]} ] ; do
		
		MONTADOLUKS=`blkid | grep -i ${arrayMONTADOSUUID[$CONTADOR]} | grep -i /dev/sd | sort | awk '{print $1}' |  sed 's/:/ /g'`
		arrayMONTADOLUKS=("${arrayMONTADOLUKS[@]}" $MONTADOLUKS)	
		MODELOMONT=`udevinfo -a -p /sys/block/${arrayMONTADOLUKS3[$CONTADOR]} | grep -i model | awk -F '==' '{printf $2}' | sed 's/ /_/g'` 
		arrayMODELOMONT=("${arrayMODELOMONT[@]}" $MODELOMONT) #array con el MODELO DE LOS DISCOS
		TAMANOMONT=`fdisk -l ${arrayMONTADOLUKS2[$CONTADOR]} | grep -i disk | grep -i ${arrayMONTADOLUKS2[$CONTADOR]} | awk '{printf $3 $4}'`
		arrayTAMANOMONT=("${arrayTAMANOMONT[@]}" $TAMANOMONT) #array con los TAMAÑOS DE LOS DISCOS
		TABLAP=" $CONTADOR------$MODELOMONT------${arrayMONTADOLUKS[$CONTADOR]}------$TAMANOMONT"
		TABLA=$TABLA$TABLAP
		let CONTADOR=CONTADOR+1 
	done
	clear
	if [ ${#arrayMONTADOS[@]} == 0 ] ; then 
			echo -e "$rojo THERE AREN'T ENCRYPTED DEVICES MOUNTED, PLEASE, CONNECT SOME DEVICE AND RERUN THE PROGRAM.\n $def "
			echo -e $MENSAJES_5
			read
			echo -e $MENSAJES_6
			sleep 5
			continue
	fi
#BUCLE QUE CREA LA TABLA DE LOS DISPOSITIVOS CONECTADOS QUE ESTAN CIFRADOS Y MONTADOS
	while [ "$ERROR" == "error" ] ; do
		SEMFENTRADA=NO
		clear
		echo -e "${#arrayMONTADOS[@]} ENCRIPTED DEVICES MOUNTED\n"
			for TABLAFOR in $TABLA ; do echo -e $TABLAFOR ;  done
				echo -e "\n $rojo**** SELECT NUMBER DISK TO UNMOUNT **** $def"
				echo -e	"$rojo(to return to main menu, type Q and press ENTER.)\n$def"
				read NUMDISCO
				case $NUMDISCO in
				Q)
				  echo -e "$MENSAJES_2"
				  echo -e "$MENSAJES_6"
                		  sleep 3
				  continue 2 ;;
				*)
					for AA in {0..100} ; do
					      if [ $AA == $NUMDISCO ] ; then  
						SEMFENTRADA=SI
						break
					      fi 
					done
				if [ $SEMFENTRADA == SI ] ; then 
					if [ "${arrayMONTADOLUKS[$NUMDISCO]}" != "" ] && [ "$NUMDISCO" != "" ] ; then
						ERROR="OK"
						else 
						echo -e "\n $rojo**** THIS NUMBER IS WRONG ****$def\n"
						echo -e $MENSAJES_5
						ERROR="error"
						read
					fi
				fi ;;
				esac
	done	
	
	MENSAJES_3="$verde\nDisk $NUMDISCO selected ${arrayMODELOMONT[$NUMDISCO]} ${arrayMONTADOLUKS[$NUMDISCO]} ${arrayTAMANOMONT[$NUMDISCO]} $def "
	funcion1 "$MENSAJES_1" "$MENSAJES_3"
	umount /dev/mapper/${arrayMONTADOSUUID[$NUMDISCO]} >/dev/null 2>&1
	if [ $? != 0 ] ; then
		echo -e "$ROJO\nDEVICE IS BUSY, IT CAN'T UNMOUNT.\n"
		read
		continue
	fi
	cryptsetup luksClose ${arrayMONTADOSUUID[$NUMDISCO]}
 	rmdir /media/${arrayMONTADOSUUID[$NUMDISCO]}
	echo -e "\n$verde DISK UMOUNTED CORRECTLY, YOU CAN REMOVE THE DEVICE SAFELY.$def\n"
	echo -e $MENSAJES_6
	sleep 5
	;;
	
	4) # OPCION CAMBIAR CONTRASEÑA
	
	dispoLUKSUUID=`blkid | grep -i LUKS | sort | awk  -F '"' '{print $2}'` 
	declare -a arraydispoLUKSUUID=($dispoLUKSUUID)
	dispoLUKS=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g'`
	declare -a arraydispoLUKS=($dispoLUKS)
	dispoLUKS2=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g' |  sed 's/1//g'`
	declare -a arraydispoLUKS2=($dispoLUKS2)
	dispoLUKS3=`blkid | grep -i LUKS | sort | awk '{print $1}' |  sed 's/:/ /g' |  sed 's/1//g'| gawk -F / '{print $3}'`
	declare -a arraydispoLUKS3=($dispoLUKS3)
#Bucle que crea la tabla que mostrará los dispositivos que tenemos conectados Y QUE ESTAN CIFRADOS.. También almacena en los arrays definidos arriba los datos: MODELO, TAMAÑO, DISPOSITIVO, para usarlos cuando se seleccione el disco a cifrar.
		while [ $CONTADOR -lt ${#arraydispoLUKS[@]} ] ; do
			MODELO=`udevinfo -a -p /sys/block/${arraydispoLUKS3[$CONTADOR]} | grep -i model | awk -F '==' '{printf $2}' | sed 's/ /_/g'`	
			arrayMODELO=("${arrayMODELO[@]}" $MODELO) #array con el MODELO DE LOS DISCOS
			TAMANO=`fdisk -l ${arraydispoLUKS2[$CONTADOR]} | grep -i disk | grep -i ${arraydispoLUKS2[$CONTADOR]} | awk '{printf $3 $4}'`
			arrayTAMANO=("${arrayTAMANO[@]}" $TAMANO) #array con los TAMAÑOS DE LOS DISCOS
			TABLAP=" $CONTADOR------$MODELO------${arraydispoLUKS[$CONTADOR]}------$TAMANO"
			TABLA=$TABLA$TABLAP
			let CONTADOR=CONTADOR+1 
		done
	clear
	if [ ${#arraydispoLUKS[@]} == 0 ] ; then 
		echo -e "$rojo THERE AREN'T ENCRYPTED DEVICES MOUNTED, PLEASE, CONNECT SOME DEVICE AND RERUN THE PROGRAM.\n $def "
		echo -e $MENSAJES_5
		read
		echo -e $MENSAJES_6
		sleep 4
		continue
	fi
#BUCLE QUE CREA LA TABLA DE LOS DISPOSITIVOS CONECTADOS Y QUE ESTAN CIFRADOS
	while [ "$ERROR" == "error" ] ; do
		SEMFENTRADA=NO
		clear
		echo -e "${#arraydispoLUKS[@]} ENCRIPTED DEVICES MOUNTED\n"
		for TABLAFOR in $TABLA ; do echo -e $TABLAFOR ;  done
			echo -e "\n $rojo**** SELECT NUMBER DISK TO CHANGE PASSWORD **** $def"
			echo -e	"$rojo(to return to main menu, type Q and press ENTER.)\n$def"
			read NUMDISCO
			case $NUMDISCO in
				Q)echo -e "$MENSAJES_2"
				  echo -e "$MENSAJES_6"
                		  sleep 3
				  continue 2 ;;
				*)
				for AA in {0..100} ; do
					if [ $AA == $NUMDISCO ] ; then  
						SEMFENTRADA=SI
						break
					fi 
				done
				if [ $SEMFENTRADA == SI ] ; then 
					if [ "${arraydispoLUKS[$NUMDISCO]}" != "" ] && [ "$NUMDISCO" != "" ] ; then
						ERROR="OK"
						else 
						echo -e "\n $rojo**** THIS NUMBER IS WRONG ****$def\n"
						echo -e $MENSAJES_5
						ERROR="error"
						read
					fi
				fi ;;
			esac
		done
	MENSAJES_3="$verde Disk $NUMDISCO selected ${arrayMODELO[$NUMDISCO]} ${arraydispoLUKS[$NUMDISCO]} ${arrayTAMANO[$NUMDISCO]} $def "
	funcion1 "$MENSAJES_1" "$MENSAJES_3"
	SLOT0=`cryptsetup luksDump ${arraydispoLUKS[$NUMDISCO]} | grep -i enable | grep -i 0 | awk '{print $3}' | sed 's/://g'` #Comprueba el slot de luks que esta ocupado para que cuando el usuario cambie la contraseña este slot se borre.
	echo -e "$rojo\nType your present password and next type your new password.$def\n"
	cryptsetup luksAddKey ${arraydispoLUKS[$NUMDISCO]}
	funcion2 "$MENSAJES_8" "$MENSAJES_5"
	SEMF5=SI
		while [ $? != 0 ] || [ $SEMF5 == SI ] ; do
		SEMF5=NO
			if [ "${SLOT0}" = 0 ] ; then
			    echo -e "PLEASE WAIT, Deleting old password"
			    cryptsetup luksDelKey ${arraydispoLUKS[$NUMDISCO]} 0 #luksKillSlot (para RHEL6)
			else
			    echo -e "PLEASE WAIT, Deleting old password."
			    cryptsetup luksDelKey ${arraydispoLUKS[$NUMDISCO]} 2 #luksKillSlot (para RHEL6)
			fi
		done
	echo -e "$verde\nPASSWORD CHANGED CORRECTLY.$def\n"
	echo -e $MENSAJES_6
	sleep 4
	;;
	5) exit ;; #OPCION DE SALIDA DEL PROGRAMA
  esac
done
