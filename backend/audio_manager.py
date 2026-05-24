"""Audio output management for radio playback."""

from typing import Optional, List


class AudioManager:
    """Manages audio output device selection and volume control."""

    def __init__(self):
        """Initialize audio manager."""
        self.current_device: Optional[str] = None
        self.volume: float = 1.0  # 0.0 to 1.0
        self.available_devices: List[str] = []

    def get_available_devices(self) -> List[str]:
        """Get list of available audio output devices.

        Returns:
            List of device names
        """
        # TODO: Implement device enumeration via PyAudio
        return self.available_devices

    def set_device(self, device_name: str) -> bool:
        """Set active audio output device.

        Args:
            device_name: Name of the device to use

        Returns:
            bool: True if device set successfully, False otherwise
        """
        self.current_device = device_name
        return True

    def set_volume(self, volume: float) -> bool:
        """Set playback volume.

        Args:
            volume: Volume level (0.0 to 1.0)

        Returns:
            bool: True if volume set successfully, False otherwise
        """
        if not (0.0 <= volume <= 1.0):
            return False
        self.volume = volume
        return True
