#!/bin/bash

# RTL-SDR Driver Installation Script
# Builds rtl-sdr from source for optimal performance
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

# Step 2: Purge old RTL-SDR drivers
purge_old_drivers() {
    print_header "Step 2: Purging Old RTL-SDR Drivers"
    
    print_info "Removing old package installations..."
    sudo apt-get purge -y ^librtlsdr 2>/dev/null || print_warning "No old librtlsdr packages found"
    
    print_info "Removing old library files..."
    sudo rm -rvf /usr/lib/librtlsdr* 2>/dev/null || print_warning "No files in /usr/lib/librtlsdr*"
    sudo rm -rvf /usr/include/rtl-sdr* 2>/dev/null || print_warning "No files in /usr/include/rtl-sdr*"
    sudo rm -rvf /usr/local/lib/librtlsdr* 2>/dev/null || print_warning "No files in /usr/local/lib/librtlsdr*"
    sudo rm -rvf /usr/local/include/rtl-sdr* 2>/dev/null || print_warning "No files in /usr/local/include/rtl-sdr*"
    sudo rm -rvf /usr/local/include/rtl_* 2>/dev/null || print_warning "No files in /usr/local/include/rtl_*"
    sudo rm -rvf /usr/local/bin/rtl_* 2>/dev/null || print_warning "No files in /usr/local/bin/rtl_*"
    
    print_success "Old drivers purged"
}

# Step 3: Install build dependencies
install_build_deps() {
    print_header "Step 3: Installing Build Dependencies"
    
    print_info "Installing required packages..."
    sudo apt-get install -y libusb-1.0-0-dev git cmake pkg-config build-essential
    
    print_success "Build dependencies installed"
}

# Step 4: Clone and build rtl-sdr from source
build_rtl_sdr() {
    print_header "Step 4: Building RTL-SDR from Source"
    
    # Check if rtl-sdr directory already exists
    if [ -d "rtl-sdr" ]; then
        print_warning "rtl-sdr directory already exists"
        read -p "Remove and re-clone? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf rtl-sdr
        else
            print_info "Using existing rtl-sdr directory"
        fi
    fi
    
    if [ ! -d "rtl-sdr" ]; then
        print_info "Cloning rtl-sdr repository..."
        git clone https://github.com/osmocom/rtl-sdr
        print_success "Repository cloned"
    fi
    
    cd rtl-sdr
    
    # Create build directory
    if [ -d "build" ]; then
        print_warning "build directory already exists, cleaning..."
        rm -rf build
    fi
    
    print_info "Creating build directory..."
    mkdir build
    cd build
    
    print_info "Configuring CMake..."
    cmake ../ -DINSTALL_UDEV_RULES=ON
    print_success "CMake configured"
    
    print_info "Building rtl-sdr (this may take a few minutes)..."
    make -j$(nproc)
    print_success "rtl-sdr built successfully"
    
    print_info "Installing rtl-sdr..."
    sudo make install
    print_success "rtl-sdr installed"
    
    print_info "Installing udev rules..."
    sudo cp ../rtl-sdr.rules /etc/udev/rules.d/
    print_success "udev rules installed"
    
    print_info "Updating library cache..."
    sudo ldconfig
    print_success "Library cache updated"
    
    cd ../..
}

# Step 5: Blacklist DVB-T drivers
blacklist_dvb() {
    print_header "Step 5: Blacklisting DVB-T TV Drivers"
    
    print_info "Adding dvb_usb_rtl28xxu to modprobe blacklist..."
    echo 'blacklist dvb_usb_rtl28xxu' | sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf > /dev/null
    
    print_success "DVB-T drivers blacklisted"
}

# Step 6: Verify installation
verify_installation() {
    print_header "Step 6: Verifying RTL-SDR Installation"
    
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
    
    # Check installed libraries
    if ldconfig -p | grep -q librtlsdr; then
        print_success "librtlsdr found in system libraries"
    else
        print_warning "librtlsdr not found in system libraries (may be fixed after reboot)"
    fi
}

# Main flow
main() {
    clear
    print_header "RTL-SDR Driver Installation from Source"
    echo -e "Target: Debian/Ubuntu/Raspberry Pi OS"
    echo ""
    echo "This script will:"
    echo "  1. Remove old RTL-SDR drivers and libraries"
    echo "  2. Install build dependencies"
    echo "  3. Clone and build rtl-sdr from GitHub (osmocom/rtl-sdr)"
    echo "  4. Install built drivers and udev rules"
    echo "  5. Blacklist conflicting DVB-T drivers"
    echo "  6. Verify installation"
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
    purge_old_drivers
    install_build_deps
    build_rtl_sdr
    blacklist_dvb
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
}

# Run main function
main
