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
# 1. DEFINICJE INSTALACJI
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

install_Link_Bash_Alias() {
    if [ -n "$SUDO_USER" ]; then
        # Dynamiczne wykrycie głównego folderu dotfiles (katalog wyżej niż scripts/)
        local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
        
        local SRC="$DOTFILES_DIR/.bash_alias"
        local TGT="/home/$SUDO_USER/.bash_alias"
        
        if [ -f "$SRC" ]; then
            rm -f "$TGT" # Usuwamy stary plik/link jeśli istniał
            ln -sf "$SRC" "$TGT"
            chown $SUDO_USER:$SUDO_USER "$TGT"
            echo "Pomyślnie utworzono dowiązanie dla .bash_alias" >> "$LOG_FILE" 2>&1
        else
            echo "BŁĄD: Plik źródłowy $SRC nie istnieje w repozytorium dotfiles!" >> "$LOG_FILE" 2>&1
            return 1
        fi
    fi
}

# --- SEKCJA: PROGRAMY ---
install_7zip() {
    apt-get install -y 7zip >> "$LOG_FILE" 2>&1
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
install_JDownloader(){
    # Nowa instalacja z Flathuba
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
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
# 3. INTERAKTYWNE MENU Z KATEGORIAMI
# ==============================================================================
MENU_OPTIONS=()

# Kategoria: Konfiguracja wstępna
MENU_OPTIONS+=("[--KONFIGURACJA--]" "================================" OFF)
MENU_OPTIONS+=("Setup_Flatpak"      "$(check_standard flatpak)" OFF)
MENU_OPTIONS+=("Setup_Snap"         "$(check_standard snap)" OFF)
MENU_OPTIONS+=("Link_Bash_Alias"    "$(check_symlink /home/$SUDO_USER/.bash_alias)" OFF)

# Kategoria: Internet i Przeglądarki
MENU_OPTIONS+=("[--PRZEGLĄDARKI--]" "================================" OFF)
MENU_OPTIONS+=("Google_Chrome"      "$(check_standard google-chrome)" OFF)

# Kategoria: Multimedia i Grafika
MENU_OPTIONS+=("[--MULTIMEDIA--]"   "================================" OFF)
MENU_OPTIONS+=("VLC"                "$(check_standard vlc)" OFF)
MENU_OPTIONS+=("Gimp"               "$(check_standard gimp)" OFF)
MENU_OPTIONS+=("yt-dlp"             "$(check_standard yt-dlp)" OFF)

# Kategoria: Biuro i Narzędzia
MENU_OPTIONS+=("[--NARZĘDZIA--]"    "================================" OFF)
MENU_OPTIONS+=("7zip"               "$(check_standard 7z)" OFF)
MENU_OPTIONS+=("Calibre"            "$(check_standard calibre)" OFF)
MENU_OPTIONS+=("OnlyOffice"         "$(check_standard onlyoffice-desktopeditors)" OFF)
MENU_OPTIONS+=("JDownloader"        "$(check_flatpak org.jdownloader.JDownloader)" OFF)

# Kategoria: Rozrywka i Gry
MENU_OPTIONS+=("[--GRY--]"          "================================" OFF)
MENU_OPTIONS+=("Steam"              "$(check_standard steam)" OFF)
MENU_OPTIONS+=("Heroic"             "$(check_standard heroic)" OFF)

CHOICES=$(whiptail --title "Automatyczny Instalator Programów" --checklist \
"Wybierz programy (Spacja - zaznacz, Nagłówek zaznacza całą grupę, Enter - zatwierdź):" 24 78 16 \
"${MENU_OPTIONS[@]}" \
3>&1 1>&2 2>&3)

CHOICES=$(echo "$CHOICES" | tr -d '"' | xargs)

if [ -z "$CHOICES" ]; then
  echo "Anulowano instalację lub nic nie wybrano."
  exit 0
fi

read -r -a RAW_APPS <<< "$CHOICES"

# Rozwijanie nagłówków kategorii na pełne listy programów
ALL_SELECTED=()
for APP in "${RAW_APPS[@]}"; do
    case "$APP" in
        "[--KONFIGURACJA--]")
            ALL_SELECTED+=("Setup_Flatpak" "Setup_Snap" "Link_Bash_Alias")
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
        *)
            if [[ "$APP" != \[* ]]; then
                ALL_SELECTED+=("$APP")
            fi
            ;;
    esac
done

# Usuwanie duplikatów z zachowaniem kolejności
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
    echo "Nie wybrano żadnych programów do instalacji. Zakończono."
    exit 0
fi

CURRENT_APP=0

# ==============================================================================
# 4. WYKONYWANIE, PODGLĄD LOGÓW NA ŻYWO I PASEK POSTĘPU
# ==============================================================================
VIEWER_SCRIPT="/tmp/pobieraj_logi.sh"
cat << 'EOF' > "$VIEWER_SCRIPT"
#!/bin/bash
echo "=== PODGLĄD INSTALACJI NA ŻYWO ==="
echo "----------------------------------"
tail -f /tmp/instalacja_programow.log
EOF
chmod +x "$VIEWER_SCRIPT"
chown $SUDO_USER:$SUDO_USER "$VIEWER_SCRIPT"

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
    TERM_PID=$!
fi

{
    for APP in "${SELECTED_APPS[@]}"; do
        PERCENT=$((CURRENT_APP * 100 / TOTAL_APPS))
        echo "XXX"
        echo "$PERCENT"
        echo "Instalowanie/Konfiguracja: $APP ($CURRENT_APP/$TOTAL_APPS)..."
        echo "XXX"

        echo -e "\n========================================\nSTART: $APP\n========================================" >> "$LOG_FILE"

        "install_$APP"
        CURRENT_APP=$((CURRENT_APP + 1))
    done

    echo "XXX"
    echo "100"
    echo "Zakończono pobieranie i instalację!"
    echo "XXX"
    sleep 2

} | whiptail --title "Trwa instalacja" --gauge "Przygotowywanie środowiska..." 8 60 0

whiptail --title "Gotowe!" --msgbox "Wszystkie wybrane zadania zostały zakończone.\nPełny raport znajdziesz w: $LOG_FILE" 10 60
clear
echo "Zrobione! Środowisko gotowe do pracy."