#!/bin/bash

folderpath=$(pwd)

tmuxinatorpath="$HOME/dotfiles/tmuxinator"

cp -r "$tmuxinatorpath" "$folderpath"

echo "Copied tmuxinator folder to $folderpath"

ln -s "$tmuxinatorpath/tmuxinator/move_windows.sh" "$folderpath/move_windows.sh"

rm "$folderpath/tmuxinator/start.sh"
