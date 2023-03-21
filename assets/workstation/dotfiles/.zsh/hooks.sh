# https://github.com/direnv/direnv
eval "$(direnv hook zsh)"

. $HOME/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# zoxide options
export _ZO_FZF_OPTS="--algo=v2 --no-exact --layout=reverse"

# unset z
unalias z

#python build env stuff
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
export KEEP_BUILD_PATH=true

