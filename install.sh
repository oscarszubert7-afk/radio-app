#!/bin/bash

# Radio App Installation Script for Debian/Ubuntu/Raspberry Pi OS
# This script automates installation of all dependencies and Python packages
# with intelligent fallbacks for unavailable packages

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for tracking
SKIPPED_PACKAGES=0
CRITICAL_FAILURES=0

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running as root for sudo commands
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo access. You may be prompted for your password."
    fi
}

# Attempt to install a package with fallbacks
# Usage: install_with_fallback "package1" "package2" "package3" "Description" true/false
# Last parameter (true) = critical (fail if all attempts fail), false = optional
install_with_fallback() {
    local description="${@: -2:1}"
    local is_critical="${@: -1}"
    local packages=("${@:1:$#-2}")
    
    print_info "Installing: $description"
    
    for package in "${packages[@]}"; do
        if sudo apt-get install -y "$package" 2>/dev/null; then
            print_success "$description installed ($package)"
            return 0
        fi
    done
    
    # All attempts failed
    if [ "$is_critical" = true ]; then
        print_error "$description - ALL ATTEMPTS FAILED (CRITICAL)"
        CRITICAL_FAILURES=$((CRITICAL_FAILURES + 1))
        return 1
    else
        print_warning "$description - not found (trying Python alternatives or skipping)"
        SKIPPED_PACKAGES=$((SKIPPED_PACKAGES + 1))
        return 1
    fi
}

# Step 1: Update package lists
update_packages() {
    print_header "Step 1: Updating Package Lists"
    sudo apt-get update
    print_success "Package lists updated"
}

# Step 2: Install RTL-SDR tools (CRITICAL)
install_rtl_sdr() {
    print_header "Step 2: Installing RTL-SDR Tools (CRITICAL)"
    
    install_with_fallback \
        "rtl-sdr" \
        "RTL-SDR main package" \
        true
    
    install_with_fallback \
        "librtlsdr0" "librtlsdr0:armhf" \
        "RTL-SDR runtime library" \
        true
    
    install_with_fallback \
        "librtlsdr-dev" "librtlsdr-dev:armhf" \
        "RTL-SDR development headers" \
        true
    
    print_success "RTL-SDR tools installed"
}

# Step 3: Install audio system (CRITICAL)
install_audio() {
    print_header "Step 3: Installing Audio System (CRITICAL)"
    
    install_with_fallback \
        "pulseaudio" \
        "PulseAudio" \
        true
    
    install_with_fallback \
        "alsa-utils" "alsa" \
        "ALSA utilities" \
        true
    
    install_with_fallback \
        "libasound2-dev" "libasound2-dev:armhf" \
        "ALSA development headers" \
        true
    
    print_success "Audio system installed"
}

# Step 4: Install FFT/signal processing libraries (OPTIONAL - Python fallback available)
install_fft() {
    print_header "Step 4: Installing FFT/Signal Processing Libraries (Optional)"
    
    install_with_fallback \
        "libfftw3-3" "libfftw3-3:armhf" \
        "FFTW3 library" \
        false
    
    install_with_fallback \
        "libfftw3-dev" "libfftw3-dev:armhf" \
        "FFTW3 development headers" \
        false
    
    print_info "Note: NumPy/SciPy will provide FFT functionality if system libs unavailable"
}

# Step 5: Install Qt5 libraries (CRITICAL)
install_qt5() {
    print_header "Step 5: Installing Qt5 Libraries (CRITICAL)"
    
    install_with_fallback \
        "libqt5gui5" "libqt5gui5:armhf" \
        "Qt5 GUI library" \
        true
    
    install_with_fallback \
        "libqt5widgets5" "libqt5widgets5:armhf" \
        "Qt5 Widgets library" \
        true
    
    install_with_fallback \
        "libqt5core5a" "libqt5core5a:armhf" \
        "Qt5 Core library" \
        true
    
    print_success "Qt5 libraries installed"
}

# Step 6: Install Python development headers (CRITICAL)
install_python_dev() {
    print_header "Step 6: Installing Python Development Headers (CRITICAL)"
    
    install_with_fallback \
        "python3-dev" "python3-devel" \
        "Python development headers" \
        true
    
    install_with_fallback \
        "python3-venv" \
        "Python virtual environment" \
        true
    
    install_with_fallback \
        "python3-pip" \
        "Python package manager (pip)" \
        true
    
    print_success "Python development tools installed"
}

# Step 7: Install build essentials (OPTIONAL - may be needed for compiling extensions)
install_build_tools() {
    print_header "Step 7: Installing Build Tools (Optional)"
    
    install_with_fallback \
        "build-essential" "gcc g++ make" \
        "Build essentials" \
        false
    
    install_with_fallback \
        "git" \
        "Git version control" \
        false
}

