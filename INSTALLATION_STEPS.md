# Radio App - Installation Steps

Complete installation guide for Radio App on Debian/Ubuntu/Raspberry Pi OS.

## Prerequisites

- **OS**: Debian, Ubuntu, or Raspberry Pi OS (Bullseye/Bookworm)
- **Python**: 3.8 or higher
- **Internet Connection**: Required for downloading packages
- **USB Port**: For RTL-SDR dongle connection
- **Keyboard/Mouse or SSH**: For initial setup

## Installation Overview

The installation is divided into 3 main steps:

1. **RTL-SDR Driver Setup** - Build and install RTL-SDR drivers from source
2. **System Dependencies** - Install required libraries and tools
3. **Radio App Installation** - Set up the application

**Estimated Time**: 20-40 minutes (depending on hardware)

---

## Step 1: RTL-SDR Driver Installation

This step builds the RTL-SDR drivers from the latest osmocom source code and installs them as Debian packages.

### 1a. Clone the Radio App Repository

```bash
# Navigate to your home directory
cd ~

# Clone the repository
git clone https://github.com/oscarszubert7-afk/radio-app.git

# Enter the directory
cd radio-app
```

### 1b. Make the RTL-SDR Setup Script Executable

```bash
chmod +x setup-rtl-sdr-deb.sh
```

### 1c. Run the RTL-SDR Installation Script

```bash
./setup-rtl-sdr-deb.sh
```

The script will:
- ✅ Update package lists
- ✅ Install build dependencies (libusb-1.0-0-dev, git, cmake, build-essential, pkg-config, debhelper)
- ✅ Remove any old RTL-SDR installations
- ✅ Clone the latest rtl-sdr from osmocom/rtl-sdr on GitHub
- ✅ Build it as Debian packages (.deb files)
- ✅ Install the packages (librtlsdr0, librtlsdr-dev, rtl-sdr)
- ✅ Configure device permissions
- ✅ Blacklist conflicting DVB drivers
- ✅ Verify the installation

**When prompted:**
- Press `y` to confirm installation
- Enter your password when asked for sudo access

### 1d. Reboot Your System

```bash
sudo reboot
```

**Wait for your system to restart** (this is important for kernel module changes to take effect).

### 1e. Verify RTL-SDR Installation

After reboot, test the installation:

```bash
# Test RTL-SDR (with dongle connected)
rtl_test -t

# You should see output like:
# Found 1 device(s):
#   0:  Realtek, RTL2832U, SN: 12345678
```

**Note**: If you see "No supported devices found", connect your RTL-SDR dongle via USB and run again.

---

## Step 2: Radio App and System Dependencies

After RTL-SDR is installed and verified, install the Radio App and remaining dependencies.

### 2a. Make the Install Script Executable

```bash
cd ~/radio-app
chmod +x install.sh
```

### 2b. Run the Installation Script

```bash
./install.sh
```

The script will:
- ✅ Update package lists
- ✅ Install audio system (PulseAudio, ALSA)
- ✅ Install Qt5 libraries (for the GUI)
- ✅ Install signal processing libraries (with fallbacks)
- ✅ Create a Python virtual environment
- ✅ Install all Python dependencies (PyQt5, NumPy, SciPy, PyAudio, etc.)
- ✅ Run verification tests

**When prompted:**
- Press `y` to confirm installation
- Enter your password when asked for sudo access

### 2c. Verify Installation

The script will automatically verify:
- ✅ Python imports (PyQt5, NumPy, SciPy)
- ✅ RTL-SDR device detection
- ✅ Radio logic modules

Look for success messages (✓) for each component.

---

## Step 3: Running the Radio App

### 3a. Activate the Python Virtual Environment

```bash
cd ~/radio-app
source venv/bin/activate
```

You should see `(venv)` appear at the start of your terminal prompt.

### 3b. Run the Application

```bash
python ui/main.py
```

The Radio App window should open with:
- 🎚️ Ruler-style frequency selector
- 📻 FM/DAB mode toggle in the top-right corner
- 📊 Signal strength visualization area

### 3c. Basic Usage

