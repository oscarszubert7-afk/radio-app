# Installation Guide

## Prerequisites

### Python
- Python 3.8 or higher
- pip package manager

### System Dependencies

The application requires several external tools and libraries for SDR functionality.

#### Debian/Ubuntu (including Raspberry Pi OS)

```bash
# Update package lists
sudo apt-get update

# Install RTL-SDR tools and libraries
sudo apt-get install -y \
    rtl-sdr \
    librtlsdr0 \
    librtlsdr-dev

# Install audio system
sudo apt-get install -y \
    pulseaudio \
    alsa-utils \
    libasound2-dev

# Install FFT/signal processing libraries
sudo apt-get install -y \
    libfftw3-3 \
    libfftw3-dev

# Install Qt5 libraries (for PyQt5)
sudo apt-get install -y \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5core5a
```

#### Fedora/RHEL/CentOS

```bash
# Install RTL-SDR tools
sudo dnf install -y \
    rtl-sdr \
    rtl-sdr-devel

# Install audio system
sudo dnf install -y \
    pulseaudio \
    pulseaudio-devel \
    alsa-lib-devel

# Install FFT libraries
sudo dnf install -y \
    fftw-libs \
    fftw-devel

# Install Qt5 libraries
sudo dnf install -y \
    qt5-qtbase \
    qt5-qtwidgets
```

#### macOS (using Homebrew)

```bash
# Install RTL-SDR
brew install rtl-sdr

# Install audio libraries
brew install portaudio

# Install FFT
brew install fftw

# PyQt5 will be installed via pip
```

### Raspberry Pi Specific Setup

For Raspberry Pi OS (Bullseye/Bookworm), additional configuration may be needed:

```bash
# Ensure user can access USB devices
sudo usermod -a -G plugdev $USER
sudo usermod -a -G dialout $USER

# Add udev rules for RTL-SDR
sudo tee /etc/udev/rules.d/rtl-sdr.rules > /dev/null << EOF
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", MODE:="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Disable dvb_usb_rtl28xxu kernel module (conflicts with rtl-sdr)
sudo tee -a /etc/modprobe.d/rtl-sdr-blacklist.conf > /dev/null << EOF
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF

# Reboot to apply changes
sudo reboot
```

## Python Installation

### 1. Clone the Repository

```bash
git clone https://github.com/oscarszubert7-afk/radio-app.git
cd radio-app
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

## Verification

### Test RTL-SDR Installation

```bash
# Check if RTL-SDR device is detected
rtl_test -t

# You should see output like:
# Found 1 device(s):
#   0:  Realtek, RTL2832U, SN: 12345678
```

### Test Python Installation

```bash
# Run the test suite
python -m pytest tests/

# Run the application
python ui/main.py
```

## Troubleshooting

### RTL-SDR Device Not Found

1. Check USB connection: `lsusb | grep Realtek`
2. Verify udev rules are loaded: `cat /etc/udev/rules.d/rtl-sdr.rules`
3. Reload udev: `sudo udevadm control --reload-rules && sudo udevadm trigger`
4. Check if kernel module is loaded: `lsmod | grep dvb_usb_rtl28xxu`

### Audio Issues

- Verify PulseAudio is running: `pactl list short sinks`
- Check ALSA configuration: `aplay -l`
- Set default audio device in `config/app_config.yaml`

### PyQt5 Issues

- Reinstall PyQt5: `pip install --force-reinstall PyQt5`
- On Raspberry Pi, use: `pip install PyQt5 --only-binary :all:`

## DAB/DAB+ Support (Optional)

For DAB+ radio support, you'll need to compile and install **welle.io**:

### Build welle.io from Source

```bash
# Install build dependencies
sudo apt-get install -y \
    git \
    build-essential \
    cmake \
    libfaad-dev \
    libusb-1.0-0-dev \
    liquid-dsp-dev

# Clone and build
git clone https://github.com/AlbrechtL/welle.io.git
cd welle.io
mkdir build
cd build
cmake ..
make -j4
sudo make install
```

## Next Steps

1. Configure your RTL-SDR device in `config/app_config.yaml`
2. Add FM station presets to `config/default_presets.json`
3. Run `python ui/main.py` to start the application

## License Information

This project uses the following external dependencies:

- **rtl-sdr**: LGPL v2
- **welle.io**: LGPL v3
- **PyQt5**: GPL v3
- **SciPy/NumPy**: BSD 3-Clause
- **PulseAudio**: LGPL v2.1+

See `LICENSES.md` for full license text and attribution.
