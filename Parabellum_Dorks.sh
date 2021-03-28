#!/bin/bash
# Enumeração com google Dorks 
# By WTECHSEC


# Variables
## General

example_domain="example.com" 				# Exemplo de entrada do site
sleeptime=6						# Atraso entre as consultas
domain=$1 						# Obendo domínio
browser='Mozilla/5.0_(MSIE;_Windows_11)'	        # Informando o navegador no curl
gsite="site:$domain" 					# Google Site

## Paginas de Login
lpadmin="inurl:admin"
lplogin="inurl:login"
lpadminlogin="inurl:adminlogin"
lpcplogin="inurl:cplogin"
lpweblogin="inurl:weblogin"
lpquicklogin="inurl:quicklogin"
lpwp1="inurl:wp-admin"
lpwp2="inurl:wp-login"
lpportal="inurl:portal"
lpuserportal="inurl:userportal"
lploginpanel="inurl:loginpanel"
lpmemberlogin="inurl:memberlogin"
lpremote="inurl:remote"
lpdashboard="inurl:dashboard"
lpauth="inurl:auth"
lpexc="inurl:exchange"
lpfp="inurl:ForgotPassword"
lptest="inurl:test"
loginpagearray=($lpadmin $lplogin $lpadminlogin $lpcplogin $lpweblogin $lpquicklogin $lpwp1 $lpwp2 $lpportal $lpuserportal $lploginpanel $memberlogin $lpremote $lpdashboard $lpauth $lpexc $lpfp $lptest)

## Filetypes
ftdoc="filetype:doc"						# Filetype DOC (MsWord 97-2003)
ftdocx="filetype:docx"						# Filetype DOCX (MsWord 2007+)
ftxls="filetype:xls"						# Filetype XLS (MsExcel 97-2003)
ftxlsx="filetype:xlsx"						# Filetype XLSX (MsExcel 2007+)
ftppt="filetype:ppt"						# Filetype PPT (MsPowerPoint 97-2003)
ftpptx="filetype:pptx"						# Filetype PPTX (MsPowerPoint 2007+)
ftmdb="filetype:mdb"						# Filetype MDB (Ms Access)
ftpdf="filetype:pdf"						# Filetype PDF
ftsql="filetype:sql"						# Filetype SQL
fttxt="filetype:txt"						# Filetype TXT
ftrtf="filetype:rtf"						# Filetype RTF
ftcsv="filetype:csv"						# Filetype CSV
ftxml="filetype:xml"						# Filetype XML
ftconf="filetype:conf"						# Filetype CONF
ftdat="filetype:dat"						# Filetype DAT
ftini="filetype:ini"						# Filetype INI
ftlog="filetype:log"						# Filetype LOG
ftidrsa="index%20of:id_rsa%20id_rsa.pub"	                # File ID_RSA
filetypesarray=($ftdoc $ftdocx $ftxls $ftxlsx $ftppt $ftpptx $ftmdb $ftpdf $ftsql $fttxt $ftrtf $ftcsv $ftxml $ftconf $ftdat $ftini $ftlog $ftidrsa)

## Directory traversal
dtparent='intitle:%22index%20of%22%20%22parent%20directory%22' 	# Cminho de diretorio 
dtdcim='intitle:%22index%20of%22%20%22DCIM%22' 			# Foto
dtftp='intitle:%22index%20of%22%20%22ftp%22' 			# FTP
dtbackup='intitle:%22index%20of%22%20%22backup%22'		# BackUp
dtmail='intitle:%22index%20of%22%20%22mail%22'			# Mail
dtpassword='intitle:%22index%20of%22%20%22password%22'		# Password
dtpub='intitle:%22index%20of%22%20%22pub%22'			# Pub
dirtravarray=($dtparent $dtdcim $dtftp $dtbackup $dtmail $dtpassword $dtpub)

