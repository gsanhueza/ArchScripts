#!/usr/bin/env bash

# This script will install `yay` as your AUR helper.

set -eu

function test_git_availability() {
    command -v git > /dev/null 2>&1
}

function prompt_git_installation() {
    echo "Git is not installed in the system!"
    echo "Install it with 'sudo pacman -S git' and then re-run this script."
    exit 1
}

function install_yay() {
    [[ -e /tmp/yay-bin ]] && rm -rf /tmp/yay-bin
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    makepkg --dir /tmp/yay-bin -sic --noconfirm
}

function main() {
    test_git_availability || prompt_git_installation
    install_yay
}

# Execute main only if directly run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
