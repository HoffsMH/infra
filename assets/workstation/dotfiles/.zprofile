export EDITOR="$HOME/bin/e"
export WAIT_EDITOR="/usr/bin/nvim"
export BROWSER="brave"
export READER="zathura"
export XDG_CONFIG_HOME="$HOME/.config"

export TERM="st-256color"
export TERMINAL="st-256color"

export QT_QPA_PLATFORMTHME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0

export GTK2_RC_FILES="/usr/share/themes/Gruvbox-Material-Dark/gtk-2.0/gtkrc"
export GTK_THEME="gruvbox-dark-gtk"

export SESSION=awesome

export HISTSIZE=40000
export SAVEHIST=40000
export SHARE_HISTORY=true

export HISTFILE="$HOME/.zsh_history"

setopt -o appendhistory
setopt appendhistory
setopt -o sharehistory


# path and shims
source "$HOME/.zsh/path_and_shims.sh"

sudo cpupower frequency-set -g powersave > /dev/null
sudo cpupower set -b 13 > /dev/null
# sudo cpupower frequency-set -u 3.2G

