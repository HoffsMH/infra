export PATH=""
export PATH=/bin:$PATH
export PATH=/sbin:$PATH
export PATH=/usr/sbin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH=/usr/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/alias:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/opt/fzf/bin:$PATH
export PATH=$HOME/.pyenv/bin:$PATH

# languages
export PATH=$ASDF_DATA_DIR/shims:$PATH

export PATH=/usr/local/go/bin:$PATH
# leaving these incase I one day need them again but for now
# asdf + go modules

# export GOPATH=$HOME/code/go
# export GOBIN=$HOME/code/go/bin
# export PATH=$GOBIN:$PATH

# rust env
export PATH="$HOME/.cargo/bin:$PATH"

# openssl on path
export PATH="/usr/local/opt/openssl/bin:$PATH"


# should end up with something like
# ie always prefer version management, and personal binaries over system

# /Users/<user>/.asdf/shims:
# /Users/<user>/bin:
# /usr/local/bin:
# /usr/bin:
# /usr/sbin:
# /sbin:
# /bin:
# :
# /usr/local/opt/fzf/bin
