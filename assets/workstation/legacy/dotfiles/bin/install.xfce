#!/bin/zsh


#! /bin/bash
set -e

echo "###############################################"
echo "XFCE"
echo "###############################################"

installs=(
  "xfce4" # 
  "xfce4-goodies" # 
  "manjaro-xfce-minimal-settings" #
)

echo $installs
for i in $installs
do
  echo "###############################################"
  echo "INSTALLING $i"
  echo "###############################################"
  if yay -S --noconfirm $i ; then
    echo "###############################################"
    echo "SUCCEEDED $i"
    echo "###############################################"
  else
    echo "###############################################"
    echo "FAILED $i"
    echo "###############################################"
    echo "- $i\n" >> failures.md
  fi
done
