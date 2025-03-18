#!/bin/bash

folderpath=$(pwd)

tmuxinatorpath="$HOME/dotfiles/tmuxinator"

cp -r "$tmuxinatorpath" "$folderpath"

echo "Copied tmuxinator folder to $folderpath"

rm "$folderpath/tmuxinator/move_windows.sh"

ln -s "$tmuxinatorpath/tmuxinator/move_windows.sh" "$folderpath/tmuxinator/move_windows.sh"

rm "$folderpath/tmuxinator/start.sh"
