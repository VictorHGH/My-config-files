#!/bin/bash

open -a "Google Chrome" --args --new-window "https://www.google.com"
open -a "Safari" --args --new-window "https://www.google.com"
open -a "Terminal"

# Function to move window to second monitor for Linux
move_to_second_monitor_linux() {
    # Get the window IDs of the Chrome, Safari, and Terminal windows
    chrome_window_id=$(xdotool search --onlyvisible --class "google-chrome")
    safari_window_id=$(xdotool search --onlyvisible --class "Safari")
    terminal_window_id=$(xdotool search --onlyvisible --class "Terminal")

    # Set the new window size (width x height)
    chrome_new_width=1920
    chrome_new_height=1080

    safari_new_width=960
    safari_new_height=1080

    terminal_new_width=960
    terminal_new_height=1080

    # Move the windows to the second monitor
    xdotool windowsize "$chrome_window_id" "$chrome_new_width" "$chrome_new_height"
    xdotool windowmove "$chrome_window_id" 1920 0  # Adjust the coordinates as needed

    xdotool windowsize "$safari_window_id" "$safari_new_width" "$safari_new_height"
    xdotool windowmove "$safari_window_id" 960 0  # Adjust the coordinates as needed

    xdotool windowsize "$terminal_window_id" "$terminal_new_width" "$terminal_new_height"
    xdotool windowmove "$terminal_window_id" 0 0  # Adjust the coordinates as needed
}

# Function to move window to second monitor for macOS
move_to_second_monitor_mac() {
    # Get the window ID of the Chrome window
    chrome_window_id=$(osascript -e 'tell application "Google Chrome" to id of window 1')
    safari_window_id=$(osascript -e 'tell application "Safari" to id of window 1')
    terminal_window_id=$(osascript -e 'tell application "Terminal" to id of window 1')

    # Set the new window size (width x height)
    chrome_new_width=3840
    chrome_new_height=1080

    safari_new_width=1920
    safari_new_height=1080

    terminal_new_width=960
    terminal_new_height=1080

    # Move the window to the second monitor
    osascript -e "tell application \"Google Chrome\" to set bounds of window id $chrome_window_id to {1920, 0, $chrome_new_width, $chrome_new_height}"
    osascript -e "tell application \"Safari\" to set bounds of window id $safari_window_id to {960, 0, $safari_new_width, $safari_new_height}"
    osascript -e "tell application \"Terminal\" to set bounds of window id $terminal_window_id to {0, 0, $terminal_new_width, $terminal_new_height}"
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