# Header
echo -e "\n\e[01;33m\e[07m############################################################################\e[00m"
echo -e "\e[01;33m#                                                                          #\e[01;33m"
echo -e "\e[01;33m#"  "\e[01;33m  __        __  _____  _______    ___   _   _   _____  ______   ____     \e[01;33m#"  
echo -e "\e[01;33m#"  "\e[01;33m  \ \      / / |_   _| | ____|  / ___| | | | | /  ___| | ____| / ___|    \e[01;33m#"  
echo -e "\e[01;33m#"  "\e[01;33m   \ \ /\ / /    | |   |  _|   | |     | |_| | \___ \  |  _|   | |       \e[01;33m#" 
echo -e "\e[01;33m#"  "\e[01;33m    \ V  V /     | |   | |___  | |___  |  _  | ___) |  |  |__  | |__     \e[01;33m#"  
echo -e "\e[01;33m#"  "\e[01;33m     \_/\_/      |_|   |_____|  \____| |_| |_| |____/  |_____| \____|    \e[01;33m#"  
echo -e "\e[01;33m#                                                                          \e[01;33m#"  
echo -e "\e[01;33m#\e[05m"  "\e[01;33m                          PARABELLUM DORKS GOOGLE                       \e[00m" "\e[01;33m#\e[00m"
echo -e "\e[01;33m#                                                                          #\e[00m" 
echo -e "\e[01;33m\e[07m############################################################################\e[00m"

echo -e "\e[00;33m# Ver: \e[01;34m1.0                 \e[00m" "\e[01;31m$ver\e[00m"
echo -e "\e[00;33m# Use proxy                 \e[00m" "\e[01;31m$ver\e[00m"
# Verificando Domínio
	if [ -z "$domain" ] 
	then
		echo -e "\e[00;33m# Exemplo:\e[00m" "\e[01;34m$0 $example_domain \e[00m\n"
		exit
	else
			echo -e "\e[00;33m# Obtendo Informações sobre:   \e[00m" "\e[01;34m$domain\e[00m"
			echo -e "\e[00;33m# Atraso entre as consultas:   \e[00m" "\e[01;34m$sleeptime\e[00m" "\e[01;34msec\e[00m\n"
	fi

# Função de pesquisa sobre o site ### INÍCIO
function Query {
		result="";
		for start in `seq 0 10 40`; # Último número - quantidade de respostas possíveis
			do
				query=$(echo; curl -sS -A $browser "https://www.google.com/search?q=$gsite%20$1&start=$start&client=firefox-b-e")

				checkban=$(echo $query | grep -io "https://www.google.com/sorry/index")
				if [ "$checkban" == "https://www.google.com/sorry/index" ]
				then 
					echo -e "O Google acha que você é um robô e você foi bloqueado;) espere um pouco para cancelar o bloqueio ou altere seu ip!"; 
					exit;
				fi
				
				checkdata=$(echo $query | grep -Eo "(http|https)://[a-zA-Z0-9./?=_~-]*$domain/[a-zA-Z0-9./?=_~-]*")
				if [ -z "$checkdata" ]
					then
						sleep $sleeptime; # Para evitar bloqueio
						break; # Sai do loop
					else
						result+="$checkdata ";
						sleep $sleeptime; # Para evitar bloqueio
				fi
			done

		# Echo resultados
		if [ -z "$result" ] 
			then
			           echo -e "\e[00;33m           
			                   [\e[00m\e[01;34m-\e[00m\e[00;33m]\e[00m Sem resultados"
			else
				IFS=$'\n' sorted=($(sort -u <<<"${result[@]}" | tr " " "\n")) # Resultados com key única
				echo -e " "
				for each in "${sorted[@]}"; do echo -e "     \e[00;33m[\e[00m\e[00;31m+\e[00m\e[00;33m]\e[00m $each"; done
		fi

		# Variáveis não definidas
		unset IFS sorted result checkdata checkban query
}
# Função de pesquisa sobre o site ### FIM


# Função para imprimir os resultados ### INÍCIO
function PrintTheResults {
	for dirtrav in $@; 
		do echo -en "\e[01;33m[\e[00m\e[01;34m*\e[00m\e[01;33m]\e[00m" Verificando $(echo $dirtrav | cut -d ":" -f 2 | tr '[:lower:]' '[:upper:]' | sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b") "\t" 
		Query $dirtrav 
	done
echo " "
}
# Função para imprimir os resultados ### FINAL

echo -e "\e[01;34mVerificando Página de Login:\e[00m"; PrintTheResults "${loginpagearray[@]}";
echo -e "\e[01;34mVerificando Arquivos Especificos:\e[00m"; PrintTheResults "${filetypesarray[@]}";
echo -e "\e[01;34mVerificando Caminho do Diretório:\e[00m"; PrintTheResults "${dirtravarray[@]}";
