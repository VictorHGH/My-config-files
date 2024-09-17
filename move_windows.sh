#!/bin/bash

link1="path-to-location"
link2="path-to-location"

# Function to move window to second monitor for Linux
move_to_second_monitor_linux() {
	# Abriendo chromium
	chromium --new-window $link1

	# Moviendo al segundo monitor
	chromium --new-window $link2

	# Movemos el cursor al segundo monitor
	xdotool key super+2 
}

# Function to move window to second monitor for macOS
move_to_second_monitor_mac() {
  open -a "Safari" $link1
  open -a "Google Chrome" $link2

  # Get the window ID of the Chrome window
  chrome_window_id=$(osascript -e 'tell application "Google Chrome" to id of window 1')
  safari_window_id=$(osascript -e 'tell application "Safari" to id of window 1')

  # Set the new window size (width x height)
  chrome_new_width=3840
  chrome_new_height=1080

  safari_new_width=1920
  safari_new_height=1080

  # Move the window to the second monitor
  # This specifies the bounds of the window as a rectangle. The format is {left, top, right, bottom}. In this case, 
  # the left and top coordinates are set to 1920 and 0, respectively, indicating the position of the top-left corner 
  # of the window on the screen. The right and bottom coordinates are calculated based on the width and height of the 
  # window ($chrome_new_width and $chrome_new_height variables).
  osascript -e "tell application \"Google Chrome\" to set bounds of window id $chrome_window_id to {1920, 0, $chrome_new_width, $chrome_new_height}"
  osascript -e "tell application \"Safari\" to set bounds of window id $safari_window_id to {960, 0, $safari_new_width, $safari_new_height}"
}

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    move_to_second_monitor_mac
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    move_to_second_monitor_linux
else
    echo "Unsupported operating system"
    exit 1
fi

