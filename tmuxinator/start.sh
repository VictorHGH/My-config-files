#!/bin/bash

folderpath=$(pwd)

touch ./.gitignore

tmuxinatorpath="$HOME/dotfiles/tmuxinator"

cp -r "$tmuxinatorpath" "$folderpath"

echo "Copied tmuxinator folder to $folderpath"

rm "$folderpath/tmuxinator/start.sh"
