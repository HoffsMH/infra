eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

fh () {
        output=$(atuin search $* -i 3>&1 1>&2 2>&3)
        print -z "$output"
}

PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '
