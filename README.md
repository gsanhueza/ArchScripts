# ArchScripts

Custom-built scripts for (mostly) non-interactive installation of Arch Linux.

# How to use it

These script are originally intended to be part of the live ISO that you can build using [ArchISOMaker](https://www.github.com/gsanhueza/ArchISOMaker). In this repository, the `setup.sh` file is the main script what needs to be run to start the installation process.

If you want to use these scripts by yourself (i.e. directly from your host system) without having to build an ISO file (for example, to install ArchLinux in a separate disk/pendrive, or to use it with [systemd-nspawn](https://wiki.archlinux.org/title/Systemd-nspawn)), I'd recommend you to:

- Edit the `install_scripts/common.sh` file before running the main script, and modify the `CACHE_DIR` environment variable to match where you have your package cache in the host system (in ArchLinux, it's located in `/var/cache/pacman/pkg`).

Using your currently available cache lets you avoid re-downloading packages that your cache might already have.

- Edit the `setup.sh` file and comment the `setup_pacman_custom` function inside `main`, to guarantee you'll use the most updated packages instead of what you currently have in cache.

If you don't comment the line, you'll end having to use non-existent `custom.db` database that [ArchISOMaker](https://www.github.com/gsanhueza/ArchISOMaker) generates, so you'll have to [manually create a database](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Custom_local_repository) with your cache packages.

# Relevant information

The installation script (`setup.sh`) uses settings from the `install_scripts/env.sh` file, so you are required to edit it *before* installing the system!

Luckily, when installing the system using `setup.sh`, the script offer you to edit the `env.sh` file, and if you agree, it will automatically open a text editor to edit the `env.sh` file before starting the installation process.

# Script descriptions

Each script file plays a particular role:

## Main file

- `setup.sh`: The main script that orchestrates the installation process, and the post-install configuration.

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
* Nvidia (proprietary driver with open kernel modules)
