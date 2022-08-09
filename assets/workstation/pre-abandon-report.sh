#!/bin/bash

echo " "
echo "~/personal/media/video/capture"
exa -la ~/personal/media/video/capture

echo ""
echo "~/personal/media/audio/capture"
exa -la ~/personal/media/audio/capture

echo ""
echo "~/personal/media/image/capture"
exa -la ~/personal/media/image/capture

echo " "
echo "installed without dotfiles:"
cat ~/.installed


echo ""
gfold $HOME
