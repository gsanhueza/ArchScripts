#!/usr/bin/env bash

SCRIPTFILE=${0##*/}
PRINTERFILE="printer.sh"
ENVFILE="env.sh"

source /root/$PRINTERFILE
source /root/$ENVFILE

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
    systemctl list-unit-files ly.service &>/dev/null && systemctl enable ly.service && return

    # Failed to find a display manager
    print_warning ">>> Display manager not found, continuing... <<<"
}

setup_root_account()
{
    print_message ">>> Setting root account <<<"
    chsh -s $USERSHELL

    # This is insecure AF, don't use this if your machine is being monitored
    echo "root:$PASSWORD" | chpasswd
}

setup_user_account()
{
    print_message ">>> Creating $USERNAME account <<<"
    useradd -m -G wheel -s $USERSHELL $USERNAME

    # This is insecure AF, don't use this if your machine is being monitored
    echo "$USERNAME:$PASSWORD" | chpasswd

    print_message ">>> Enabling sudo for $USERNAME <<<"
    sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL:ALL)\s\ALL\)/\1/' /etc/sudoers

    print_message ">>> Moving AUR Helper instalation script to user folder <<<"

    mv /root/yay_install.sh /home/$USERNAME/ -v
    chown $USERNAME:$USERNAME /home/$USERNAME/yay_install.sh -v
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
    (findmnt /efi || findmnt /boot/efi) &> /dev/null && BOOTPATH="/boot" || BOOTPATH=""

    ## Uncomment these lines to prevent moving Microsoft's original bootloader.
    ## Might be useful if you have an HP/MSI laptop (EFI implementation too rigid).
    # mkdir -p /boot/EFI/refind
    # cp /usr/share/refind/refind.conf-sample /boot/EFI/refind/refind.conf

    refind-install
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
    command -v grub-install &> /dev/null && install_grub && return
    command -v refind-install &> /dev/null && install_refind && return

    # Failed to install the bootloader
    print_warning ">>> Display manager not found, continuing... <<<"
}

clean_up()
{
    print_success ">>> Ready! Cleaning up <<<"

    rm $ENVFILE -vf
    rm $PRINTERFILE -vf
    rm $SCRIPTFILE -vf
}

main()
{
    set_zoneinfo &&
    enable_utc &&
    set_language &&
    set_hostname &&
    enable_networking &&
    enable_display_manager &&
    setup_root_account &&
    setup_user_account &&
    install_bootloader &&
    clean_up
}

# Execute main
main
