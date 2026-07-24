#FLATPAK 
sudo apt install flatpak -y && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    #Baobab(wykorzystanie dysku)
        flatpak install flathub org.gnome.baobab -y
    #Bitwarden
        flatpak install flathub com.bitwarden.desktop
    #Brave
        flatpak install flathub com.brave.Browser
    #Callibre(ebooks editor)
        flatpak install flathub com.calibre_ebook.calibre
    #Deluge(Torrenty)
        flatpak install flathub org.deluge_torrent.deluge
    #Discord
        flatpak install flathub com.discordapp.Discord
    #Gimp
        flatpak install flathub org.gimp.GIMP
    #Google Chrome
        flatpak install flathub com.google.Chrome
    #HeroicGameLauncher
        flatpak install flathub com.heroicgameslauncher.hgl
    # JDownloader
        flatpak install flathub org.jdownloader.JDownloader
    #Monitor systemu
        flatpak install flathub io.missioncenter.MissionCenter
    #Lutris
        flatpak install flathub net.lutris.Lutris
    #OBS
        flatpak install flathub com.obsproject.Studio
    #OnlyOffice
        flatpak install flathub org.onlyoffice.desktopeditors
    #Signal
        flatpak install flathub org.signal.Signal
    #Steam
        flatpak install flathub com.valvesoftware.Steam
    #Virt-Manager
        flatpak install flathub org.virt_manager.virt-manager
    #VLC
        flatpak install flathub org.videolan.VLC
        
#classic
    #7zip
        sudo apt install p7zip-full -y
    #Gparted
        sudo apt install gparted -y 
    #yt-dlp
        sudo apt update && sudo apt install -y ffmpeg curl && sudo curl -L https://github.com -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp
