<<<<<<< HEAD
#FLATPAK 
sudo apt install flatpak
    #Callibre(ebooks editor)
        flatpak install flathub com.calibre_ebook.calibre
    #Gimp
        flatpak install flathub org.gimp.GIMP
    #Google Chrome
        flatpak install flathub com.google.Chrome
    #HeroicGameLauncher
        flatpak install flathub com.heroicgameslauncher.hgl
    JDownloader
        flatpak install flathub org.jdownloader.JDownloader
    #OBS
        flatpak install flathub com.obsproject.Studio
    #OnlyOffice
        flatpak install flathub org.onlyoffice.desktopeditors
    #Signal
        flatpak install flathub org.signal.Signal
    #Steam
        flatpak install flathub com.valvesoftware.Steam
    #VLC
        flatpak install flathub org.videolan.VLC
        
#classic
    #7zip
        sudo apt install p7zip-full
    #yt-dlp
        sudo apt update && sudo apt install -y ffmpeg curl && sudo curl -L https://github.com -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp
=======
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Proszę uruchomić skrypt z uprawnieniami root (np. sudo ./install.sh)"
  exit
fi

LOG_FILE="/tmp/instalacja_programow.log"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"
> "$LOG_FILE"

# ==============================================================================
# 1. DEFINICJE INSTALACJI (Nazwy funkcji zostają techniczne i czyste)
# ==============================================================================

# --- SEKCJA: KONFIGURACJA WSTĘPNA ---
install_Setup_Flatpak() {
    apt-get update -y >> "$LOG_FILE" 2>&1
    apt-get install -y flatpak >> "$LOG_FILE" 2>&1
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
}

install_Setup_Snap() {
    apt-get update -y >> "$LOG_FILE" 2>&1
    apt-get install -y snapd >> "$LOG_FILE" 2>&1
}

install_Link_Bash_Aliases() {
    if [ -n "$SUDO_USER" ]; then
        local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
        
        local SRC="$DOTFILES_DIR/.bash_aliases"
        local TGT="/home/$SUDO_USER/.bash_aliases"
        
        if [ -f "$SRC" ]; then
            rm -f "$TGT"
            ln -sf "$SRC" "$TGT"
            chown $SUDO_USER:$SUDO_USER "$TGT"
            echo "Pomyślnie utworzono dowiązanie dla .bash_aliases" >> "$LOG_FILE" 2>&1
        else
            echo "BŁĄD: Plik źródłowy $SRC nie istnieje w repozytorium dotfiles!" >> "$LOG_FILE" 2>&1
            return 1
        fi
    fi
}

# --- SEKCJA: PROGRAMY ---
# --- ADMINISTRACJA ---
install_7zip() {
    apt-get install -y 7zip >> "$LOG_FILE" 2>&1
}
install_Baobab() {
    flatpak install -y flatpak install flathub org.gnome.baobab>> "$LOG_FILE" 2>&1
}
install_GParted() {
    flatpak install -y 	sudo apt install gparted>> "$LOG_FILE" 2>&1
}
install_Monitor_systemu() {
    flatpak install -y 	flatpak install flathub io.missioncenter.MissionCenter>> "$LOG_FILE" 2>&1
}
install_Todoist() {
    flatpak install -y 	flatpak install flathub com.todoist.Todoist>> "$LOG_FILE" 2>&1
}


