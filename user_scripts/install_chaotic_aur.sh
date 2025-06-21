#!/usr/bin/env bash

# This script will add `chaotic-aur` as an extra repository.
# Documentation can be found in https://aur.chaotic.cx/docs

set -eu

function retrieve_primary_key() {
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
}

function install_keyring_and_mirrorlist() {
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
}

function append_chaotic_repository() {
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
}

function prompt_finished() {
    echo "Installation is ready!"
    echo "Make sure to run 'sudo pacman -Syu' before using the new repository."
}

function main() {
    retrieve_primary_key
    install_keyring_and_mirrorlist
    append_chaotic_repository
    prompt_finished
}

# Execute main only if directly run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
