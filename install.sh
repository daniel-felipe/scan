#!/bin/bash

# colors
info=$(tput setaf 4)
none=$(tput sgr0)

# installing
echo "[${info}+${none}] Installing..."

[ ! -d "$HOME/.local/bin" ] && mkdir "$HOME/.local/bin/"
cp subscan.sh "$HOME/.local/bin/subscan"

echo "[${info}+${none}] Done!"

