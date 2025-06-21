#!/usr/bin/env bash

set -eu

BASE_DIR=$(readlink -f ${0%/*})
COMMON_PATH="${BASE_DIR}/common.sh"

source $COMMON_PATH

select_base_packages()
{
    print_message "Selecting base packages..."

    PACKAGES=""
    for recipe_file in $(find ${RECIPES_DIR}/base -name "*.sh")
    do
        source ${recipe_file}
        export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
    done
}

select_desktop_environment()
{
    local FILEPATH="${RECIPES_DIR}/desktops/${DESKTOP_ENV}.sh"

    if test -f $FILEPATH; then
        print_message "Selecting ${DESKTOP_ENV}..."
        source $FILEPATH
        export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
    else
        print_warning "Skipping desktop selection..."
    fi
}

select_bootloader()
{
    local FILEPATH="${RECIPES_DIR}/bootloaders/${BOOTLOADER}.sh"

    if test -f $FILEPATH; then
        print_message "Selecting ${BOOTLOADER}..."
        source $FILEPATH
        export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
    else
        print_warning "Skipping bootloader selection..."
    fi
}

select_video_drivers()
{
    local FILEPATH="${RECIPES_DIR}/video_drivers/${VIDEO_DRIVERS}.sh"

    if test -f $FILEPATH; then
        print_message "Selecting ${VIDEO_DRIVERS} drivers..."
        source $FILEPATH
        export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
    else
        print_warning "Skipping video drivers selection..."
    fi
}

install_packages()
{
    print_message "Installing packages..."
    pacstrap -C $PACMAN_PATH $MOUNT_POINT $PACKAGES --cachedir=$CACHE_DIR --needed
}

generate_fstab()
{
    genfstab -p -U $MOUNT_POINT > $MOUNT_POINT/etc/fstab
}

install_system()
{
    select_base_packages
    select_desktop_environment
    select_bootloader
    select_video_drivers

    install_packages
    generate_fstab
}

# Execute installation only if directly run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_system
fi
