# ArchScripts

Custom-built scripts for (mostly) non-interactive installation of Arch Linux.

# Relevant information

The installation script (`setup.sh`) uses settings from the `install_scripts/env.sh` file, so you are required to edit it *before* installing the system!

# Script descriptions

Each script file plays a particular role:

## Main files

- `setup.sh`: The main script that orchestrates the installation process, and the post-install configuration.
- `pacman_custom.conf`: A pacman file that sets up a custom repository in `/root/pkg` in the live system.

## Installation files

These files are located in the `install_scripts` folder.

- `install.sh`: The script that installs ArchLinux in your system.
- `config.sh`: The script that configures the installed system, which runs inside *chroot*.
- `env.sh`: The environment script that stores the information used to install and configure your system.
- `common.sh`: A script that stores common constants and functions for the `install.sh` and `config.sh` scripts.
- `printer.sh`: A printer script, used to print colored messages.

## Optional files

These optional files are located in the `user_scripts` folder.

These will appear in the home directory of your installed system after you reboot the live ISO.
They're useful to install the described utilities, and can be safely deleted if not required.

- `install_yay.sh`: Convenient script that allows you to install `yay` (an AUR helper) *after* installing your system.
- `install_chaotic_aur.sh`: Convenient script that allows you to install the Chaotic AUR repository *after* installing your system.

# Recipes

All packages are stored in each recipe, which is sourced and added to the pool of packages to install in your system.

Available recipes by default are:

### Desktop environments
* KDE (Plasma)
* GNOME (GNOME Shell)

### Bootloaders
* rEFInd
* GRUB

### Graphic drivers
* Default (works for AMD/Intel, check `recipes/video_drivers/default.sh` for more information)
* Nvidia (proprietary driver)
