#!/usr/bin/env bash

SCRIPTFILE=${0##*/}
MOUNTPOINT="/mnt"

BASEDIR=$(readlink -f ${0%/*})
RECIPESDIR="${BASEDIR}/recipes"

PRINTERFILE="printer.sh"
PKGFILE="packages.sh"
ENVFILE="env.sh"
CONFFILE="config.sh"
YAYFILE="yay_install.sh"

PRINTERPATH="${BASEDIR}/${PRINTERFILE}"
PKGPATH="${BASEDIR}/${PKGFILE}"
ENVPATH="${BASEDIR}/${ENVFILE}"
CONFPATH="${BASEDIR}/${CONFFILE}"
YAYPATH="${BASEDIR}/${YAYFILE}"

# --------------------------------------- #

# Use this for OFFLINE installation (ArchISOMaker)
CACHEDIR="/root/pkg"
PACMANPATH="${BASEDIR}/pacman_custom.conf"

# Use this if for ONLINE installation
#CACHEDIR="${MOUNTPOINT}/var/cache/pacman/pkg"
#PACMANPATH="/etc/pacman.conf"

# --------------------------------------- #

source $PRINTERPATH
source $ENVPATH
source $PKGPATH

select_base_packages()
{
    print_message "Selecting base packages..."

    source "${RECIPESDIR}/base/minimal.sh"
    export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"

    source "${RECIPESDIR}/base/utilities.sh"
    export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
}

select_desktop_environment()
{
    print_message "Selecting ${DESKTOP_ENV}..."

    source "${RECIPESDIR}/desktops/${DESKTOP_ENV}.sh"
    export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
}

select_bootloader()
{
    print_message "Selecting ${BOOTLOADER}..."

    source "${RECIPESDIR}/bootloaders/${BOOTLOADER}.sh"
    export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
}

select_video_drivers()
{
    print_message "Selecting ${XORG_DRIVERS} drivers..."

    source "${RECIPESDIR}/video_drivers/${XORG_DRIVERS}.sh"
    export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
}

install_packages()
{
    print_message "Installing packages..."
    pacstrap -C $PACMANPATH $MOUNTPOINT $PACKAGES --cachedir=$CACHEDIR --needed
}

generate_fstab()
{
    genfstab -p -U $MOUNTPOINT > $MOUNTPOINT/etc/fstab
}

copy_scripts()
{
    cp $ENVPATH $MOUNTPOINT/root -v
    cp $CONFPATH $MOUNTPOINT/root -v
    cp $PRINTERPATH $MOUNTPOINT/root -v
    cp $YAYPATH $MOUNTPOINT/root -v
}

configure_system()
{
    print_warning ">>> Configuring your system with $DESKTOP_ENV, $BOOTLOADER and $XORG_DRIVERS... <<<"
    arch-chroot $MOUNTPOINT /bin/zsh -c "cd && ./$CONFFILE && rm $CONFFILE $ENVFILE -f"
}

prompt_environment()
{
    print_message "Your system will be installed using the data in '$ENVPATH'"
    print_warning "Make sure your data is correct before proceeding!"
    echo ""

    print_trailing "Do you wish to edit '$ENVPATH'? ((Y)es / (n)o / e(x)it: "
    read ans

    case $ans in
        'n'|'N')
            print_success "Ok, installing with settings retrieved from '$ENVPATH'..."
            sleep 1
        ;;
        'x'|'X')
            print_failure "Aborting installation!"
            exit 1
        ;;
        *)
            $EDITOR $ENVPATH
            print_message "--------------------------------------------"
            print_message "Press ENTER to continue, or Ctrl+C to abort."
            print_message "--------------------------------------------"

            read
            source $ENVPATH
        ;;
    esac
}

check_mounted_drive() {
    if [[ $(findmnt -M "$MOUNTPOINT") ]]; then
        print_success "Drive mounted in $MOUNTPOINT."
    else
        print_failure "Drive is NOT MOUNTED!"
        print_warning "Mount your drive in '$MOUNTPOINT' and re-run '$SCRIPTFILE' to install your system."
        exit 1
    fi
}

install_system()
{
    select_base_packages
    select_desktop_environment
    select_bootloader
    select_video_drivers

    install_packages
    generate_fstab
    copy_scripts

    configure_system
}

verify_installation()
{
    [[ ! -f $MOUNTPOINT/root/$CONFFILE && ! -f $MOUNTPOINT/root/$ENVFILE && ! -f $MOUNTPOINT/root/$PRINTERFILE ]]
}

main()
{
    # Check pre-install state
    check_mounted_drive

    # Prompt user to check environment file before installing
    prompt_environment

    # Install and verify
    install_system
    verify_installation

    # Message at end
    if [[ $? == 0 ]]; then
        print_success "Installation finished! You can reboot now."
    else
        print_failure "Installation failed! Check errors before trying again."
        exit 1
    fi
}

# Execute main
main $@
