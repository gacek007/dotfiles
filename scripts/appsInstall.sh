#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Proszę uruchomić skrypt z uprawnieniami root (np. sudo ./install.sh)"
  exit
fi

LOG_FILE="/tmp/instalacja_programow.log"
# Tworzymy pusty plik logów i dajemy do niego dostęp wszystkim, 
# aby zwykły użytkownik w nowym oknie mógł go bez problemu czytać
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"
> "$LOG_FILE"

# ==============================================================================
# 1. DEFINICJE INSTALACJI
# ==============================================================================
install_7zip() {
    sudo apt install 7zip >> "$LOG_FILE" 2>&1
}
install_Calibre() {
    apt install -y libopengl0 libxcb-cursor0 >> "$LOG_FILE" 2>&1
    wget -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin >> "$LOG_FILE" 2>&1
}
install_Gimp() {
    apt-get install -y gimp >> "$LOG_FILE" 2>&1
}
install_Google_Chrome() {
    wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >> "$LOG_FILE" 2>&1
    apt install -y /tmp/google-chrome-stable_current_amd64.deb >> "$LOG_FILE" 2>&1
}
install_Heroic(){
    apt install -y curl
    URL=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | grep "browser_download_url" | grep "amd64.deb" | sed -E 's/.*"([^"]+)".*/\1/') && curl -L -o /tmp/heroic.deb "$URL" >> "$LOG_FILE" 2>&1
    apt install -y /tmp/heroic.deb >> "$LOG_FILE" 2>&1
}
install_JDownloader(){
    sh ./JDownloader2Setup.sh >> "$LOG_FILE" 2>&1
}
install_OnlyOffice(){
    wget -O /tmp/onlyoffice.deb https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb >> "$LOG_FILE" 2>&1
    DEBIAN_FRONTEND=noninteractive apt install -y /tmp/onlyoffice.deb >> "$LOG_FILE" 2>&1
}
install_Steam() {
    wget -O /tmp/steam.deb https://cdn.fastly.steamstatic.com/client/installer/steam.deb >> "$LOG_FILE" 2>&1
    apt install -y /tmp/steam.deb >> "$LOG_FILE" 2>&1
    #sudo -u "$SUDO_USER" steam >> "$LOG_FILE" 2>&1
}
install_VLC() {
    apt-get install -y vlc >> "$LOG_FILE" 2>&1
}
install_yt-dlp(){
    apt install ffmpeg -y
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp >> "$LOG_FILE" 2>&1
    chmod a+rx /usr/local/bin/yt-dlp >> "$LOG_FILE" 2>&1
}

# ==============================================================================
# 2. FUNKCJE SPRAWDZAJĄCE
# ==============================================================================

check_standard() {
    local cmd_name=$1
    if command -v "$cmd_name" >/dev/null 2>&1; then echo " (Zainstalowano)"; else echo ""; fi
}

check_flatpak() {
    local app_id=$1
    if command -v flatpak >/dev/null 2>&1 && flatpak list --app | grep -q "$app_id"; then echo " (Zainstalowano)"; else echo ""; fi
}

check_jdownloader() {
    # Sprawdzamy obecność folderu w /opt lub w katalogu domowym użytkownika
    if [ -d "/opt/jd2" ]; then
        echo " (Zainstalowano)"
    fi
}

# ==============================================================================
# 3. INTERAKTYWNE MENU
# ==============================================================================

MENU_OPTIONS=()
#MENU_OPTIONS+=("JDownloader" "Menadżer pobierania$(check_flatpak org.jdownloader.JDownloader)" OFF)
MENU_OPTIONS+=("7Zip"           "Obsługa archiwum           $(check_standard 7z)" OFF)
MENU_OPTIONS+=("Calibre"        "Edytor ebookow             $(check_standard calibre)" OFF)
MENU_OPTIONS+=("Gimp"           "Edytor obrazow             $(check_standard gimp)" OFF)
MENU_OPTIONS+=("Google_Chrome"  "Przeglądarka internetowa   $(check_standard google-chrome)" OFF)
MENU_OPTIONS+=("JDownloader"    "Pobieranie wideo           $(check_standard google-chrome)" OFF)
MENU_OPTIONS+=("Heroic"         "Launcher gier              $(check_standard heroic)" OFF)
MENU_OPTIONS+=("OnlyOffice"     "Pakiet office              $(check_standard only-office-desktopeditors)" OFF)
MENU_OPTIONS+=("Steam"          "Launcher gier              $(check_standard steam)" OFF)
MENU_OPTIONS+=("VLC"            "Video player               $(check_standard vlc)" OFF)
MENU_OPTIONS+=("yt-dlp"         "Pobieranie video/mp3 z yt  $(check_standard yt-dlp)" OFF)

