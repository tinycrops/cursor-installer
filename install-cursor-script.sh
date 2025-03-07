#!/bin/bash

# Enhanced Cursor installation script with thorough cleanup

# Define colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

# Get the current username
USERNAME=$(whoami)

# Check if the specified AppImage exists in the current directory
if [ ! -f "Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage" ]; then
    print_error "Cursor AppImage file not found in the current directory."
    echo "Please make sure 'Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage' is in the same directory as this script."
    exit 1
fi

# Ask if the user wants to perform a quick installation or a thorough one
echo "Cursor Installation Options:"
echo "  1. Quick installation (skip thorough system search for existing installations)"
echo "  2. Thorough installation (search and clean up existing Cursor installations, may take time)"
echo
read -p "Choose an option (1/2, default: 1): " install_option
install_option=${install_option:-1}

if [ "$install_option" == "2" ]; then
    print_status "Beginning thorough system search for existing Cursor installations..."

# Find all Cursor AppImages on the system (limited to common locations)
print_status "Searching for Cursor AppImage files..."
FOUND_APPIMAGES=$(find ~ -name "*cursor*.AppImage" 2>/dev/null || true)
if [ -n "$FOUND_APPIMAGES" ]; then
    print_warning "Found the following Cursor AppImage files:"
    echo "$FOUND_APPIMAGES"
    echo
    read -p "Do you want to remove these files? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        for file in $FOUND_APPIMAGES; do
            print_warning "Removing $file"
            rm -f "$file"
        done
    fi
else
    print_success "No Cursor AppImage files found in home directory."
fi

# Find all cursor executable files and symlinks
print_status "Searching for Cursor executable files and symlinks in PATH directories..."
IFS=:
for dir in $PATH; do
    if [ -e "$dir/cursor" ]; then
        print_warning "Found cursor file at $dir/cursor"
        
        # Check if it's a symlink
        if [ -L "$dir/cursor" ]; then
            echo "  -> Symlink pointing to $(readlink -f "$dir/cursor")"
        else
            echo "  -> Regular file (not a symlink)"
            # Display first few lines of the file to help identify it
            echo "  -> First 5 lines of the file:"
            head -n 5 "$dir/cursor" | sed 's/^/     /'
        fi
        
        read -p "Do you want to remove this file? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            if [[ "$dir" == /usr/* ]]; then
                sudo rm -f "$dir/cursor"
            else
                rm -f "$dir/cursor"
            fi
            print_success "Removed cursor file at $dir/cursor"
        fi
    fi
done
unset IFS

# Check specifically for the problematic file in ~/.local/bin
if [ -e "$HOME/.local/bin/cursor" ]; then
    print_warning "Found the problematic cursor file at ~/.local/bin/cursor"
    echo "This is likely causing your issue based on the error message you reported."
    read -p "Do you want to remove this file? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        rm -f "$HOME/.local/bin/cursor"
        print_success "Removed problematic cursor file at ~/.local/bin/cursor"
    fi
fi

