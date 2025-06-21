#!/usr/bin/env bash

### Directories
BASEDIR=$(readlink -f ${0%/*})

RECIPESDIR="${BASEDIR}/recipes"
INSTALL_SCRIPTS_DIR="/root/install_scripts"
USER_SCRIPTS_DIR="/root/user_scripts"

# Files
PRINTERFILE="printer.sh"
ENVFILE="env.sh"
CONFFILE="config.sh"

# Paths
PRINTERPATH="${BASEDIR}/${PRINTERFILE}"
ENVPATH="${BASEDIR}/${ENVFILE}"
CONFPATH="${BASEDIR}/${CONFFILE}"

### Installation options
MOUNTPOINT="/mnt"
CACHEDIR="/root/pkg"
PACMANPATH="${BASEDIR}/pacman_custom.conf"

# Use this for ONLINE installation
#CACHEDIR="${MOUNTPOINT}/var/cache/pacman/pkg"
#PACMANPATH="/etc/pacman.conf"

### Expose functions when sourcing this script file
source $PRINTERPATH
source $ENVPATH
