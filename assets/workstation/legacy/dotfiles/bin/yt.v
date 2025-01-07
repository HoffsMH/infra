#!/bin/bash

clip=$(xpaste || echo "")
url=${1:-$clip}

echo "ytdlv \"$url\"" >> ~/bin/ytgo
echo "ytdlv $url"
notify-send "VIDEO queued: $url"
