#!/bin/bash

# Exit on error
set -e

# Define Miniconda version and installer
MINICONDA_VERSION=py39_24.1.2-0
INSTALLER=Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh
INSTALL_PATH="$HOME/miniconda3"
DOWNLOAD_URL="https://repo.anaconda.com/miniconda/$INSTALLER"

echo "Updating package list..."
sudo apt update

echo "Installing required packages (curl, bzip2)..."
sudo apt install -y curl bzip2

echo "Downloading Miniconda installer..."
curl -LO $DOWNLOAD_URL

echo "Running Miniconda installer..."
bash $INSTALLER -b -p "$INSTALL_PATH"

echo "Removing installer..."
rm $INSTALLER

echo "Initializing Conda..."
"$INSTALL_PATH/bin/conda" init

echo "Reloading shell..."
exec "$SHELL"

echo "Installation complete! You may need to restart your terminal."
