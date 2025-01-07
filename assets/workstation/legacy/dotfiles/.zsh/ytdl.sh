#######################
# youtube-dl
######################

#!/bin/bash

# -x, --extract-audio              Convert video files to audio-only files
#                                (requires ffmpeg or avconv and ffprobe or
#                                avprobe)
# -c, --continue                   Force resume of partially downloaded files.
#                                  By default, youtube-dl will resume
#                                  downloads if possible.

# --sleep-interval SECONDS         Number of seconds to sleep before each
#                                  download when used alone or a lower bound
#                                  of a range for randomized sleep before each
#                                  download (minimum possible number of
#                                  seconds to sleep) when used along with
#                                  --max-sleep-interval.
# --max-sleep-interval SECONDS     Upper bound of a range for randomized sleep
#                                  before each download (maximum possible
#                                  number of seconds to sleep). Must only be
#                                  used along with --min-sleep-interval.

# --yes-playlist                   Download the playlist, if the URL refers to
#                                  a video and a playlist.
# the operative word here is IF, so leaving this in seems harmless for my purposes

# --no-warnings                    Ignore warnings
# I think this is to allow us to continue on playlist if there a software error with a parictular file

# -i, --ignore-errors              Continue on download errors, for example to
#                                  skip unavailable videos in a playlist

# --download-archive FILE          Download only videos not listed in the
#                                  archive file. Record the IDs of all
#                                  downloaded videos in it.

# If I always specificy the same archive I should be safe just spamming this command and being sure im not filling up HD un-necessarily

mkdir -p ~/.config/.yt-dl-archive
touch ~/.config/.yt-dl-archive/archive

ytdlv() {
    clipboard=$(/usr/bin/xclip -o || echo "")
    yturl=${1:-$clipboard}

    if [ -z "$2" ]
      then
        dir_name=""
      else
        dir_name="/$2"
    fi
    echo  downloading "$yturl" to "$dir_name"

    youtube-dl --add-metadata -c --sleep-interval 2 --max-sleep-interval 4 --no-warnings --playlist-reverse --download-archive ~/.config/.yt-dl-archive/video -o "~/personal/media/video/capture$dir_name/%(title)s-%(id)s.%(ext)s" $yturl
}

ytdla() {
    clipboard=$(/usr/bin/xclip -o || echo "")
    yturl=${1:-$clipboard}

    if [ -z "$2" ]
      then
        dir_name=""
      else
        dir_name="/$2"
    fi
    echo  downloading "$yturl" to "$dir_name"

    youtube-dl  --add-metadata -x  -ci --sleep-interval 2 --max-sleep-interval 4 --no-warnings --playlist-reverse --download-archive ~/.config/.yt-dl-archive/audio --audio-format 'mp3' --audio-quality 0 -o "~/personal/media/audio/capture$dir_name/%(title)s-%(uploader)s-%(id)s.%(ext)s" $yturl
}