install_Calibre() {
    apt-get install -y libopengl0 libxcb-cursor0 >> "$LOG_FILE" 2>&1
    wget -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin >> "$LOG_FILE" 2>&1
}
install_Gimp() {
    apt-get install -y gimp >> "$LOG_FILE" 2>&1
}
install_Google_Chrome() {
    wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >> "$LOG_FILE" 2>&1
    apt-get install -y /tmp/google-chrome-stable_current_amd64.deb >> "$LOG_FILE" 2>&1
}
install_Heroic(){
    apt-get install -y curl >> "$LOG_FILE" 2>&1
    URL=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | grep "browser_download_url" | grep "amd64.deb" | sed -E 's/.*"([^"]+)".*/\1/') && curl -L -o /tmp/heroic.deb "$URL" >> "$LOG_FILE" 2>&1
    apt-get install -y /tmp/heroic.deb >> "$LOG_FILE" 2>&1
}
install_JDownloader() {
    flatpak install -y flathub org.jdownloader.JDownloader >> "$LOG_FILE" 2>&1
}
install_OnlyOffice(){
    wget -O /tmp/onlyoffice.deb https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb >> "$LOG_FILE" 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/onlyoffice.deb >> "$LOG_FILE" 2>&1
}
install_Steam() {
    wget -O /tmp/steam.deb https://cdn.fastly.steamstatic.com/client/installer/steam.deb >> "$LOG_FILE" 2>&1
    apt-get install -y /tmp/steam.deb >> "$LOG_FILE" 2>&1
    
    if [ -n "$SUDO_USER" ]; then
        USER_UID=$(id -u "$SUDO_USER")
        sudo -u "$SUDO_USER" env DISPLAY="${DISPLAY:-:0}" XAUTHORITY="/home/$SUDO_USER/.Xauthority" XDG_RUNTIME_DIR="/run/user/$USER_UID" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus" steam > /dev/null 2>&1 &
        sleep 2
    fi
}
install_VLC() {
    apt-get install -y vlc >> "$LOG_FILE" 2>&1
}
install_yt-dlp(){
    apt-get install ffmpeg -y >> "$LOG_FILE" 2>&1
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp >> "$LOG_FILE" 2>&1
    chmod a+rx /usr/local/bin/yt-dlp >> "$LOG_FILE" 2>&1
}

# ==============================================================================
# 2. FUNKCJE SPRAWDZAJĄCE
# ==============================================================================
check_standard() {
    local cmd_name=$1
    if command -v "$cmd_name" >/dev/null 2>&1; then echo "Zainstalowano"; else echo "Nie zainstalowano"; fi
}

check_flatpak() {
    local app_id=$1
    if command -v flatpak >/dev/null 2>&1 && flatpak list --app | grep -q "$app_id"; then echo "Zainstalowano"; else echo "Nie zainstalowano"; fi
}

check_snap() {
    local snap_name=$1
    if command -v snap >/dev/null 2>&1 && snap list | grep -q "^$snap_name\b"; then echo "Zainstalowano"; else echo "Nie zainstalowano"; fi
}

check_symlink() {
    local target_path=$1
    if [ -L "$target_path" ]; then echo "Skonfigurowano"; else echo "Nie skonfigurowano"; fi
}

# ==============================================================================
# TWORZENIE SKRYPTU PODGLĄDU LOGÓW
# ==============================================================================
VIEWER_SCRIPT="/tmp/pobieraj_logi.sh"
rm -f "$VIEWER_SCRIPT"

cat << 'EOF' > "$VIEWER_SCRIPT"
#!/bin/bash
echo "=== PODGLĄD INSTALACJI NA ŻYWO ==="
echo "----------------------------------"
tail -f /tmp/instalacja_programow.log &
TAIL_PID=$!

while [ ! -f /tmp/install_done ]; do
    sleep 0.5
done

kill $TAIL_PID 2>/dev/null
exit 0
EOF
chmod +x "$VIEWER_SCRIPT"
chown $SUDO_USER:$SUDO_USER "$VIEWER_SCRIPT"


