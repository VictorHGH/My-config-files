#!/bin/bash

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
	link1="view"
	link2="tutorial"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
	link1="view"
	link2="tutorial"
else
    echo "Unsupported operating system"
    exit 1
fi

export link1
export link2
