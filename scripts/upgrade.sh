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
npm -g update && npm -g upgrade

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "-----------------------"
	echo "Upgrade finished"
	echo "-----------------------"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Upgrade pacman
	echo "-----------------------"
	echo "Upgrade pacman"
	echo "-----------------------"
	sudo pacman -Syu --noconfirm
    echo "-----------------------"
	echo "Upgrade finished"
	echo "-----------------------"
else
    echo "Unsupported operating system"
    exit 1
fi
