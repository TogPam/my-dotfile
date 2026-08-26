#!/usr/bin/env bash

set -euo pipefail

EWW="eww"
SCRIPT="$HOME/.config/eww/desktop-note/notes.sh"

# Chờ EWW daemon sẵn sàng
sleep 1

# Load JSON vào EWW variable
"$SCRIPT" init

# Mở icon
"$EWW" open note_icon
