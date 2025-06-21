#!/usr/bin/env bash

set -eu

SCRIPTFILE=${0##*/}

BASEDIR=$(readlink -f ${0%/*})
SETUP_FILE="setup.sh"
SETUP_PATH="${BASEDIR}/${SETUP_FILE}"

source $SETUP_PATH

check_mounted_drive() {
    if [[ $(findmnt -M "$MOUNTPOINT") ]]; then
        print_success "Drive mounted in $MOUNTPOINT."
    else
        print_failure "Drive is NOT MOUNTED!"
        print_warning "Mount your drive in '$MOUNTPOINT' and re-run '$SCRIPTFILE' to install your system."
        exit 1
    fi
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

copy_configuration_scripts()
{
    local INSTALL_SCRIPTS_TARGET_DIR="${MOUNTPOINT}${INSTALL_SCRIPTS_DIR}"
    [ -e $INSTALL_SCRIPTS_TARGET_DIR ] || mkdir $INSTALL_SCRIPTS_TARGET_DIR -v

    cp $COMMONPATH $INSTALL_SCRIPTS_TARGET_DIR -v
    cp $PRINTERPATH $INSTALL_SCRIPTS_TARGET_DIR -v
    cp $ENVPATH $INSTALL_SCRIPTS_TARGET_DIR -v
    cp $CONFPATH $INSTALL_SCRIPTS_TARGET_DIR -v
}

copy_user_scripts() {
    local USER_SCRIPTS_TARGET_DIR="${MOUNTPOINT}${USER_SCRIPTS_DIR}"
    [ -e $USER_SCRIPTS_TARGET_DIR ] || mkdir $USER_SCRIPTS_TARGET_DIR -v

    cp ${BASEDIR}/user_scripts/* $USER_SCRIPTS_TARGET_DIR -v
}

configure_system()
{
    copy_configuration_scripts
    copy_user_scripts

    print_warning ">>> Configuring your system with $DESKTOP_ENV, $BOOTLOADER and $VIDEO_DRIVERS... <<<"
    arch-chroot $MOUNTPOINT /bin/zsh -c "sh $INSTALL_SCRIPTS_DIR/$CONFFILE && rm $INSTALL_SCRIPTS_DIR $USER_SCRIPTS_DIR -rf"
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
