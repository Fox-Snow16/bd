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

# --- 2. Download and Extract logic ---
if [ ! -d "theme-files" ] || [ ! -d "plasma-theme" ]; then
    echo "Theme assets not found. Downloading from GitHub..."
    curl -L "$REPO_URL" -o "$ZIP_NAME"
    unzip -o "$ZIP_NAME"
    cd "$EXTRACT_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

# --- 3. Distro & App Check ---
if [ -f /etc/debian_version ]; then
    OS="debian"
    INSTALL_CMD="apt-get update && apt-get install -y plymouth plymouth-themes unzip"
    REBUILD_CMD="sudo update-initramfs -u -k all"
elif [ -f /etc/fedora-release ]; then
    OS="fedora"
    INSTALL_CMD="dnf install -y plymouth unzip"
    REBUILD_CMD="sudo dracut -f"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    INSTALL_CMD="pacman -S --needed plymouth unzip"
    REBUILD_CMD="sudo mkinitcpio -p linux"
else
    echo "Unsupported Operating System."
    exit 1
fi

# --- 4. Install & Select: Plymouth (Boot Image) ---
if ask_permission "Do you want to change the Boot Image (Plymouth)?"; then
    echo "Installing required applications..."
    sudo sh -c "$INSTALL_CMD"
    
    echo "Copying Plymouth files to system..."
    sudo mkdir -p /usr/share/plymouth/themes/bad-dragon
    sudo cp -r theme-files/bad-dragon/* /usr/share/plymouth/themes/bad-dragon/
    sudo chmod -R 755 /usr/share/plymouth/themes/bad-dragon
    
    if [ "$OS" == "debian" ]; then
        echo "Registering 'bad-dragon' theme..."
        # We use a very high priority (200) to make sure it shows up
        sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/bad-dragon/bad-dragon.plymouth 200
        
        echo ""
        echo "----------------------------------------------------------"
        echo " ACTION REQUIRED: Select the number for 'bad-dragon' below "
        echo "----------------------------------------------------------"
        # Forcing the interactive config menu
        sudo update-alternatives --config default.plymouth
    fi
    
    echo "Rebuilding boot image (this may take a minute)..."
    $REBUILD_CMD
else
    echo "Skipping Boot Image installation."
fi

# --- 5. Install & Select: Splash Screen (Plasma) ---
if ask_permission "Do you want to change the Splash Screen (Plasma Look-and-Feel)?"; then
    echo "Installing Plasma theme files..."
    sudo mkdir -p /usr/share/plasma/look-and-feel/Bad-Dragon
    sudo cp -r plasma-theme/Bad-Dragon/* /usr/share/plasma/look-and-feel/Bad-Dragon/
    sudo chmod -R 755 /usr/share/plasma/look-and-feel/Bad-Dragon
    
    echo ""
    echo "Plasma theme files installed successfully!"
    echo "To apply: Go to System Settings > Colors & Themes > Splash Screen and select 'Bad-Dragon'."
else
    echo "Skipping Splash Screen installation."
fi

# --- 6. Cleanup & Exit ---
echo ""
echo "----------------------------------------------------------"
echo " Installation Process Finished! "
echo "----------------------------------------------------------"