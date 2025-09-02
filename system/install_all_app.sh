#!/bin/bash

# ===================================================================================
# Universal Application Installer for Ubuntu (v4 - Extensible & User-Friendly)
#
# This script automates the installation of applications from three sources:
# 1. APT repositories
# 2. Snap Store
# 3. Direct .deb file downloads from a configurable list of URLs
#
# Key Features:
# - Extensible: Easily add new .deb packages by editing the DEB_PACKAGES array.
# - Idempotent: Skips already installed packages to avoid redundant work.
# - User-Friendly: Shows download progress for .deb files.
# - Robust: Stops on error and cleans up temporary files.
# ===================================================================================

# --- Safety First: Exit on any error ---
set -e

# --- Helper Functions ---
is_installed() { dpkg -s "$1" &>/dev/null; }
is_snap_installed() { snap list | grep -q "^$1\s"; }

# --- CONFIGURATION ---
# Review and edit the package lists below.

# 1. APT Packages
APT_PACKAGES=(
    # Desktop Apps
    copyq
    gparted
    gedit
    meld
    parcellite
    remmina
    vim
    vlc
    zeal

    # Development Tools
    bear
    bison
    build-essential
    clang-format
    clangd
    cmake
    curl
    flex
    git
    htop
    jq
    make
    nodejs
    npm
    python3-pip
    python3-venv
    sshfs
    tmux
    xclip
    zsh
)

# 2. Snap Packages
SNAP_PACKAGES=(
    "spotify"
    "notepad-plus-plus"
)

# 3. .deb Packages from URLs
# This array is designed for easy extension. Just add a new line with the package name and its URL.
# Note: Some URLs contain version numbers and may need manual updates in the future.
declare -A DEB_PACKAGES
DEB_PACKAGES=(
    ["google-chrome-stable"]="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    ["code"]="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    ["sunloginclient"]="https://down.oray.com/sunlogin/linux/sunloginclient-latest.deb"
    ["siyuan"]="https://github.com/siyuan-note/siyuan/releases/download/v3.3.0/siyuan-3.3.0-linux.deb"
    ["bcompare"]="https://www.scootersoftware.com/files/bcompare-5.0.5.30614_amd64.deb"
    ["qqmusic"]="https://dldir1.qq.com/music/clntupate/linux/qqmusic_1.1.7_amd64.deb"
    ["youdao-dict"]="http://cidian.youdao.com/download/youdao-dict_6.0.0-ubuntu-amd64.deb"
    ["stacer"]="https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb"
    # Add your new packages here, for example:
    # ["another-app-name"]="https://example.com/path/to/another-app.deb"
)


# --- SCRIPT EXECUTION ---

main() {
    if [ "$EUID" -ne 0 ]; then
      echo "Please run this script with sudo."
      exit 1
    fi

    # Create a temporary directory for all downloads
    DOWNLOAD_DIR=$(mktemp -d)
    trap 'echo "Cleaning up temporary directory..."; rm -rf "$DOWNLOAD_DIR"' EXIT

    install_apt_packages
    install_snap_packages
    install_deb_packages

    echo ""
    echo "--- Installation script finished! ---"
    echo "It's recommended to run 'sudo apt autoremove' to clean up."
}

# --- Installation Functions ---

install_apt_packages() {
    echo ""
    echo "--- Processing APT Packages... ---"
    apt-get update

    local packages_to_install=()
    for pkg in "${APT_PACKAGES[@]}"; do
        if is_installed "$pkg"; then
            echo "APT: '$pkg' is already installed. Skipping."
        else
            packages_to_install+=("$pkg")
        fi
    done

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        echo "APT: Installing ${#packages_to_install[@]} packages: ${packages_to_install[*]}..."
        apt-get install -y "${packages_to_install[@]}"
    else
        echo "APT: All packages are already installed."
    fi
}

install_snap_packages() {
    echo ""
    echo "--- Processing Snap Packages... ---"
    local snaps_to_install=()
    for pkg in "${SNAP_PACKAGES[@]}"; do
        if is_snap_installed "$pkg"; then
            echo "Snap: '$pkg' is already installed. Skipping."
        else
            snaps_to_install+=("$pkg")
        fi
    done

    if [ ${#snaps_to_install[@]} -gt 0 ]; then
        echo "Snap: Installing ${#snaps_to_install[@]} packages: ${snaps_to_install[*]}..."
        snap install "${snaps_to_install[@]}"
    else
        echo "Snap: All packages are already installed."
    fi
}

install_deb_packages() {
    echo ""
    echo "--- Processing .deb Packages... ---"
    local deb_files_to_download=()
    local pkg_names_to_download=()
    local download_urls=()

    for pkg_name in "${!DEB_PACKAGES[@]}"; do
        if is_installed "$pkg_name"; then
            echo "DEB: '$pkg_name' is already installed. Skipping."
        else
            local url="${DEB_PACKAGES[$pkg_name]}"
            local filename="$DOWNLOAD_DIR/${pkg_name}.deb"
            deb_files_to_download+=("$filename")
            pkg_names_to_download+=("$pkg_name")
            download_urls+=("$url")
            echo "DEB: Queuing download for '$pkg_name'..."
        fi
    done

    if [ ${#deb_files_to_download[@]} -gt 0 ]; then
        echo "DEB: Starting parallel download of ${#deb_files_to_download[@]} .deb packages..."
        for i in "${!deb_files_to_download[@]}"; do
            local filename="${deb_files_to_download[$i]}"
            local url="${download_urls[$i]}"
            wget -O "$filename" "$url" &
        done

        wait # Wait for all background downloads to complete

        echo "DEB: All downloads finished. Starting installation..."
        for filename in "${deb_files_to_download[@]}"; do
            local pkg_name
            pkg_name=$(basename "$filename" .deb)
            echo "DEB: Installing '$pkg_name'..."
            dpkg -i "$filename" || true
            echo "DEB: Fixing dependencies for '$pkg_name'..."
            apt-get install -f -y
        done
    else
        echo "DEB: All packages are already installed."
    fi
}

# --- Run the main function ---
main