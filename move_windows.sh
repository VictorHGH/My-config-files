#!/bin/bash

link1="path-to-location"
link2="path-to-location"

# Function to move window to second monitor for Linux
move_to_second_monitor_linux() {
  # Abrir dos instancias de Chromium usando dmenu y diferentes URLs
  chromium_pid_1=$(dmenu_run -p "Abrir $link1 en Chromium" & flatpak run org.chromium.Chromium "$link1" & echo $!)
  sleep 1
  chromium_pid_2=$(dmenu_run -p "Abrir $link2 en Chromium" & flatpak run org.chromium.Chromium --new-window "$link2" & echo $!)
  sleep 1

  # Abrir Warp usando dmenu
  warp_pid=$(dmenu_run -p "Abrir Warp" & flatpak run com.warp & echo $!)
  sleep 1

  # Obtener los IDs de las ventanas de Chromium y Warp usando xdotool
  chromium_win_1=$(xdotool search --sync --pid $chromium_pid_1 | head -n 1)
  chromium_win_2=$(xdotool search --sync --pid $chromium_pid_2 | head -n 1)
  warp_win=$(xdotool search --sync --pid $warp_pid | head -n 1)

  # Mover y cambiar el tamaño de la primera ventana de Chromium a la segunda mitad del primer monitor
  xdotool windowmove "$chromium_win_1" 940 -20
  xdotool windowsize "$chromium_win_1" 995 1125

  # Mover y cambiar el tamaño de la segunda ventana de Chromium al monitor completo del segundo monitor
  xdotool windowmove "$chromium_win_2" 1950 -20
  xdotool windowsize "$chromium_win_2" 1950 1125

  # Mover y cambiar el tamaño de la ventana de Warp a la primera mitad del primer monitor
  xdotool windowmove "$warp_win" 0 0
  xdotool windowsize "$warp_win" 960 1100
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

