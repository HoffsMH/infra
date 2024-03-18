
source "$HOME/.zsh/path_and_shims.sh"
source "$HOME/.zsh/functions_and_aliases.sh"

eval "$(zoxide init zsh)"

eval "$(direnv hook zsh)"

eval "$(starship init zsh)"

eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

pfetch
