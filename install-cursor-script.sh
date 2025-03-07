#!/bin/bash

# Cursor installation script
# This script cleans up any previous installation and installs the specific Cursor AppImage file

# Define colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    echo -e "${BLUE}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Get the current username
USERNAME=$(whoami)

# Check if the specified AppImage exists in the current directory
if [ ! -f "Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage" ]; then
    echo "Error: Cursor AppImage file not found in the current directory."
    echo "Please make sure 'Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage' is in the same directory as this script."
    exit 1
fi

# Clean up previous installation
print_status "Checking for previous installation..."

# Remove previous symlink
if [ -L "/usr/local/bin/cursor" ]; then
    print_warning "Removing previous symlink..."
    sudo rm -f /usr/local/bin/cursor
fi

# Remove previous desktop entry
if [ -f "$HOME/.local/share/applications/cursor.desktop" ]; then
    print_warning "Removing previous desktop entry..."
    rm -f "$HOME/.local/share/applications/cursor.desktop"
fi

# Disable and remove previous update service if it exists
if [ -f "$HOME/.config/systemd/user/update-cursor.service" ]; then
    print_warning "Disabling previous update service..."
    systemctl --user disable update-cursor.service >/dev/null 2>&1
    rm -f "$HOME/.config/systemd/user/update-cursor.service"
fi

# Remove previous update script
if [ -f "$HOME/Applications/cursor/update-cursor.sh" ]; then
    print_warning "Removing previous update script..."
    rm -f "$HOME/Applications/cursor/update-cursor.sh"
fi

# Remove previous application directory (but create a new one)
if [ -d "$HOME/Applications/cursor" ]; then
    print_warning "Cleaning previous application directory..."
    rm -rf "$HOME/Applications/cursor"
fi

# 1. Create a new folder for cursor
print_status "Creating directory for Cursor..."
mkdir -p ~/Applications/cursor
print_success "Directory created at ~/Applications/cursor"

# 2. Copy the specific Cursor AppImage to the applications folder
print_status "Copying Cursor AppImage to applications folder..."
cp "Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage" ~/Applications/cursor/cursor.AppImage
print_success "Cursor AppImage copied"

# 3. Make sure AppImage is executable
print_status "Making AppImage executable..."
chmod +x ~/Applications/cursor/cursor.AppImage
print_success "AppImage is now executable"

# 4. Make a symlink to be able to launch cursor from command line
print_status "Creating symlink in /usr/local/bin..."
sudo ln -sf ~/Applications/cursor/cursor.AppImage /usr/local/bin/cursor
print_success "Symlink created - you can now run 'cursor' from terminal"

# 5. Create a desktop entry file
print_status "Creating desktop entry..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Exec=/home/$USERNAME/Applications/cursor/cursor.AppImage
Type=Application
Categories=Utility;Development;
EOF
print_success "Desktop entry created"

print_success "Cursor has been successfully installed!"
echo ""
echo "You can now launch Cursor by:"
echo "  1. Running 'cursor' in your terminal"
echo "  2. Finding it in your application menu"
