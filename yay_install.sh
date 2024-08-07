#!/usr/bin/env bash

set -e -u

# This script will install `yay` as your AUR helper.
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin
