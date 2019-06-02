#!/bin/bash
# PwnBox -  RogueAP Detector
# author : PwnBox
echo "
██████╗ ██╗    ██╗███╗   ██╗██████╗  ██████╗ ██╗  ██╗
██╔══██╗██║    ██║████╗  ██║██╔══██╗██╔═══██╗╚██╗██╔╝
██████╔╝██║ █╗ ██║██╔██╗ ██║██████╔╝██║   ██║ ╚███╔╝
██╔═══╝ ██║███╗██║██║╚██╗██║██╔══██╗██║   ██║ ██╔██╗
██║     ╚███╔███╔╝██║ ╚████║██████╔╝╚██████╔╝██╔╝ ██╗
╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
"
echo "vos interfaces"
ifconfig | grep -E 'wlan'
echo "saisir votre nom d'interface wlan0/wlan1/...: wlanX"
read interface
echo script running with : $interface
echo
PS3='Please enter your choice: '
options=("Option 1 - Configuration" "Option 2 - Surveillance" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1 - Configuration")
            echo "you chose choice 1 - Configuration mode "
            echo "Generation de la white list dans whitelist.txt"
	    iwlist $interface scan | grep -E 'ESSID|Address'
            sortie=$(iwlist $interface scan | grep -E 'ESSID|Address')
            echo $sortie > white.txt
            ;;
        "Option 2 - Surveillance")
            echo "you chose choice 2 - Surveillance mode"
	    echo "lire fichier"
	    sed 's/ /\n/g' white.txt | grep ESSID | sed -e 's/.*ESSID:"\(.*\)".*/\1/' > wlist.txt
	    # wlist.txt contient les ap legitimes
            echo "lister interface"
	    iwlist $interface scan | grep -E 'ESSID' | sed -e 's/.*ESSID:"\(.*\)".*/\1/' > apvisibles.txt
	    # cherche dans les ap visibles
	    cat apvisibles.txt  |  while read output
	    do
	    # parcourir liste des ap visibles
	    	sleep 5
                echo "sleep 5 secondes..."
	        if grep -q $output wlist.txt ; then
    			echo $output "présent dans la liste blanche"
	    	else
    			echo $output "absent de la liste blanche ! ALERTE !"
		# sendemail $output alerte
	    	sendEmail -o tls=yes -f monitoring.home.clauzel@gmail.com -t t.clauzel@gmail.com -s smtp.gmail.com:587 -xu monitoring.home.clauzel@gmail.com -xp PASSWORD -u "RogueAP DETECTED" -m " $output detected pls investigate  "
                fi
            done
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esa
