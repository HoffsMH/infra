# ######################################################
# # zsh
# ######################################################
#
alias zource="source ~/.zshrc"

# ######################################################
# # files/directory work
# ######################################################
#
# # lsing on my music directory was getting annoying with the default color
# export EXA_COLORS="*.mp3=34"
#
alias e="nvim"
# #fancy ls command
alias l="exa -laGghHMS  --git --icons -T -L 1"
alias cat="bat --theme gruvbox-dark"
alias dig="dog"
# alias http="xh"
alias yotpc="ykman oath accounts code"
alias yotpl="ykman oath accounts list"
#
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

# alias pass="gopass"

# ######################################################
# # git
# ######################################################
#
# alias lzg="lazygit"
# # fuzzy finder for checking out git branchs
#
gcof() {
    git checkout "$(gbf)"
}

gbf() {
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
    echo "$target" | awk '{print $2}'
}
#
# gcofw() {
#     local tags branches target
#     tags=$(
#         git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
#     branches=$(
#         git branch --all | grep -v HEAD             |
#             sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
#             sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
#     target=$(
#         (echo "$tags"; echo "$branches") |
#             fzf --no-hscroll --ansi +m -d "\t" -n 2 --preview-window=hidden
#           ) || return
#     git worktree add $(echo "$target" | awk '{print $2}')
# }
#
#
alias g="git"
alias gb="git branch"
alias gco="git checkout"
alias gf="git fetch"
#
gdn() {
 git diff "HEAD~$1" "HEAD" $2 $3 $4
}
#
# # finds text across all commits, be careful when searching to not use common terms
# # useful for searching for code that you knew existed at one point
gsearch() { git log -S$1 -p }
#
gpoc() { git pull origin $(g.bn) --rebase }
#
alias gd="git diff"
#
# # see diff from n commits ago
#
alias ga="git add"
alias gs="git status"
alias gr="git reset"
alias gcm="git commit -m "
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
#
# # I don't trust git stash so sometimes store incomplete work on top of the branch
# # in a commit that is always called 'reset me'
alias greset="git add . && git commit -m 'reset me'"
# # undoes the previous alias
alias gr1="git reset HEAD~1"
#
# # pretty git log
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
#
# # diffs your version of the current branch vs the internet's version
# # useful with difi to see updated branch on origin
# # $ gdo | difi
# gdo() {
#     local branchname
#     branchname=$(git.branch-name)
#     git diff "$branchname" "origin/$branchname" $1
# }
#
# ######################################################
# # docker
# ######################################################
# stops containers
alias dockerstopc='docker stop $(docker ps -aq)'
# cleans containers
alias dockercleanc='docker rm $(docker ps -aq)'
# cleans volumes
alias dockercleanv='docker volume rm $(docker volume ls --filter dangling=true -q)'
# cleans images
alias dockercleani='docker rmi -f $(docker images -q -a)'

alias dockernuke='dockerstopc || dockercleanc || dockercleani || dockercleanv'
# start the docker daemon
alias dockerstartdaemon='sudo systemctl start docker.service'
# stop the docker daemon
alias dockerstopdaemon='sudo systemctl stop docker.service'
#
# ######################################################
# # language specific
# ######################################################
#
# # JS/Ember
alias ya='yarn'

alias udm="udisksctl mount -b"
alias udum="udisksctl unmount -b"
#
# ######################################################
# # PASS
# ######################################################
#
alias passedit='pass edit -c -e nvim'
#
fh() {
  output=$(atuin search $* -i 3>&1 1>&2 2>&3)
  print -z "$output"
}
#
alias df="dust"
alias du="duf"

function edit_command {
    local temp_file=$(mktemp)
    echo "$BUFFER" > "$temp_file"
    nvim "$temp_file"
    BUFFER=$(<"$temp_file")
    rm "$temp_file"
    zle reset-prompt
}

zle -N edit_command
