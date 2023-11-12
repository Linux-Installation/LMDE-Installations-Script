#!/bin/bash
#(awk '{ print $2 }' /var/log/installer/media-info )
rep=""
pakete=""
service="" #be careful not fully implemented now!
remove=""

sudo apt install -y nala
sudo nala upgrade

export DEBIAN_FRONTEND=noninteractive
if [[ $( cat /etc/issue | cut -d" " -f1,2,3 ) != "LMDE 6 Faye" ]] 
then 
	read -p "Du benutzt kein LMDE 6 Faye. Wenn du das Script trotzdem fortsetzen möchtest drücke j!"
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Jj]$ ]]
	then
    		exit 1
	fi
fi
if [ $(uname -m) = x86_64 ]
then
	Bit=64
elif [ $(uname -m) = i686 ]
then
	Bit=32
else
	echo "Konnte weder eine 32 Bit, noch eine 64 Bit Version vorfinden!"
	echo "Breche ab!"
	exit 1
fi
#sudo sed -i "/recordfail_broken=/{s/1/0/}" /etc/grub.d/00_header
#sudo update-grub
#Config-Daten
verzeichnis=$(pwd)
config=$(pwd)/download

if [ "$1" = "" ] || [ "$1" = "rep" ]
then
#Kopiere bei Bedarf Firefox, Chromium Einstellungen
alterUser=`who | awk '{ print $1 }'`

