#!/bin/bash

swww init &

swww img ~/.wall.jpg

theme="Nordzy-cursors"
size=24

hyprctl setcursor $theme $size
gsettings set org.gnome.desktop.interface cursor-theme $theme
gsettings set org.gnome.desktop.interface cursor-size $size
