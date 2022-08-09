#! /bin/bash

set -e

echo "###############################################"
echo "ZSH UTIL"
echo "###############################################"

pushd "$HOME"

rm -rf .zsh-autopair
rm -rf .fast-syntax-highlighting

git clone https://github.com/hlissner/zsh-autopair .zsh-autopair || echo "zsh-auto-pair failed"
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting .fast-syntax-highlighting || echo "zsh-fast-syntax-highlighting failed"
