#!/bin/bash

# This removes a newline at end of file only if it is a new line
# https://stackoverflow.com/questions/28259288/removing-newline-at-end-of-file-using-bash-shell-script
#sed -i.bak '/^[[:blank:]]*$/{$d;}' $1

#echo -e "## ${2:-cap}.md\n" >> $1

nvim -c $ $1
