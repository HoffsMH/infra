export ZSH="$HOME/.zsh"
setopt INC_APPEND_HISTORY

unalias -a
bindkey -e

# fzf settings
source ~/.zsh/fzf_settings.sh

# all my stuff
source "$HOME/.zsh/ytdl.sh"
source "$HOME/.zsh/functions_and_aliases.sh"

# path and shims
source "$HOME/.zsh/path_and_shims.sh"

# shell hooks
source ~/.zsh/hooks.sh
source ~/.zsh/util.sh

# export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/yubikey-agent/yubikey-agent.sock"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

pfetch

if {[ -n "$SINGLE_COMMAND_MODE" ]; } then
  source ~/.zsh/single_command_mode.zsh
fi

# if ! {[ -n "$TMUX" ]; } then
#   tmux new-session -A main
# fi


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/hoffs/.config/google-cloud-sdk/path.zsh.inc' ]; then . '/home/hoffs/.config/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/hoffs/.config/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/hoffs/.config/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

