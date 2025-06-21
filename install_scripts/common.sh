#!/usr/bin/env bash

### Directories
BASE_DIR=$(readlink -f ${0%/*})
THIS_DIR=$(dirname ${BASH_SOURCE[0]})

RECIPES_DIR="${BASE_DIR}/recipes"
INSTALL_SCRIPTS_DIR="/root/install_scripts"
USER_SCRIPTS_DIR="/root/user_scripts"

# Paths
PRINTER_PATH="${THIS_DIR}/printer.sh"
ENV_PATH="${THIS_DIR}/env.sh"

### Installation options
MOUNT_POINT="/mnt"
CACHE_DIR="/root/pkg"
PACMAN_PATH="${BASE_DIR}/pacman_custom.conf"

# Use this for ONLINE installation
#CACHE_DIR="${MOUNT_POINT}/var/cache/pacman/pkg"
#PACMAN_PATH="/etc/pacman.conf"

### Expose functions when sourcing this script file
source $PRINTER_PATH
source $ENV_PATH