# ==============================================================================
# 3. GŁÓWNA PĘTLA PROGRAMU
# ==============================================================================
while true; do

    MENU_OPTIONS=()

    # Kategoria: Konfiguracja wstępna (ŁADNE NAZWY WYŚWIETLANE)
    MENU_OPTIONS+=("[--KONFIGURACJA--]"       "[Zaznacz całą sekcję]" OFF)
    MENU_OPTIONS+=("Dowiązanie .bash_aliases" "$(check_symlink /home/$SUDO_USER/.bash_aliases)" OFF)
    MENU_OPTIONS+=("Środowisko Flatpak"       "$(check_standard flatpak)" OFF)
    MENU_OPTIONS+=("Środowisko Snap"          "$(check_standard snap)" OFF)


    # Kategoria: Administracja
    MENU_OPTIONS+=("[--ADMINISTRACJA--]"          "[Zaznacz całą sekcję]" OFF)
    MENU_OPTIONS+=("7zip"                         "$(check_standard 7z)" OFF)
    MENU_OPTIONS+=("Baobab - wykorzystanie dysku" "$(check_flatpak baobab)" OFF)
    MENU_OPTIONS+=("GParted"                      "$(check_standard gparted)" OFF)
    MENU_OPTIONS+=("Monitor systemu"              "$(check_flatpak MissionCenter)" OFF)
    MENU_OPTIONS+=("Todoist"                      "$(check_flatpak Todoist)" OFF)


    MENU_OPTIONS+=("[--PRZEGLĄDARKI--]"       "[Zaznacz całą sekcję]" OFF)
    MENU_OPTIONS+=("Google Chrome"            "$(check_standard google-chrome)" OFF)

    # Kategoria: Multimedia i Grafika
    MENU_OPTIONS+=("[--MULTIMEDIA--]"         "[Zaznacz całą sekcję]" OFF)
    MENU_OPTIONS+=("Odtwarzacz VLC"           "$(check_standard vlc)" OFF)
    MENU_OPTIONS+=("Program GIMP"             "$(check_standard gimp)" OFF)
    MENU_OPTIONS+=("Narzędzie yt-dlp"         "$(check_standard yt-dlp)" OFF)

    # Kategoria: Biuro i Narzędzia
    MENU_OPTIONS+=("[--NARZĘDZIA--]"          "[Zaznacz całą sekcję]" OFF)

    MENU_OPTIONS+=("E-booki Calibre"          "$(check_standard calibre)" OFF)
    MENU_OPTIONS+=("Pakiet OnlyOffice"        "$(check_standard onlyoffice-desktopeditors)" OFF)
    MENU_OPTIONS+=("JDownloader 2 (Flatpak)"  "$(check_flatpak org.jdownloader.JDownloader)" OFF)

    # Kategoria: Rozrywka i Gry
    MENU_OPTIONS+=("[--GRY--]"                "[Zaznacz całą sekcję]" OFF)
    MENU_OPTIONS+=("Platforma Steam"          "$(check_standard steam)" OFF)
    MENU_OPTIONS+=("Heroic Games Launcher"    "$(check_standard heroic)" OFF)

    CHOICES=$(whiptail --title "Automatyczny Instalator Programów" --checklist \
    "Wybierz pozycje (Spacja - zaznacz, Nagłówek zaznacza grupę, Enter - zatwierdź):" 24 78 16 \
    "${MENU_OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

    # Sprawdzenie wyjścia/anulowania przed użyciem eval
    if [ -z "$CHOICES" ]; then
      clear
      echo "Zakończono pracę z instalatorem. Do zobaczenia!"
      exit 0
    fi

    # NOWOŚĆ: Bezpieczne parsowanie tekstu ze spacjami do tablicy
    eval RAW_APPS=($CHOICES)

    # Rozwijanie nagłówków oraz mapowanie ŁADNYCH NAZW na NAZWY FUNKCJI
    ALL_SELECTED=()
    for ITEM in "${RAW_APPS[@]}"; do
        case "$ITEM" in
            "[--KONFIGURACJA--]")
                ALL_SELECTED+=("Setup_Flatpak" "Setup_Snap" "Link_Bash_Aliases")
                ;;
            "[--ADMINISTRACJA--]")
                ALL_SELECTED+=("7zip" "Baobab" "GParted" "Monitor_systemu" "Todoist")
                ;;




            "[--PRZEGLĄDARKI--]")
                ALL_SELECTED+=("Google_Chrome")
                ;;
            "[--MULTIMEDIA--]")
                ALL_SELECTED+=("VLC" "Gimp" "yt-dlp")
                ;;
            "[--NARZĘDZIA--]")
                ALL_SELECTED+=("7zip" "Calibre" "OnlyOffice" "JDownloader")
                ;;
            "[--GRY--]")
                ALL_SELECTED+=("Steam" "Heroic")
                ;;
            
            # MAPOWANIE: Ładna nazwa z menu -> Sufiks funkcji instalacyjnej
            "Środowisko Flatpak")           ALL_SELECTED+=("Setup_Flatpak") ;;
            "Środowisko Snap")              ALL_SELECTED+=("Setup_Snap") ;;
            "Dowiązanie .bash_aliases")     ALL_SELECTED+=("Link_Bash_Aliases") ;;
            "7zip")                         ALL_SELECTED+=("7zip") ;;
            "Baobab - wykorzystanie dysku") ALL_SELECTED+=("Baobab") ;;
            "GParted")                      ALL_SELECTED+=("GParted") ;;
            "Monitor systemu")              ALL_SELECTED+=("Monitor_systemu") ;;
            "Todoist")                      ALL_SELECTED+=("Todoist") ;;


            "Google Chrome")                ALL_SELECTED+=("Google_Chrome") ;;
            "Odtwarzacz VLC")               ALL_SELECTED+=("VLC") ;;
            "Program GIMP")                 ALL_SELECTED+=("Gimp") ;;
            "Narzędzie yt-dlp")             ALL_SELECTED+=("yt-dlp") ;;
            "E-booki Calibre")              ALL_SELECTED+=("Calibre") ;;
            "Pakiet OnlyOffice")            ALL_SELECTED+=("OnlyOffice") ;;
            "JDownloader 2 (Flatpak)")      ALL_SELECTED+=("JDownloader") ;;
            "Platforma Steam")              ALL_SELECTED+=("Steam") ;;
            "Heroic Games Launcher")        ALL_SELECTED+=("Heroic") ;;
        esac
    done

    # Usuwanie duplikatów
    SELECTED_APPS=()
    declare -A SEEN_APPS
    for APP in "${ALL_SELECTED[@]}"; do
        if [[ -z "${SEEN_APPS[$APP]}" ]]; then
            SEEN_APPS[$APP]=1
            SELECTED_APPS+=("$APP")
        fi
    done

    TOTAL_APPS=${#SELECTED_APPS[@]}

    if [ "$TOTAL_APPS" -eq 0 ]; then
        whiptail --title "Błąd" --msgbox "Nie wybrano poprawnych programów do instalacji." 8 50
        continue
    fi

    CURRENT_APP=0

    # ==============================================================================
    # 4. WYKONYWANIE I PASEK POSTĘPU
    # ==============================================================================
    rm -f /tmp/install_done

    if [ -n "$SUDO_USER" ]; then
        USER_UID=$(id -u "$SUDO_USER")
        export DISPLAY="${DISPLAY:-:0}"
        export XAUTHORITY="/home/$SUDO_USER/.Xauthority"
        export XDG_RUNTIME_DIR="/run/user/$USER_UID"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus"

        if command -v gnome-terminal >/dev/null 2>&1; then
            sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gnome-terminal -- "$VIEWER_SCRIPT" 2>/dev/null &
        elif command -v kgx >/dev/null 2>&1; then
            sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" kgx run "$VIEWER_SCRIPT" 2>/dev/null &
        elif command -v io.elementary.terminal >/dev/null 2>&1; then
            sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" io.elementary.terminal -e "$VIEWER_SCRIPT" 2>/dev/null &
        else
            sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" x-terminal-emulator -- "$VIEWER_SCRIPT" 2>/dev/null &
        fi
    fi

    {
        for APP in "${SELECTED_APPS[@]}"; do
            PERCENT=$((CURRENT_APP * 100 / TOTAL_APPS))
            echo "XXX"
            echo "$PERCENT"
            echo "Przetwarzanie: $APP ($CURRENT_APP/$TOTAL_APPS)..."
            echo "XXX"

            echo -e "\n========================================\nSTART: $APP\n========================================" >> "$LOG_FILE"

            "install_$APP"
            CURRENT_APP=$((CURRENT_APP + 1))
        done

        echo "XXX"
        echo "100"
        echo "Zakończono instalację partii!"
        echo "XXX"
        sleep 1
        touch /tmp/install_done

    } | whiptail --title "Trwa instalacja" --gauge "Przygotowywanie środowiska..." 8 60 0

    whiptail --title "Partia zakończona!" --msgbox "Wybrane zadania zostały pomyślnie przetworzone.\nPowracam do menu głównego." 10 60

done
>>>>>>> d207a22cddc79fa716dc9c2871605ae089d4755f
