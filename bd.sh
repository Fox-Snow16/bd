#!/bin/bash

# --- 1. Preparation & Variables ---
REPO_URL="https://github.com/Fox-Snow16/bd/archive/refs/heads/main.zip"
ZIP_NAME="bd_theme.zip"
EXTRACT_DIR="bd-main"

# Function to ask yes/no
ask_permission() {
    read -p "$1 (y/n): " choice
    case "$choice" in 
        y|Y ) return 0;;
        * ) return 1;;
    esac
}

# --- 2. Download and Extract ---
if [ ! -d "theme-files" ]; then
    echo "Downloading theme assets..."
    curl -L "$REPO_URL" -o "$ZIP_NAME"
    unzip -o "$ZIP_NAME"
    cd "$EXTRACT_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

# --- 3. Distro & App Check ---
# We separate the update and install to avoid the "no arguments" error
if [ -f /etc/debian_version ]; then
    OS="debian"
    INSTALL_CMD="sudo apt-get update && sudo apt-get install -y plymouth plymouth-themes unzip"
    REBUILD_CMD="sudo update-initramfs -u -k all"
elif [ -f /etc/fedora-release ]; then
    OS="fedora"
    INSTALL_CMD="sudo dnf install -y plymouth unzip"
    REBUILD_CMD="sudo dracut -f"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    INSTALL_CMD="sudo pacman -S --needed plymouth unzip"
    REBUILD_CMD="sudo mkinitcpio -p linux"
else
    echo "Unsupported OS."; exit 1
fi

# --- 4. Install & Select: Plymouth (Boot Image) ---
if ask_permission "Do you want to change the Boot Image (Plymouth)?"; then
    echo "Installing required apps..."
    # Using 'sh -c' ensures the double command string runs correctly
    sudo sh -c "$INSTALL_CMD"
    
    echo "Copying Plymouth files..."
    sudo mkdir -p /usr/share/plymouth/themes/bad-dragon
    sudo cp -r theme-files/bad-dragon/* /usr/share/plymouth/themes/bad-dragon/
    sudo chmod -R 755 /usr/share/plymouth/themes/bad-dragon
    
    if [ "$OS" == "debian" ]; then
        sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/bad-dragon/bad-dragon.plymouth 100
    fi
    
    echo "Setting theme as default..."
    sudo plymouth-set-default-theme -R bad-dragon
    
    echo "Rebuilding boot image..."
    $REBUILD_CMD
else
    echo "Skipping Boot Image."
fi

# --- 5. Install & Select: Splash Screen (Plasma) ---
if ask_permission "Do you want to change the Splash Screen (Plasma Look-and-Feel)?"; then
    echo "Installing Plasma theme files..."
    sudo mkdir -p /usr/share/plasma/look-and-feel/Bad-Dragon
    sudo cp -r plasma-theme/Bad-Dragon/* /usr/share/plasma/look-and-feel/Bad-Dragon/
    sudo chmod -R 755 /usr/share/plasma/look-and-feel/Bad-Dragon
    echo "Plasma theme installed!"
else
    echo "Skipping Splash Screen."
fi

echo "-----------------------------------------------"
echo "Done! You can now close this terminal."