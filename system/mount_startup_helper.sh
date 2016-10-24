#!/bin/bash

# @author    	Kai Grassnick <info@kai-grassnick.de>
# @description 	mount my network drive and run some commands

SMB=0
CIFS_USER="<USERNAME>"

# Sudo Passwort abfragen
PASSW=$(zenity --entry --hide-text --text "Bitte Passwort für Sudo eingeben:" --title "Sudo Passwort?")
retsudo=$?
case $retsudo in
	1)
		exit 1
	;;
esac

# Prüfe ob Sudo funktioniert, falls nicht breche hier ab!
if ! echo -e "$PASSW\n" | sudo -S -s -- ls; then
	zenity --error --text "Sudo funktioniert nicht, gehe sterben..."
	exit 1
fi

# SMB Passwort abfragen, wenn cancel skip mount
input=$(zenity --entry --hide-text --text "Bitte Passwort für SMB/CIFS eingeben:" --title "SMB/CIFS Passwort?")
retval=$?
case $retval in
	0)
		CIFS_PASSWD=$input
	;;
	1)
		SMB=1
	;;
esac
if [[ $SMB -eq 0 ]]; then
	if ! echo -e "$PASSW\n" | sudo -S -s -- mount -t cifs -o user=$CIFS_USER,pass=$CIFS_PASSWD,uid=1000 //000.000.000.000/home/$CIFS_USER ~/_SHARE/home/; then
		zenity --error --text "Mount von: 'home' ist fehlgeschlagen"
	fi
	if ! echo -e "$PASSW\n" | sudo -S -s -- mount -t cifs -o user=$CIFS_USER,pass=$CIFS_PASSWD,uid=1000 //000.000.000.000/public ~/_SHARE/public/; then
		zenity --error --text "Mount von: 'public' ist fehlgeschlagen"
	fi
fi

echo -e "$PASSW\n" | sudo -S -s -- service nginx restart
echo -e "$PASSW\n" | sudo -S -s -- service php5-fpm restart
echo -e "$PASSW\n" | sudo -S -s -- service mysql restart

PASSW=""
CIFS_PASSWD=""

zenity --info --text "Done"