1. **Switch Radio Mode**: Click the "FM" button in the top-right to toggle between FM and DAB
2. **Tune Frequency**: Drag the ruler horizontally to change frequency (FM: 88.0-108.0 MHz)
3. **Save Presets**: Use the preset system to save favorite stations

### 3d. Exit the Application

Press `Esc` or close the window.

### 3e. Deactivate the Virtual Environment

```bash
deactivate
```

---

## Troubleshooting

### RTL-SDR Device Not Detected

**Problem**: `rtl_test -t` shows "No supported devices found"

**Solution**:
1. Check USB connection: `lsusb | grep Realtek`
2. Verify udev rules loaded: `cat /etc/udev/rules.d/rtl-sdr.rules`
3. Check modprobe blacklist: `cat /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf`
4. Reload udev rules:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```
5. Reboot: `sudo reboot`

### PyQt5 Import Error

**Problem**: `ImportError: No module named 'PyQt5'`

**Solution**:
```bash
cd ~/radio-app
source venv/bin/activate
pip install --force-reinstall PyQt5
```

### Audio Issues

**Problem**: No sound output

**Solution**:
1. Check PulseAudio: `pactl list short sinks`
2. List audio devices: `aplay -l`
3. Set default device in `config/app_config.yaml`

### Permission Denied Errors

**Problem**: `Permission denied` when running scripts

**Solution**:
```bash
chmod +x script-name.sh
```

### Python Virtual Environment Issues

**Problem**: `(venv)` doesn't appear or commands not found

**Solution**:
```bash
# Recreate virtual environment
cd ~/radio-app
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Daily Usage

### To Run Radio App

```bash
cd ~/radio-app
source venv/bin/activate
python ui/main.py
```

### To Update Presets

Edit `config/default_presets.json`:
```json
{
  "name": "Station Name",
  "frequency_mhz": 102.4,
  "mode": "FM"
}
```

### To Check Installation Status

```bash
# Check RTL-SDR installation
dpkg -l | grep rtlsdr

# Check Python packages
cd ~/radio-app
source venv/bin/activate
pip list
```

---

## Complete Installation Checklist

- [ ] Cloned repository: `git clone https://github.com/oscarszubert7-afk/radio-app.git`
- [ ] Made setup-rtl-sdr-deb.sh executable: `chmod +x setup-rtl-sdr-deb.sh`
- [ ] Ran RTL-SDR setup: `./setup-rtl-sdr-deb.sh`
- [ ] Rebooted system: `sudo reboot`
- [ ] Verified RTL-SDR: `rtl_test -t` (showed device found)
- [ ] Made install.sh executable: `chmod +x install.sh`
- [ ] Ran Radio App install: `./install.sh`
- [ ] Verified Python environment: `python -c "import PyQt5; print('OK')"`
- [ ] Tested application: `python ui/main.py` (opened GUI)
- [ ] Added to presets (optional): Edit `config/default_presets.json`

---

## Next Steps

After successful installation, you can:

1. **Customize Presets** - Add your favorite FM/DAB stations to `config/default_presets.json`
2. **Adjust Settings** - Modify `config/app_config.yaml` for UI and backend preferences
3. **Run Tests** - Verify functionality: `python -m pytest tests/`
4. **Develop Features** - See `README.md` for architecture and development info

---

## Support & Documentation

- **README.md** - Project overview and features
- **INSTALL.md** - Detailed dependency documentation
- **setup-rtl-sdr-deb.sh** - RTL-SDR installation script
- **install.sh** - Radio App installation script
- **requirements.txt** - Python package dependencies

---

## System Requirements Summary

| Component | Requirement |
|-----------|------------|
| OS | Debian/Ubuntu/Raspberry Pi OS |
| Python | 3.8+ |
| Disk Space | ~500 MB (without virtual environment) |
| RAM | 512 MB minimum, 1 GB+ recommended |
| USB | RTL-SDR dongle support |
| Internet | Required for installation |

---

## License Information

This project uses open-source components:
- **rtl-sdr**: LGPL v2
- **PyQt5**: GPL v3
- **NumPy/SciPy**: BSD 3-Clause
- **PulseAudio**: LGPL v2.1+

See `LICENSES.md` for full attribution.

---

**Installation complete! Enjoy your Radio App! 🎙️**
