#!/usr/bin/env bash

_ytdl_archive_dir="${XDG_STATE_HOME:-$HOME/.local/state}/yt-dlp"
_ytdl_video_dir="$HOME/personal/media/video/capture"
_ytdl_audio_dir="$HOME/personal/media/audio/capture"

_ytdl_url() {
  if [ "$#" -gt 0 ] && [ -n "${1:-}" ]; then
    printf '%s\n' "$1"
  else
    uclip 2>/dev/null || true
  fi
}

_ytdl_require() {
  command -v yt-dlp >/dev/null 2>&1 || {
    echo 'yt-dlp is required' >&2
    return 1
  }
}

ytdlv() {
  local yturl dir_name destination
  yturl=$(_ytdl_url "${1:-}")
  dir_name="${2:-}"
  [ -n "$yturl" ] || { echo 'Usage: ytdlv [url] [subdirectory]' >&2; return 1; }
  _ytdl_require || return

  destination="$_ytdl_video_dir"
  [ -n "$dir_name" ] && destination="$destination/$dir_name"
  mkdir -p "$destination" "$_ytdl_archive_dir"

  yt-dlp --add-metadata --continue \
    --sleep-interval 2 --max-sleep-interval 4 --no-warnings \
    --playlist-reverse --download-archive "$_ytdl_archive_dir/video" \
    -o "$destination/%(title)s-%(id)s.%(ext)s" "$yturl"
}

ytdla() {
  local yturl dir_name destination
  yturl=$(_ytdl_url "${1:-}")
  dir_name="${2:-}"
  [ -n "$yturl" ] || { echo 'Usage: ytdla [url] [subdirectory]' >&2; return 1; }
  _ytdl_require || return

  destination="$_ytdl_audio_dir"
  [ -n "$dir_name" ] && destination="$destination/$dir_name"
  mkdir -p "$destination" "$_ytdl_archive_dir"

  yt-dlp --add-metadata --extract-audio --continue \
    --sleep-interval 2 --max-sleep-interval 4 --no-warnings \
    --playlist-reverse --download-archive "$_ytdl_archive_dir/audio" \
    --audio-format mp3 --audio-quality 0 \
    -o "$destination/%(title)s-%(uploader)s-%(id)s.%(ext)s" "$yturl"
}
