export ZSH="$HOME/.zsh"
setopt INC_APPEND_HISTORY

export PISTOL_CHROMA_STYLE=arduino
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000
export SAVEHIST=1000
setopt -o appendhistory
setopt appendhistory
setopt -o sharehistory

unalias -a
bindkey -e

# fzf settings
source ~/.zsh/fzf_settings.sh

# all my stuff
source "$HOME/.zsh/ytdl.sh"
source "$HOME/.zsh/zsh-vi-mode.plugin.zsh"
source "$HOME/.zsh/functions_and_aliases.sh"

# path and shims
source "$HOME/.zsh/path_and_shims.sh"

# shell hooks
source ~/.zsh/hooks.sh
source ~/.zsh/util.sh

# export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/yubikey-agent/yubikey-agent.sock"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

set_win_title(){
    mydir=$(pwd)
    base=$(basename $mydir)
    echo -ne "\033]0; $base \007"
}
precmd_functions+=(set_win_title)

pfetch

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/hoffs/.config/google-cloud-sdk/path.zsh.inc' ]; then . '/home/hoffs/.config/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/hoffs/.config/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/hoffs/.config/google-cloud-sdk/completion.zsh.inc'; fi