# Find all desktop entries
print_status "Searching for Cursor desktop entries..."
DESKTOP_ENTRIES=$(find ~/.local/share/applications /usr/share/applications -name "*cursor*.desktop" 2>/dev/null || true)
if [ -n "$DESKTOP_ENTRIES" ]; then
    print_warning "Found the following Cursor desktop entries:"
    echo "$DESKTOP_ENTRIES"
    echo
    read -p "Do you want to remove these desktop entries? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        for file in $DESKTOP_ENTRIES; do
            if [[ $file == /usr/share/applications/* ]]; then
                print_warning "Removing system desktop entry $file (requires sudo)"
                sudo rm -f "$file"
            else
                print_warning "Removing user desktop entry $file"
                rm -f "$file"
            fi
        done
    fi
else
    print_success "No Cursor desktop entries found."
fi

# Remove previous update service if it exists
if [ -f "$HOME/.config/systemd/user/update-cursor.service" ]; then
    print_warning "Found previous update service. Disabling..."
    systemctl --user disable update-cursor.service >/dev/null 2>&1
    rm -f "$HOME/.config/systemd/user/update-cursor.service"
    print_success "Previous update service removed."
fi

# Clean up the standard installation directory
if [ -d "$HOME/Applications/cursor" ]; then
    print_warning "Found existing Cursor directory at ~/Applications/cursor"
    read -p "Do you want to clean this directory? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        rm -rf "$HOME/Applications/cursor"
        print_success "Removed ~/Applications/cursor directory."
    fi
fi
else
    print_status "Skipping thorough system search. Performing quick installation..."
    
    # Check specifically for the problematic file in ~/.local/bin
    if [ -e "$HOME/.local/bin/cursor" ]; then
        print_warning "Found cursor file at ~/.local/bin/cursor (commonly causes issues)"
        read -p "Do you want to remove this file? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            rm -f "$HOME/.local/bin/cursor"
            print_success "Removed cursor file at ~/.local/bin/cursor"
        fi
    fi
    
    # Check for symlink in /usr/local/bin
    if [ -e "/usr/local/bin/cursor" ]; then
        print_warning "Found cursor file at /usr/local/bin/cursor"
        read -p "Do you want to remove this file? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            sudo rm -f "/usr/local/bin/cursor"
            print_success "Removed cursor file at /usr/local/bin/cursor"
        fi
    fi
    
    # Clean standard installation directory
    if [ -d "$HOME/Applications/cursor" ]; then
        print_warning "Found existing Cursor directory at ~/Applications/cursor"
        read -p "Do you want to clean this directory? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            rm -rf "$HOME/Applications/cursor"
            print_success "Removed ~/Applications/cursor directory"
        fi
    fi
fi

# Create directories for new installation
print_status "Creating directory for Cursor..."
mkdir -p ~/Applications/cursor
print_success "Directory created at ~/Applications/cursor"

# Copy the specific Cursor AppImage to the applications folder
print_status "Copying Cursor AppImage to applications folder..."
cp "Cursor-0.46.10-7b3e0d45d4f952938dbd8e1e29c1b17003198481.deb.glibc2.25-x86_64.AppImage" ~/Applications/cursor/cursor.AppImage
print_success "Cursor AppImage copied"

# Make sure AppImage is executable
print_status "Making AppImage executable..."
chmod +x ~/Applications/cursor/cursor.AppImage
print_success "AppImage is now executable"

# Create symlink
print_status "Creating symlink in /usr/local/bin..."
sudo ln -sf ~/Applications/cursor/cursor.AppImage /usr/local/bin/cursor
print_success "Symlink created - you can now run 'cursor' from terminal"

# Create desktop entry with sandbox disabled
print_status "Creating desktop entry with sandbox disabled..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Exec=/home/$USERNAME/Applications/cursor/cursor.AppImage --no-sandbox %F
Type=Application
Categories=Utility;Development;
EOF
print_success "Desktop entry created with sandbox disabled"

# Create a wrapper script to automatically add the --no-sandbox flag
print_status "Creating wrapper script to disable sandbox..."
cat > ~/Applications/cursor/cursor-wrapper.sh << EOF
#!/bin/bash
exec ~/Applications/cursor/cursor.AppImage --no-sandbox "\$@"
EOF
chmod +x ~/Applications/cursor/cursor-wrapper.sh
print_success "Wrapper script created"

# Update the symlink to point to the wrapper script
print_status "Updating symlink to use the wrapper script..."
sudo ln -sf ~/Applications/cursor/cursor-wrapper.sh /usr/local/bin/cursor
print_success "Symlink updated to use wrapper script (with --no-sandbox flag)"

# Final verification
print_status "Verifying installation..."
CURSOR_COMMAND=$(which cursor)
if [ "$CURSOR_COMMAND" == "/usr/local/bin/cursor" ]; then
    print_success "Cursor command points to the correct location: $CURSOR_COMMAND"
else
    print_warning "Cursor command points to: $CURSOR_COMMAND"
    print_warning "This may indicate there's still another Cursor installation in your PATH."
    
    print_status "Your current PATH is:"
    echo "$PATH"
    
    print_status "Suggestion: You might want to check your ~/.bashrc, ~/.profile, or other startup files for PATH modifications."
fi

print_success "Installation complete!"
echo
echo "You can now launch Cursor by:"
echo "  1. Running 'cursor' in your terminal"
echo "  2. Finding it in your application menu"
echo
echo "If the old version still appears, you may need to restart your session or terminal."
