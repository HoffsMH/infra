######################################################
# manjaro
######################################################

alias mirrors-f="sudo pacman-mirrors -f"
alias update-f="sudo pacman -Syyu --overwrite '*'"
alias keyring-f="sudo pacman -S manjaro-keyring"

# sudo pacman-key --init
# sudo pacman-key --populate manjaro archlinux

######################################################
# zsh
######################################################

alias zource="source ~/.zshrc"
alias vim="nvim"

######################################################
# files/directory work
######################################################

# lsing on my music directory was getting annoying with the default color
export EXA_COLORS="*.mp3=34"

#fancy ls command
alias l="exa -laFGgh --icons -T -L 1"
alias ls="exa -Fla --icons -T -L 1"

# alias l="ls -laFGgohq"
# alias ls='ls -Fa'
# alias lg='l | grep -i'

alias tree="tree -L 3"

# makes a generic tar.gz file for the given folder
tarmake () {
    tar -cvzf "$1.tar.gz" "$1"
}

# found this thing on SO it supposed to extract most things
untar(){
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "Unable to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

alias pass="gopass"
alias bc="bc -l"

######################################################
# git
######################################################

alias lzg="lazygit"
# fuzzy finder for checking out git branchs
gcof() {
    local tags branches target
    tags=$(
        git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    branches=$(
        git branch --all | grep -v HEAD             |
            sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
            sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    target=$(
        (echo "$tags"; echo "$branches") |
            fzf --no-hscroll --ansi +m -d "\t" -n 2 --preview-window=hidden
          ) || return
    git checkout $(echo "$target" | awk '{print $2}')
}
alias ytf="ytfzf -t"

alias g="git"
alias gb="git branch"
alias gco="git checkout"

# get branch name
alias gbn="git rev-parse --abbrev-ref HEAD"

alias gcf="git clean -f -d"

# finds text across all commits, be careful when searching to not use common terms
# useful for searching for code that you knew existed at one point
gsearch() { git log -S$1 -p }

gpoc() { git pull origin $(gbn) --rebase }

alias gcopybranchname="gbn | tr -d '\r\n' |tee /dev/stderr | xclip"
# if working in a repository where the convention is to name prs after branches
alias gcopyprname="gbn | sed -e 's/-/ /g' | tr -d '\r\n' |tee /dev/stderr | xclip"

alias gpu="git push origin"
alias gd="git diff"

# see diff from n commits ago
gdn() {
 git diff "HEAD~$1"
}

alias ga="git add"
alias gs="git status"
alias gr="git reset"
alias gf="git fetch"
alias gcm="git commit -m "
alias gc="git commit"
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
alias gm='git merge'

# I don't trust git stash so sometimes store incomplete work on top of the branch
# in a commit that is always called 'reset me'
alias greset="git add . && git commit -m 'reset me'"
# undoes the previous alias
alias gr1="git reset HEAD~1"

# pretty git log
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# diffs your version of the current branch vs the internet's version
# useful with difi to see updated branch on origin
# $ gdo | difi
gdo() {
    local branchname
    branchname=$(gbn)
    git diff "$branchname" "origin/$branchname" $1
}

######################################################
# docker
######################################################
# stops containers
alias dockerstopc='docker stop $(docker ps -aq)'
# cleans containers
alias dockercleanc='docker rm $(docker ps -aq)'
# cleans volumes
alias dockercleanv='docker volume rm $(docker volume ls --filter dangling=true -q)'
# cleans images
alias dockercleani='docker rmi -f $(docker images -q -a)'

alias dockernuke='dockerstopc || dockercleanc || dockercleani || dockercleanv'

######################################################
# language specific
######################################################
alias pyenvinstall="CPPFLAGS='-I/usr/local/opt/zlib/include' pyenv install -v"

# JS/Ember
alias ya='yarn'

# elixir
alias miex="iex -S mix"
alias miet="iex -S mix test"
alias tmiex="MIX_ENV=test iex -S mix"
alias ctmiex="MIX_ENV=test mix compile --force && tmiex"
alias mphx="iex -S mix phx.server"
alias mt="mix test"

# ruby
alias be="bundle exec"

# golang
alias gob="go build"
alias got="go test -v"

export ytgo_template_location="$HOME/personal/dotfiles/samples/bin/ytgo"
export ytgo_location="$HOME/bin/ytgo"

alias ytreport='cat $ytgo_location'
alias eyt='$EDITOR ~/bin/ytgo'
alias pacman-refresh='sudo pacman-mirrors -f && sudo pacman -Syyu'

######################################################
# clipboard
######################################################

# cptext bash script for copying text arguments
alias xclip="/usr/bin/xclip -selection clipboard"

######################################################
# history
######################################################

fh() {
    print -z $(fho)
}

######################################################
# which
######################################################

fb() {
    print -z $(fbo)
}


######################################################
# disks
######################################################

alias rm='echo "This is not the command you are looking for."; false'
alias trm='tl rm'

######################################################
# files
######################################################

alias open="xdg-open"
alias jfc='jf ~/personal/00-capture'
alias jfa='jf ~/personal/media/audio'
alias jfi='jf ~/personal/media/image'
alias jfs='jf ~/personal/media/software'
alias jft='jf ~/personal/media/text'
alias jfv='jf ~/personal/media/video'

# open this file
alias oalias="$EDITOR ~/.zsh/functions_and_aliases.sh"

######################################################
# docker
######################################################
# start the docker daemon
alias dockerstartdaemon='sudo systemctl stop docker.service'

# docker
# stop the docker daemon
alias dockerstopdaemon='sudo systemctl start docker.service'

alias task='taskell "$HOME/personal/00-capture/board/taskell.md"'

######################################################
# Text Editing
######################################################
alias subl='\rm -rf ~/.config/sublime-text/Local/Auto\ Save\ Session.sublime_session && /usr/bin/subl'

######################################################
# getting random text for passwords and secrets
######################################################

random_key() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

######################################################
# Displays/wallpaper and keyboard
######################################################

setdmonpicale() {
  xrandr --output $1 --scale $2
}

setdp1cale() {
  setdmonpicale "DisplayPort-1" $1
}

sethdmiscale() {
  setdmonpicale "HDMI-0" $1
}

alias kbdxcape="xcape -t 200 -e Control_L=Escape"

######################################################
# WM and session
######################################################

alias xfcesesh="export SESSION=xfce4-session && startx"
alias dwmsesh="export SESSION=dwm && startx"
alias awesomesesh="export SESSION=awesome && startx"

######################################################
# bw
######################################################

bwunlock() {
  export BW_SESSION=$(bw unlock --raw)
}

gpgstart() {
  gpgconf --launch gpg-agent
}

alias gpg-reload-card='gpg-connect-agent "scd serialno" "learn --force" /bye'
alias gpg-import-my-key='curl mhkr.io/key.pub | gpg --import'

alias addoath="ykman oath add -t $1 $(xclip -o)"

######################################################
# network sleuthing
######################################################

alias nmapo="sudo nmap -O -v"

######################################################
# Restic and backup stuff
######################################################

# specify your repo with env variable or -r
alias resticbrowse="restic mount /media/restic"

alias udmount="udisksctl mount -b"
alias udunmount="udisksctl unmount -b"

######################################################
# PASS
######################################################

alias passedit='pass edit -e "$WAIT_EDITOR"'