for i in $(ls /home); do
if [ $i != "lost+found" ]		
then
    #dayon
    sudo mkdir -p /home/$i/.dayon
	sudo mv -f $config/.dayon /home/$i
	#hide Dayon Assistant
	sudo mkdir -p /home/$i/.local/share/applications
	sudo mv $config/.local/share/applications/dayon_assistant.desktop /home/$i/.local/share/applications/
	#Google Chrome
	declare dir=/home/$i/.config/google-chrome
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis .config/google-chrome existiert schon, soll es überschrieben werden? Dann drücke j!"
	#	echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Google Chrome nicht"
		else
		    overwriteChrome=true
		    sudo rm -rf /home/$i/.config/google-chrome
		fi
	fi
	if [ ! -d $dir ] || [ overwriteChrome==true ]
	then
		#echo $dir
		sudo mkdir -p /home/$i/.config
		sudo mv -f $config/.config/google-chrome /home/$i/.config								 
	fi		
	
	#Vivaldi
	declare dir=/home/$i/.config/vivaldi
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis .config/vivaldi existiert schon, soll es überschrieben werden? Dann drücke j!"
	#	echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Vivaldi nicht"
		else
		    overwriteChrome=true
		    sudo rm -rf /home/$i/.config/vivaldi
		fi
	fi
	if [ ! -d $dir ] || [ overwriteChrome==true ]
	then
		#echo $dir
		sudo mkdir -p /home/$i/.config
		sudo mv -f $config/.config/vivaldi /home/$i/.config								 
	fi	
	
	#firefox
	declare dir=/home/$i/.mozilla
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis Firefox existiert schon, soll es überschrieben werden? Dann drücke j!"
		echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Firefox nicht"
		else
		    overwriteFirefox=true
		    sudo rm -rf /home/$i/.mozilla
		fi
	fi
	if [ ! -d $dir ] || [ overwriteFirefox==true ]
	then
	    #echo $dir
		sudo mv -f $config/.mozilla /home/$i/
	fi
	#cinnamon
	declare dir=/home/$i/.config/cinnamon
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis Cinnamon existiert schon, soll es überschrieben werden? Dann drücke j!"
		echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Cinnamon nicht"
		else
		    overwriteCinnamon=true
		    sudo rm -rf /home/$i/.config/cinnamon
		fi
	fi
	if [ ! -d $dir ] || [ overwriteCinnamon==true ]
	then
	    #echo $dir
		sudo mv -f $config/.config/cinnamon /home/$i/.config/
	fi
	#autostart
	sudo mkdir -p /home/$i/.config/autostart/
	sudo mv -f $config/.config/autostart/* /home/$i/.config/autostart/*
	
	sudo chown -R $i:$i /home/$i
fi
done
fi
#Gaming on AMD/Intel
#read -p "Möchtest du Games spielen und hast eine AMD/Intel Grafikkarte? Dann drücke j!"
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Jj]$ ]]
#then
#  sudo add-apt-repository -y ppa:kisak/kisak-mesa
#	pakete=`echo "$pakete dxvk mesa-vulkan-drivers mesa-vulkan-drivers:i386"`
#fi

#Vivaldi (Chromium based Browser)
read -p "Soll Vivaldi (Chromium based Browser) installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list
    pakete=`echo "$pakete vivaldi-stable"`
fi


#flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ $Bit != 32 ]
then
	#https://github.com/Bajoja/indicator-kdeconnect
	read -p "Soll das Programm KDE-Connect-Monitor (Zugriff von und aufs Handy) installiert werden? Dann drücke j!"
	#echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Jj]$ ]]
	then
		##sudo add-apt-repository -y ppa:webupd8team/indicator-kdeconnect outdated!
		sudo flatpak -y install flathub com.github.bajoja.indicator-kdeconnect
		pakete=`echo "$pakete kdeconnect"`
	fi
	#Fritz!Box
	read -p "Soll das Programm Roger Router (ehemals ffgtk) für die Fritz!Box installiert werden? Dann drücke j!"
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Jj]$ ]]
	then
		sudo flatpak -y install flathub org.tabos.roger  
	fi

	#ProtonUp
	read -p "Soll das Programm ProtonUp-Qt installiert werden? Dann drücke j!"
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Jj]$ ]]
	then
		sudo flatpak -y install flathub net.davidotek.pupgui2  
	fi
fi
#Laptop Akkulaufzeit
read -p "Ist dies ein Laptop? Soll die Akkulaufzeit erhöht werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete tlp tlp-rdw smartmontools ethtool"`
	service=`echo "$service tlp.service"`
	if [ $Bit != 32 ]
	then
		sudo flatpak -y install flathub com.github.d4nj1.tlpui
	fi
	#TODO Find PPA for TLPUI - https://github.com/d4nj1/TLPUI
fi

#grub-customizer
read -p "Are several OS used? Shall grub-customizer be installed? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete grub-customizer"`
fi


read -p "Soll Evolution installiert werden? Dann drücke j! (ersetzt Thunderbird)"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete evolution"`
fi

read -p "Soll Thunderbird gelöscht werden? Dann drücke j! (kann durch Evolution ersetzt werden)"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	remove=`echo "$remove thunderbird*"`
fi

paketerec="digikam exiv2 kipi-plugins graphicsmagick-imagemagick-compat hw-probe"
pakete=`echo "$pakete krita-l10n mint-neta-codecs pidgin nfs-common libdvd-pkg smartmontools unoconv mediathekview python3-axolotl python3-gnupg gnome-software gnome-software-plugin-flatpak fonts-symbola vlc libxvidcore4 libfaac0 gnupg2 lutris dayon kate konsole element-desktop"`
#remove=`echo "$remove firefox*"`

#sudo snap remove firefox
sudo nala remove -y $remove


cd ~/Downloads/
sudo gpg
#Element
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list

#dayon
gpg --no-default-keyring --keyring /usr/share/keyrings/dayon.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E0C34A1B0FBCA00022B557F61FE808F293A218F0
sudo add-apt-repository "deb [signed-by=/usr/share/keyrings/dayon.gpg] https://ppa.launchpadcontent.net/regal/dayon/ubuntu noble main"

#echo $rep > rep.log

#IFS=" "
#oIFS=$IFS
#for i in $rep; do
#	sudo add-apt-repository -y $i
#done
#fi
sudo nala upgrade
echo $paketerec > paketerec.log
sudo nala install --no-install-recommends $paketerec
echo $pakete > pakete.log
sudo nala -y install $pakete

#hide Dayon Assistant
sudo mv $config/usr/share/applications/dayon_assistant.desktop /usr/share/applications/

sudo update-alternatives --set x-terminal-emulator /usr/bin/konsole

sudo dpkg-reconfigure libdvd-pkg


#sudo snap install carnet

if [ ! -z $service ]
then
sudo systemctl enable $service
fi
sudo nala install -y --fix-broken
sudo mintupdate-automation upgrade enable
#Hardware probe
sudo -E hw-probe -all -upload
sudo nala purge -y hw-probe

#Aufräumen
rm -rf $verzeichnis/Install-Skript
