#!/usr/bin/env bash

### File paths
BASEDIR=$(readlink -f ${0%/*})

RECIPESDIR="${BASEDIR}/recipes"
SCRIPTSDIR="/root/scripts"

PRINTERFILE="printer.sh"
ENVFILE="env.sh"
CONFFILE="config.sh"

PRINTERPATH="${BASEDIR}/${PRINTERFILE}"
ENVPATH="${BASEDIR}/${ENVFILE}"
CONFPATH="${BASEDIR}/${CONFFILE}"

# User scripts
YAYFILE="install_yay.sh"
YAYPATH="${BASEDIR}/${YAYFILE}"

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
