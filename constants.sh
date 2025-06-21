#!/usr/bin/env bash

### Base options
BASEDIR=$(readlink -f ${0%/*})

### File paths
RECIPESDIR="${BASEDIR}/recipes"

PRINTERFILE="printer.sh"
ENVFILE="env.sh"
CONFFILE="config.sh"
YAYFILE="install_yay.sh"

PRINTERPATH="${BASEDIR}/${PRINTERFILE}"
ENVPATH="${BASEDIR}/${ENVFILE}"
CONFPATH="${BASEDIR}/${CONFFILE}"
YAYPATH="${BASEDIR}/${YAYFILE}"

### Installation options
MOUNTPOINT="/mnt"
CACHEDIR="/root/pkg"
PACMANPATH="${BASEDIR}/pacman_custom.conf"

# Use this for ONLINE installation
#CACHEDIR="${MOUNTPOINT}/var/cache/pacman/pkg"
#PACMANPATH="/etc/pacman.conf"
