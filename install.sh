#!/bin/bash

# Radio App Installation Script for Debian/Ubuntu/Raspberry Pi OS
# This script automates installation of all dependencies and Python packages

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Check if running as root for sudo commands
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo access. You may be prompted for your password."
    fi
}

# Step 1: Update package lists
update_packages() {
    print_header "Step 1: Updating Package Lists"
    sudo apt-get update
    print_success "Package lists updated"
}

# Step 2: Install RTL-SDR tools
install_rtl_sdr() {
    print_header "Step 2: Installing RTL-SDR Tools"
    sudo apt-get install -y rtl-sdr librtlsdr0 librtlsdr-dev
    print_success "RTL-SDR tools installed"
}

# Step 3: Install audio system
install_audio() {
    print_header "Step 3: Installing Audio System"
    sudo apt-get install -y pulseaudio alsa-utils libasound2-dev
    print_success "Audio system installed"
}

# Step 4: Install FFT/signal processing libraries
install_fft() {
    print_header "Step 4: Installing FFT Libraries"
    sudo apt-get install -y libfftw3-3 libfftw3-dev
    print_success "FFT libraries installed"
}

# Step 5: Install Qt5 libraries
install_qt5() {
    print_header "Step 5: Installing Qt5 Libraries"
    sudo apt-get install -y libqt5gui5 libqt5widgets5 libqt5core5a
    print_success "Qt5 libraries installed"
}

# Step 6: Install Python development headers
install_python_dev() {
    print_header "Step 6: Installing Python Development Headers"
    sudo apt-get install -y python3-dev python3-venv python3-pip
    print_success "Python development tools installed"
}

# Step 7: Setup RTL-SDR permissions
setup_rtl_permissions() {
    print_header "Step 7: Setting Up RTL-SDR Permissions"
    
    # Add user to plugdev and dialout groups
    sudo usermod -a -G plugdev $USER
    sudo usermod -a -G dialout $USER
    print_success "Added $USER to plugdev and dialout groups"
    
    # Add udev rules
    echo "Adding udev rules for RTL-SDR..."
    sudo tee /etc/udev/rules.d/rtl-sdr.rules > /dev/null << 'EOF'
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", MODE:="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
EOF
    
    # Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    print_success "udev rules configured"
    
    # Blacklist conflicting kernel modules
    echo "Blacklisting conflicting kernel modules..."
    sudo tee -a /etc/modprobe.d/rtl-sdr-blacklist.conf > /dev/null << 'EOF'
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF
    print_success "Kernel modules blacklisted"
}

# Step 8: Create Python virtual environment
setup_venv() {
    print_header "Step 8: Creating Python Virtual Environment"
    python3 -m venv venv
    print_success "Virtual environment created"
}

# Step 9: Install Python dependencies
install_python_deps() {
    print_header "Step 9: Installing Python Dependencies"
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
    print_success "Python dependencies installed"
}

# Step 10: Verify installation
verify_installation() {
    print_header "Step 10: Verifying Installation"
    
    # Test RTL-SDR
    echo "Testing RTL-SDR detection..."
    if rtl_test -t 2>&1 | grep -q "Found.*device"; then
        print_success "RTL-SDR device detected"
    else
        print_warning "RTL-SDR device not found (this is OK if device not connected)"
    fi
    
    # Test Python environment
    echo "Testing Python environment..."
    source venv/bin/activate
    python -m pytest tests/ -v --tb=short 2>/dev/null || print_warning "Some tests may have failed (check manually)"
    deactivate
}

# Main installation flow
main() {
    clear
    print_header "Radio App Installation Script"
    echo -e "Target: Debian/Ubuntu/Raspberry Pi OS"
    echo -e "Python: $(python3 --version)"
    echo ""
    echo "This script will install:"
    echo "  • RTL-SDR tools and libraries"
    echo "  • Audio system (PulseAudio/ALSA)"
    echo "  • Signal processing libraries (FFTW)"
    echo "  • Qt5 libraries for GUI"
    echo "  • Python 3 virtual environment"
    echo "  • All Python dependencies"
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    check_sudo
    
    # Run installation steps
    update_packages
    install_rtl_sdr
    install_audio
    install_fft
    install_qt5
    install_python_dev
    setup_rtl_permissions
    setup_venv
    install_python_deps
    verify_installation
    
    print_header "Installation Complete! ✓"
    echo ""
    echo "To start the Radio App:"
    echo -e "  ${YELLOW}source venv/bin/activate${NC}"
    echo -e "  ${YELLOW}python ui/main.py${NC}"
    echo ""
    echo "Note: You may need to log out and back in for group changes to take effect."
    echo ""
}

# Run main function
main
