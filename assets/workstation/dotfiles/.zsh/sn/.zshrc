#!/bin/zsh

source ~/.zshrc

export CMDS_RUN=0
export single_cmd_shell_ignores=("\sls" "\scd" "\sfz" "\sfh")
function single_cmd_shell() {
  last_status=$?
  ignored=0
  for i in $single_cmd_shell_ignores; do
    last_cmd=$(history | tail -n1)
    if [[ $(echo $last_cmd | rg $i -c) -gt 0 ]]; then
      ignored=$((ignored+1))
    fi
  done


  # if [[ $last_status -lt 1 ]]; then
    if [[ $ignored -lt 1 ]]; then
      CMDS_RUN=$((CMDS_RUN+1))
    fi
    if [[ $CMDS_RUN -gt 1 ]]; then
      exit
    fi
  # fi
}

precmd_functions+=(single_cmd_shell)