CHOICES=$(whiptail --title "Automatyczny Instalator Programów" --checklist \
"Wybierz programy do zainstalowania (Spacja - zaznacz/odznacz, Enter - zatwierdź):" 20 78 12 \
"${MENU_OPTIONS[@]}" \
3>&1 1>&2 2>&3)

if [ -z "$CHOICES" ]; then
  echo "Anulowano instalację."
  exit 0
fi

CHOICES=$(echo "$CHOICES" | tr -d '"')
read -r -a SELECTED_APPS <<< "$CHOICES"

TOTAL_APPS=${#SELECTED_APPS[@]}
CURRENT_APP=0

# ==============================================================================
# 4. WYKONYWANIE, PODGLĄD LOGÓW NA ŻYWO I PASEK POSTĘPU
# ==============================================================================

# Tworzymy tymczasowy skrypt podglądu
VIEWER_SCRIPT="/tmp/pobieraj_logi.sh"
cat << 'EOF' > "$VIEWER_SCRIPT"
#!/bin/bash
echo "=== PODGLĄD INSTALACJI NA ŻYWO ==="
echo "----------------------------------"
tail -f /tmp/instalacja_programow.log
EOF
chmod +x "$VIEWER_SCRIPT"
chown $SUDO_USER:$SUDO_USER "$VIEWER_SCRIPT"

# Detekcja i uniwersalne odpalenie terminala zależnie od dystrybucji
if [ -n "$SUDO_USER" ]; then
    # Pobieramy numeryczny UID użytkownika, który wpisał sudo
    USER_UID=$(id -u "$SUDO_USER")
    
    # Rekonstrukcja PEŁNEGO środowiska graficznego użytkownika
    export DISPLAY="${DISPLAY:-:0}"
    export XAUTHORITY="/home/$SUDO_USER/.Xauthority"
    export XDG_RUNTIME_DIR="/run/user/$USER_UID"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus"

    if command -v gnome-terminal >/dev/null 2>&1; then
        # Klasyczny terminal Ubuntu/Pop!_OS
        sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        gnome-terminal -- "$VIEWER_SCRIPT" 2>/dev/null &
    elif command -v kgx >/dev/null 2>&1; then
        # Nowy, uparty terminal w Ubuntu (Gnome Console) - teraz ze skrajnie precyzyjnym środowiskiem
        sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        kgx run "$VIEWER_SCRIPT" 2>/dev/null &
    elif command -v io.elementary.terminal >/dev/null 2>&1; then
        # Dedykowany terminal dla elementary OS
        sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        io.elementary.terminal -e "$VIEWER_SCRIPT" 2>/dev/null &
    else
        # Opcja rezerwowa
        sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        x-terminal-emulator -- "$VIEWER_SCRIPT" 2>/dev/null &
    fi
    TERM_PID=$!
fi

{
    for APP in "${SELECTED_APPS[@]}"; do
        PERCENT=$((CURRENT_APP * 100 / TOTAL_APPS))
        echo "XXX"
        echo "$PERCENT"
        echo "Instalowanie: $APP ($CURRENT_APP/$TOTAL_APPS)..."
        echo "XXX"

        echo -e "\n========================================\nSTART INSTALACJI: $APP\n========================================" >> "$LOG_FILE"

        "install_$APP"
        CURRENT_APP=$((CURRENT_APP + 1))
    done

    echo "XXX"
    echo "100"
    echo "Zakończono pobieranie i instalację!"
    echo "XXX"
    sleep 2

} | whiptail --title "Trwa instalacja" --gauge "Przygotowywanie środowiska..." 8 60 0

# Opcjonalnie: zamykamy okno z logami po zakończeniu wszystkiego
#if [ -n "$TERM_PID" ]; then
#    kill "$TERM_PID" 2>/dev/null
#fi
#test
whiptail --title "Gotowe!" --msgbox "Wszystkie wybrane programy zostały zainstalowane.\nPełny raport znajdziesz w: $LOG_FILE" 10 60
clear
echo "Zrobione! Środowisko gotowe do pracy."




