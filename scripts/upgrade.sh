#!/usr/bin/env zsh

# Upgrade Oh My Zsh
zsh ~/.oh-my-zsh/tools/upgrade.sh
# Upgrade Home brew
echo "-----------------------"
echo "Upgrade Home brew"
echo "-----------------------"
brew upgrade `brew outdated` && brew cleanup && brew autoremove
# Upgrade the pip
# echo "-----------------------"
# echo "Upgrade the pip"
# echo "-----------------------"
# pip3 list --outdated --format json | python3 -m json.tool | grep '.*"name": "\S*"' | cut -d '"' -f4 | xargs -n1 pip3 install -U
# Upgrade the npm
echo "-----------------------"
echo "Upgrade npm"
echo "-----------------------"
npm -g upgrade
# ncu -g
# `ncu -g | grep "npm -g install .*"`
