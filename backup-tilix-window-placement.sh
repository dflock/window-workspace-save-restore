#!/usr/bin/env bash
# Print the current environment, without colours/escapes, so it doesn't mess up the terminal
printenv | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g'
set -o xtrace
export DISPLAY=:0.0

# Save Tilix windows
windows=$(/home/duncan/bin/window-workspace-save | grep 'tilix')

# Only overwite the file if there are windows
if [ -n "$windows" ]; then
  echo "$windows" > /home/duncan/.config/windows/tilix-windows.txt
fi
