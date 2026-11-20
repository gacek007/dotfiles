alias ytdlpinstall='sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp && sudo apt install -y ffmpeg'
alias ytdlpmp3='yt-dlp -f "bestaudio/best" -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" -ciw'
alias ytdlpgood='yt-dlp -f "bestvideo[ext=mp4][vcodec!^=av0][vcodec!^=av1]+bestaudio[ext=m4a]/mp4/best" -ciw'
alias ytdlpbest='yt-dlp -f "bv+ba/b" --merge-output-format mp4'
alias 7zip='7z x'
alias dell='ssh root@192.168.100.55'
alias unrar='unrar x'
alias comfy='cd /home/$USER/Programy/ComfyUI && source venv/bin/activate && python3 main.py'
alias comfy_update='cd /home/$USER/Programy/ComfyUI && source venv/bin/activate && git pull && pip install -r requirements.txt --upgrade'
alias zapis='watch "grep -e Dirty: -e Writeback: /proc/meminfo"'
git_push() {
    # default 'update'
    local msg="${1:-Update}"
    git add . && git commit -m "$msg" && git push origin main
}
