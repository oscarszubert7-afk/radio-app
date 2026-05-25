#!/bin/bash

# RTL-SDR Driver Installation Script (Debian Package Method)
# Builds and installs rtl-sdr as proper .deb packages
# Works on Debian/Ubuntu/Raspberry Pi OS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Step 1: Update package lists
update_packages() {
    print_header "Step 1: Updating Package Lists"
    sudo apt-get update
    print_success "Package lists updated"
}

# Step 2: Install build dependencies
install_build_deps() {
    print_header "Step 2: Installing Build Dependencies"
    
    print_info "Installing required packages..."
    sudo apt-get install -y \
        libusb-1.0-0-dev \
        git \
        cmake \
        build-essential \
        pkg-config \
        debhelper
    
    print_success "Build dependencies installed"
}

# Step 3: Clean up old installations
clean_old_packages() {
    print_header "Step 3: Cleaning Old RTL-SDR Installations"
    
    print_info "Removing old package installations..."
    sudo apt-get purge -y librtlsdr0 librtlsdr-dev rtl-sdr 2>/dev/null || print_warning "No old packages found"
    
    print_info "Cleaning package cache..."
    sudo apt-get autoclean
    
    print_success "Old packages cleaned"
}

# Step 4: Clone and build rtl-sdr as Debian packages
build_rtl_sdr_deb() {
    print_header "Step 4: Building RTL-SDR as Debian Packages"
    
    # Check if rtl-sdr directory already exists
    if [ -d "rtl-sdr" ]; then
        print_warning "rtl-sdr directory already exists"
        read -p "Remove and re-clone? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf rtl-sdr
        else
            print_info "Using existing rtl-sdr directory"
            cd rtl-sdr
            return
        fi
    fi
    
    print_info "Cloning rtl-sdr repository..."
    git clone https://github.com/osmocom/rtl-sdr
    print_success "Repository cloned"
    
    cd rtl-sdr
    
    print_info "Building Debian packages (this may take a few minutes)..."
    sudo dpkg-buildpackage -b --no-sign
    print_success "Debian packages built successfully"
    
    # Return to parent directory
    cd ..
}

# Step 5: Install the .deb packages
install_deb_packages() {
    print_header "Step 5: Installing Debian Packages"
    
    print_info "Checking for built .deb packages..."
    
    # Find and install packages
    if ls librtlsdr0_*.deb 1> /dev/null 2>&1; then
        print_info "Installing librtlsdr0..."
        sudo dpkg -i librtlsdr0_*.deb
        print_success "librtlsdr0 installed"
    else
        print_error "librtlsdr0_*.deb not found!"
        return 1
    fi
    
    if ls librtlsdr-dev_*.deb 1> /dev/null 2>&1; then
        print_info "Installing librtlsdr-dev..."
        sudo dpkg -i librtlsdr-dev_*.deb
        print_success "librtlsdr-dev installed"
    else
        print_error "librtlsdr-dev_*.deb not found!"
        return 1
    fi
    
    if ls rtl-sdr_*.deb 1> /dev/null 2>&1; then
        print_info "Installing rtl-sdr..."
        sudo dpkg -i rtl-sdr_*.deb
        print_success "rtl-sdr installed"
    else
        print_error "rtl-sdr_*.deb not found!"
        return 1
    fi
    
    print_success "All Debian packages installed"
}

# Step 6: Setup device permissions and blacklist
setup_permissions() {
    print_header "Step 6: Setting Up Device Permissions"
    
    print_info "Adding user to plugdev group..."
    sudo usermod -a -G plugdev $USER 2>/dev/null || print_warning "Could not add user to plugdev"
    
    print_info "Reloading udev rules..."
    sudo udevadm control --reload-rules 2>/dev/null || print_warning "Could not reload udev rules"
    sudo udevadm trigger 2>/dev/null || print_warning "Could not trigger udev"
    
    print_info "Blacklisting conflicting DVB drivers..."
    echo 'blacklist dvb_usb_rtl28xxu' | sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf > /dev/null
    
    print_success "Device permissions configured"
}

# Step 7: Verify installation
verify_installation() {
    print_header "Step 7: Verifying RTL-SDR Installation"
    
    # Check if rtl_test is available
    if command -v rtl_test &> /dev/null; then
        print_success "rtl_test found in PATH"
        
        print_info "Running rtl_test..."
        if rtl_test -t 2>&1 | grep -q "Found.*device"; then
            print_success "RTL-SDR device detected!"
        else
            print_warning "No RTL-SDR device connected (this is OK if device not plugged in)"
        fi
    else
        print_error "rtl_test not found in PATH"
        print_info "This may be fixed after rebooting"
    fi
    
    # Check installed packages
    if dpkg -l | grep -q "librtlsdr0"; then
        print_success "librtlsdr0 package installed"
    fi
    
    if dpkg -l | grep -q "rtl-sdr"; then
        print_success "rtl-sdr package installed"
    fi
}

# Main flow
main() {
    clear
    print_header "RTL-SDR Driver Installation (Debian Package Method)"
    echo -e "Target: Debian/Ubuntu/Raspberry Pi OS"
    echo ""
    echo "This script will:"
    echo "  1. Install build dependencies"
    echo "  2. Remove old RTL-SDR installations"
    echo "  3. Clone rtl-sdr from GitHub (osmocom/rtl-sdr)"
    echo "  4. Build as proper Debian packages (.deb)"
    echo "  5. Install the .deb packages"
    echo "  6. Configure device permissions and blacklist conflicting drivers"
    echo "  7. Verify installation"
    echo ""
    print_warning "A reboot will be required after installation!"
    echo ""
    read -p "Continue with RTL-SDR driver installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    # Check for sudo
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo access"
    fi
    
    # Run steps
    update_packages
    install_build_deps
    clean_old_packages
    build_rtl_sdr_deb
    install_deb_packages
    setup_permissions
    verify_installation
    
    print_header "RTL-SDR Installation Complete! ✓"
    echo ""
    print_warning "IMPORTANT: You must reboot for changes to take effect!"
    echo ""
    echo "To reboot now:"
    echo -e "  ${YELLOW}sudo reboot${NC}"
    echo ""
    echo "After reboot, test with:"
    echo -e "  ${YELLOW}rtl_test${NC}"
    echo ""
    echo "To list installed packages:"
    echo -e "  ${YELLOW}dpkg -l | grep rtlsdr${NC}"
    echo ""
}

# Run main function
main
