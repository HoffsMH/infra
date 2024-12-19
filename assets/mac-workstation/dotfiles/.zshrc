
eval "$(/opt/homebrew/bin/brew shellenv)"

alias bbic="brew update &&\
    brew bundle install --cleanup --file=~/.config/Brewfile --no-lock &&\
    brew upgrade"

source "$HOME/.zsh/functions_and_aliases.sh"

eval "$(direnv hook zsh)"

eval "$(starship init zsh)"

eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

eval "$(zoxide init zsh)"

# source "$(fd autopair.zsh /run/current-system/sw -L)"

source "$HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

bindkey -e

bindkey '\ee' edit_command

export PATH=$HOME/bin:$PATH

export PATH=$HOME/.asdf/shims:$PATH
export PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH

pfetch


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/matt/.config/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/matt/.config/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/matt/.config/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/matt/.config/google-cloud-sdk/completion.zsh.inc'; fi
