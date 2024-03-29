#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

 get_session(){
   local dbus_args=(--sh-syntax --exit-with-session)
   case "$SESSION" in
     awesome) dbus_args+=(awesome) ;;
     bspwm) dbus_args+=(bspwm-session) ;;
     budgie) dbus_args+=(budgie-desktop) ;;
     cinnamon) dbus_args+=(cinnamon-session) ;;
     deepin) dbus_args+=(startdde) ;;
     enlightenment) dbus_args+=(enlightenment_start) ;;
     fluxbox) dbus_args+=(startfluxbox) ;;
     gnome) dbus_args+=(gnome-session) ;;
     i3|i3wm) dbus_args+=(i3 --shmlog-size 0) ;;
     jwm) dbus_args+=(jwm) ;;
     kde) dbus_args+=(startkde) ;;
     lxde) dbus_args+=(startlxde) ;;
     lxqt) dbus_args+=(lxqt-session) ;;
     mate) dbus_args+=(mate-session) ;;
     xfce) dbus_args+=(xfce4-session) ;;
     openbox) dbus_args+=(openbox-session) ;;
     *) dbus_args+=("$SESSION") ;;
   esac

   exec dbus_args
 }

source "$HOME/.envrc"
# -c shadow effects
# -b run in background
# picom -c --experimental-backends --backend glx -b --no-fading-openclose

dunst &

set.wall
set.kbd
autorandr -c
/usr/bin/xset r "rate" "200" "30"
/usr/bin/sxhkd &

# start gnome keyring so I dont have to type password on every git push
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK


$HOME/.screenlayout/main.sh &

exec $SESSION > $HOME/.window-manager.log 2>&1

