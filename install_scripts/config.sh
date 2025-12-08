#!/usr/bin/env bash

set -eu

BASE_DIR=$(readlink -f ${0%/*})
COMMON_PATH="${BASE_DIR}/common.sh"

source $COMMON_PATH

set_zoneinfo()
{
    print_message ">>> Linking zoneinfo <<<"
    ln -s /usr/share/zoneinfo/$ZONEINFO /etc/localtime -f
}

enable_utc()
{
    print_message ">>> Setting time <<<"
    hwclock --systohc --utc
}

set_language()
{
    print_message ">>> Enabling language and keymap <<<"

    sed -i "s/#\($LANGUAGE\.UTF-8\)/\1/" /etc/locale.gen
    echo "LANG=$LANGUAGE.UTF-8" > /etc/locale.conf
    echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
    locale-gen
}

set_hostname()
{
    print_message ">>> Creating hostname $HOSTNAME <<<"
    echo $HOSTNAME > /etc/hostname
}

enable_networking()
{
    print_message ">>> Enabling networking <<<"

    # Enable NetworkManager if found
    systemctl list-unit-files NetworkManager.service &>/dev/null && systemctl enable NetworkManager.service && return

    # Enable systemd utilities otherwise
    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service
}

enable_display_manager()
{
    print_message ">>> Enabling display manager <<<"

    # Try enabling known display managers
    systemctl list-unit-files sddm.service &>/dev/null && systemctl enable sddm.service && return
    systemctl list-unit-files gdm.service &>/dev/null && systemctl enable gdm.service && return

    # Failed to find a display manager
    print_warning ">>> Display manager not found, continuing... <<<"
}

setup_root_account()
{
    print_message ">>> Setting root account <<<"
    if !(chsh -s $USERSHELL); then
        print_warning ">>> Shell not found, skipping shell change... <<<"
    fi

    # This is insecure AF, don't use this if your machine is being monitored
    echo "root:$PASSWORD" | chpasswd
}

setup_user_account()
{
    print_message ">>> Creating $USERNAME account <<<"

    if !(useradd -m -G wheel -s $USERSHELL $USERNAME); then
        print_warning ">>> Skipping creation of already-existing user... <<<"
        return
    fi

    # This is insecure AF, don't use this if your machine is being monitored
    echo "$USERNAME:$PASSWORD" | chpasswd

    print_message ">>> Enabling sudo for $USERNAME <<<"
    if !(test -d /etc/sudoers.d); then
        print_warning ">>> No sudoers.d directory found, skipping sudo for $USERNAME... <<<"
        return
    fi

    echo '%wheel ALL=(ALL:ALL) ALL' | tee /etc/sudoers.d/10_allow_wheel
}

setup_user_scripts() {
    print_message ">>> Moving user scripts to user folder <<<"

    chown $USERNAME:$USERNAME ${USER_SCRIPTS_DIR}/* -v
    chmod u+x ${USER_SCRIPTS_DIR}/* -v
    mv ${USER_SCRIPTS_DIR}/* /home/$USERNAME -v
}

install_grub()
{
    grub-install $(findmnt / -o SOURCE | tail -n 1 | awk -F'[0-9]' '{ print $1 }') --force
    grub-mkconfig -o /boot/grub/grub.cfg
}

install_refind()
{
    # If EFI partition is mounted on `/boot`, initrd is `initrd=/initramfs-linux.img`
    # If EFI partition is mounted on `/efi` or `/boot/efi`, initrd is `initrd=/boot/initramfs-linux.img`
    if [[ $(findmnt /boot) ]]; then
        BOOTPATH=""
        BOOTPARTITION=$(findmnt -n -o SOURCE /boot)
    elif [[ $(findmnt /efi) ]]; then
        BOOTPATH="/boot"
        BOOTPARTITION=$(findmnt -n -o SOURCE /efi)
    elif [[ $(findmnt /boot/efi) ]]; then
        BOOTPATH="/boot"
        BOOTPARTITION=$(findmnt -n -o SOURCE /boot/efi)
    else
        print_failure ">>> No EFI partition found, aborting... <<<"
        exit 1
    fi

    # If you have a system with a UEFI implementation that does not support
    # non-default EFI folder locations (HP/MSI laptops, or USB drives in my experience),
    # you may need to use "refind-fallback" instead of "refind" when selecting
    # your bootloader in `env.sh`.

    # Keep in mind that using the "refind-fallback" option does not write the entry in NVRAM,
    # (which is good for USB drives, but not so good in your computer), so you might
    # have to manually edit your boot options in the UEFI firmware options of your PC.

    # Run the installer
    if [[ "$BOOTLOADER" == "refind-fallback" ]]; then
        refind-install --usedefault ${BOOTPARTITION}
    else
        refind-install
    fi

    # Configure rEFInd manually, because in chroot mode we cannot detect the UUID correctly.
    REFIND_UUID=$(cat /etc/fstab | grep UUID | grep "/ " | cut --fields=1)
    cat <<-EOF > /boot/refind_linux.conf
"Boot using default options"     "root=${REFIND_UUID} rw add_efi_memmap initrd=${BOOTPATH}/initramfs-linux.img"
"Boot using fallback initramfs"  "root=${REFIND_UUID} rw add_efi_memmap initrd=${BOOTPATH}/initramfs-linux-fallback.img"
"Boot to terminal"               "root=${REFIND_UUID} rw add_efi_memmap initrd=${BOOTPATH}/initramfs-linux.img systemd.unit=multi-user.target"
EOF
}

install_bootloader()
{
    print_message ">>> Installing $BOOTLOADER bootloader <<<"

    # Try installing the bootloader
    command -v refind-install &> /dev/null && install_refind && return
    command -v grub-install &> /dev/null && install_grub && return

    # Failed to install the bootloader
    print_warning ">>> Bootloader not found, continuing... <<<"
}

main()
{
    set_zoneinfo
    enable_utc
    set_language
    set_hostname
    enable_networking
    enable_display_manager
    setup_root_account
    setup_user_account
    setup_user_scripts
    install_bootloader

    print_success ">>> System configuration is ready! <<<"
}

# Execute main only if directly run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
