source "$HOME/.zsh/functions_and_aliases.sh"

# Tool init (skip silently if a tool isn't installed)
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v atuin    >/dev/null && eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

# zsh plugins (Arch package paths)
[[ -r /usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh
[[ -r /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
    source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# PATH
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# asdf-managed languages (Go, Node, etc.)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Go-installed binaries (paste-cb, gh-clone-org, etc.)
export PATH=$HOME/go/bin:$PATH

bindkey -e
bindkey '^e' edit_command

command -v fastfetch >/dev/null && fastfetch
