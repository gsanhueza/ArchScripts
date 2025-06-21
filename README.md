# ArchScripts

Custom-built scripts for (mostly) non-interactive installation of Arch Linux.

# Relevant information

The installation script (`install.sh`) uses settings from the `env.sh` file, so you are required to edit it *before* installing the system!

# Script descriptions

Each script file plays a particular role:

## Required files

- `install.sh`: The main installation script.
- `config.sh`: A configuration script that runs inside *chroot*, after installing the packages.
- `constants.sh`: A script that stores common constants for the scripts.
- `env.sh`: The environment script that stores the installation/setup information.
- `printer.sh`: A printer script, mostly used to print colored messages.
- `pacman_custom.conf`: A pacman file that assumes a custom repository in `/root/pkg` when installing your system.

## Optional files

- `install_yay.sh`: Convenient script that allows you to install `yay` (an AUR helper) *after* installing your system.

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
