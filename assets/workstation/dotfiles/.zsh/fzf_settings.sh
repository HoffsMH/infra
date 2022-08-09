# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
    export PATH="$PATH:/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

export FZF_DEFAULT_OPTS='
--border
--bind "ctrl-y:execute-silent(echo {} | xclip)+abort"
--preview "(pistol {}) 2> /dev/null | head -500"
'

export FZF_DEFAULT_COMMAND='fd --type file'

export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_CTRL_T_OPTS=$FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS="--height 40% --reverse --no-preview "
