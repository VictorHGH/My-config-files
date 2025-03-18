#!/usr/bin/env zsh

if [ -z "$1" ]
then
	echo "Please provide a course name"
	exit 1
fi

# use case for diferent courses
case $1 in
	develoteca_poo)
		echo "Starting Develoteca course"
		tmuxinator start develoteca_poo
	;;
esac