# Step 8: Setup RTL-SDR permissions
setup_rtl_permissions() {
    print_header "Step 8: Setting Up RTL-SDR Permissions"
    
    # Add user to plugdev and dialout groups
    sudo usermod -a -G plugdev $USER 2>/dev/null || print_warning "Could not add user to plugdev group"
    sudo usermod -a -G dialout $USER 2>/dev/null || print_warning "Could not add user to dialout group"
    print_success "Added $USER to plugdev and dialout groups"
    
    # Add udev rules
    print_info "Adding udev rules for RTL-SDR..."
    sudo tee /etc/udev/rules.d/rtl-sdr.rules > /dev/null << 'EOF'
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", MODE:="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
EOF
    
    # Reload udev rules
    sudo udevadm control --reload-rules 2>/dev/null || print_warning "Could not reload udev rules"
    sudo udevadm trigger 2>/dev/null || print_warning "Could not trigger udev"
    print_success "udev rules configured"
    
    # Blacklist conflicting kernel modules
    print_info "Blacklisting conflicting kernel modules..."
    sudo tee -a /etc/modprobe.d/rtl-sdr-blacklist.conf > /dev/null << 'EOF'
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF
    print_success "Kernel modules blacklisted"
}

# Step 9: Create Python virtual environment
setup_venv() {
    print_header "Step 9: Creating Python Virtual Environment"
    
    if [ -d "venv" ]; then
        print_warning "Virtual environment already exists, skipping creation"
    else
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
}

# Step 10: Install Python dependencies
install_python_deps() {
    print_header "Step 10: Installing Python Dependencies"
    
    source venv/bin/activate
    
    print_info "Upgrading pip, setuptools, and wheel..."
    pip install --upgrade pip setuptools wheel
    
    print_info "Installing requirements from requirements.txt..."
    if pip install -r requirements.txt; then
        print_success "Python dependencies installed"
    else
        print_warning "Some Python packages may have failed to install"
        print_info "Attempting to install core packages individually..."
        
        # Try individual installation of core packages
        pip install PyQt5 || print_warning "PyQt5 installation had issues"
        pip install numpy scipy || print_warning "NumPy/SciPy installation had issues"
        pip install PyAudio || print_warning "PyAudio installation had issues (audio may not work)"
        
        print_success "Python dependencies partially installed (see warnings above)"
    fi
    
    deactivate
}

# Step 11: Verify installation
verify_installation() {
    print_header "Step 11: Verifying Installation"
    
    # Test RTL-SDR
    print_info "Testing RTL-SDR detection..."
    if command -v rtl_test &> /dev/null; then
        if rtl_test -t 2>&1 | grep -q "Found.*device"; then
            print_success "RTL-SDR device detected"
        else
            print_warning "RTL-SDR device not found (this is OK if device not connected)"
        fi
    else
        print_error "RTL-SDR tools not found!"
    fi
    
    # Test Python environment
    print_info "Testing Python environment..."
    source venv/bin/activate
    
    if python -c "import PyQt5" 2>/dev/null; then
        print_success "PyQt5 imported successfully"
    else
        print_error "PyQt5 import failed!"
    fi
    
    if python -c "import numpy, scipy" 2>/dev/null; then
        print_success "NumPy and SciPy imported successfully"
    else
        print_warning "NumPy or SciPy import failed (may affect signal processing)"
    fi
    
    if python -c "import radio_logic.frequency_manager" 2>/dev/null; then
        print_success "Radio logic modules imported successfully"
    else
        print_warning "Could not import radio logic modules"
    fi
    
    deactivate
}

# Print installation summary
print_summary() {
    print_header "Installation Summary"
    
    if [ $CRITICAL_FAILURES -gt 0 ]; then
        print_error "CRITICAL: $CRITICAL_FAILURES critical package(s) failed to install"
        print_error "Installation may not work correctly"
        return 1
    else
        print_success "All critical packages installed successfully"
    fi
    
    if [ $SKIPPED_PACKAGES -gt 0 ]; then
        print_warning "$SKIPPED_PACKAGES optional package(s) were skipped"
        print_info "This is usually OK - Python libraries will provide fallback functionality"
    fi
    
    return 0
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
    echo "  • Signal processing libraries (FFTW, fallback to Python)"
    echo "  • Qt5 libraries for GUI"
    echo "  • Build tools (optional)"
    echo "  • Python 3 virtual environment"
    echo "  • All Python dependencies"
    echo ""
    echo "Features:"
    echo "  • Automatic fallbacks for missing packages"
    echo "  • Multi-architecture support (x86_64, ARM)"
    echo "  • Graceful error handling"
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
    install_build_tools
    setup_rtl_permissions
    setup_venv
    install_python_deps
    verify_installation
    print_summary
    
    SUMMARY_RESULT=$?
    
    print_header "Installation Complete!"
    echo ""
    echo "To start the Radio App:"
    echo -e "  ${YELLOW}source venv/bin/activate${NC}"
    echo -e "  ${YELLOW}python ui/main.py${NC}"
    echo ""
    echo "To deactivate the virtual environment:"
    echo -e "  ${YELLOW}deactivate${NC}"
    echo ""
    echo "Note: You may need to log out and back in for group changes to take effect."
    echo ""
    
    exit $SUMMARY_RESULT
}

# Run main function
main
