#!/bin/bash

# ===================================================================================
# Universal Application Installer for Ubuntu (v6 - Pipelined)
#
# This script automates the installation of applications from three sources:
# 1. APT repositories
# 2. Snap Store
# 3. Direct .deb file downloads from a configurable list of URLs
#
# Key Features:
# - Pipelined Execution: As soon as a .deb package finishes downloading, its
#   installation begins immediately while other downloads continue in the background.
# - Parallel Operations: Starts downloading .deb packages in the background while
#   Snap packages are being installed to significantly reduce total runtime.
# - Extensible: Easily add new .deb packages by editing the DEB_PACKAGES array.
# - Idempotent: Skips already installed packages to avoid redundant work.
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
    ["clash-verge"]="https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v1.5.11/clash-verge_1.5.11_amd64.deb"
    ["obsidian"]="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/obsidian_1.6.3_amd64.deb"
)

# Associative array to map download PIDs to filenames
declare -gA WGET_PIDS_TO_FILES

# --- SCRIPT EXECUTION ---

main() {
    if [ "$EUID" -ne 0 ]; then
      echo "Please run this script with sudo."
      exit 1
    fi

    # Check for modern bash for 'wait -n'
    if [ -z "$BASH_VERSION" ] || (( ${BASH_VERSION%%.*} < 4 )); then
        echo "Error: This script requires Bash version 4.3+ for pipelined execution." >&2
        exit 1
    fi

    DOWNLOAD_DIR=$(mktemp -d)
    trap 'echo "Cleaning up temporary directory..."; rm -rf "$DOWNLOAD_DIR"' EXIT

    install_apt_packages

    # This function will start downloads and return immediately
    queue_and_download_debs_background

    # Install snaps (while .debs are downloading)
    install_snap_packages

    # This function will wait for downloads and install them as they complete
    pipeline_deb_installation

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

queue_and_download_debs_background() {
    echo ""
    echo "--- Queuing and Downloading .deb Packages in Background... ---"
    local deb_files_to_download=()
    local download_urls=()

    for pkg_name in "${!DEB_PACKAGES[@]}"; do
        if is_installed "$pkg_name"; then
            echo "DEB: '$pkg_name' is already installed. Skipping download."
        else
            local url="${DEB_PACKAGES[$pkg_name]}"
            local filename="$DOWNLOAD_DIR/${pkg_name}.deb"
            deb_files_to_download+=("$filename")
            download_urls+=("$url")
            echo "DEB: Queuing background download for '$pkg_name'..."
        fi
    done

    if [ ${#deb_files_to_download[@]} -gt 0 ]; then
        echo "DEB: Starting parallel download of ${#deb_files_to_download[@]} .deb packages..."
        for i in "${!deb_files_to_download[@]}"; do
            local filename="${deb_files_to_download[$i]}"
            local url="${download_urls[$i]}"
            wget -O "$filename" "$url" &
            WGET_PIDS_TO_FILES[$!]="$filename" # Map PID to filename
        done
    else
        echo "DEB: All .deb packages are already installed."
    fi
}

pipeline_deb_installation() {
    echo ""
    echo "--- Pipelining .deb Package Installation... ---"

    if [ ${#WGET_PIDS_TO_FILES[@]} -eq 0 ]; then
        echo "DEB: No new packages to install."
        return
    fi

    local remaining_pids=("${!WGET_PIDS_TO_FILES[@]}")
    echo "DEB: Waiting for downloads to complete. ${#remaining_pids[@]} packages remaining."

    while [ ${#remaining_pids[@]} -gt 0 ]; do
        local finished_pid
        # Wait for the next background job to finish and get its PID
        if ! wait -n -p finished_pid; then
            # This handles the case where the download failed (wget exits with non-zero)
            local filename="${WGET_PIDS_TO_FILES[$finished_pid]}"
            echo "DEB: Download process for '$(basename "$filename")' failed. Skipping installation."
        else
            # Download was successful (wget exited with 0)
            local filename="${WGET_PIDS_TO_FILES[$finished_pid]}"
            echo "DEB: Download of '$(basename "$filename")' finished. Starting installation..."

            if [ -s "$filename" ]; then
                local pkg_name
                pkg_name=$(basename "$filename" .deb)
                # Installation must be sequential due to apt/dpkg locks
                echo "DEB: Installing '$pkg_name'..."
                dpkg -i "$filename" || true
                echo "DEB: Fixing dependencies for '$pkg_name'..."
                apt-get install -f -y
            else
                echo "DEB: Download for $(basename "$filename") seems to have resulted in an empty file. Skipping."
            fi
        fi

        # Remove the processed PID from our tracking map
        unset WGET_PIDS_TO_FILES[$finished_pid]
        remaining_pids=("${!WGET_PIDS_TO_FILES[@]}")
        if [ ${#remaining_pids[@]} -gt 0 ]; then
            echo "DEB: ${#remaining_pids[@]} downloads still in progress."
        fi
    done

    echo "DEB: All pipelined installations are complete."
}

# --- Run the main function ---
main