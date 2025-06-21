#!/usr/bin/env bash

set -eu

SCRIPTFILE=${0##*/}

BASEDIR=$(readlink -f ${0%/*})
COMMONFILE="common.sh"
COMMONPATH="${BASEDIR}/${COMMONFILE}"

source $COMMONPATH

select_base_packages()
{
    print_message "Selecting base packages..."

    PACKAGES=""
    for recipe_file in $(find ${RECIPESDIR}/base -name "*.sh")
    do
        source ${recipe_file}
        export PACKAGES="${PACKAGES} ${RECIPE_PKGS}"
    done
}

select_desktop_environment()
{
    local FILEPATH="${RECIPESDIR}/desktops/${DESKTOP_ENV}.sh"

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
    local FILEPATH="${RECIPESDIR}/bootloaders/${BOOTLOADER}.sh"

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
    local FILEPATH="${RECIPESDIR}/video_drivers/${VIDEO_DRIVERS}.sh"

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
    pacstrap -C $PACMANPATH $MOUNTPOINT $PACKAGES --cachedir=$CACHEDIR --needed
}

generate_fstab()
{
    genfstab -p -U $MOUNTPOINT > $MOUNTPOINT/etc/fstab
}

copy_configuration_scripts()
{
    local MNTSCRIPTSDIR="${MOUNTPOINT}${SCRIPTSDIR}"
    mkdir $MNTSCRIPTSDIR -v

    cp $COMMONPATH $MNTSCRIPTSDIR -v
    cp $PRINTERPATH $MNTSCRIPTSDIR -v
    cp $ENVPATH $MNTSCRIPTSDIR -v
    cp $CONFPATH $MNTSCRIPTSDIR -v
}

copy_user_scripts() {
    cp $YAYPATH $MOUNTPOINT/root -v
}

configure_system()
{
    copy_configuration_scripts

    print_warning ">>> Configuring your system with $DESKTOP_ENV, $BOOTLOADER and $VIDEO_DRIVERS... <<<"
    arch-chroot $MOUNTPOINT /bin/zsh -c "sh $SCRIPTSDIR/$CONFFILE && rm $SCRIPTSDIR -rf"

    copy_user_scripts
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
}

main()
{
    # Check pre-install state
    check_mounted_drive

    # Prompt user to check environment file before installing
    prompt_environment

    # Install and configure
    install_system
    configure_system

    # Message at end
    if [[ $? == 0 ]]; then
        print_success "Installation finished! You can reboot now."
    else
        print_failure "Installation failed! Check errors before trying again."
        exit 1
    fi
}

# Execute main only if directly run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
