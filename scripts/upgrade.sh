#!/usr/bin/env zsh

function print_help() {
	echo "-----------------------"
	echo "Upgrade $1"
	echo "-----------------------"
}

function upgrade() {
	# Upgrade Oh My Zsh
	print_help "Oh My Zsh"
	zsh ~/.oh-my-zsh/tools/upgrade.sh

	# Upgrade Home brew
	print_help "Home brew"
	brew upgrade `brew outdated` && brew cleanup && brew autoremove

	# Upgrade the npm
	print_help "npm"
	npm -g update && npm -g upgrade

	# Upgrade the Nvim
	print_help "Nvim"
	nvim . -c UpgradeNvim

	# Finish
	print_help "Finished"
}

function upgrade_linux() {
	# Upgrade pacman
	print_help "pacman"
	sudo pacman -Syu --noconfirm
	sudo pacman -Qqe > ~/dotfiles/resources/pacman/packages.txt
	brew bundle dump --file ~/dotfiles/resources/homebrew/Brewfile-linux --force
	print_help "Brewfile-linux created"
}

function upgrade_mac() {
	brew bundle dump --file ~/dotfiles/resources/homebrew/Brewfile --force
	print_help "Brewfile created"
}

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
	upgrade	
	upgrade_mac
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
	upgrade
	upgrade_linux
else
    echo "Unsupported operating system"
    exit 1
fi
