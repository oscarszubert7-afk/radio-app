"""RTL-FM backend interface for FM radio reception."""

import subprocess
import threading
from typing import Optional, Callable


class RTLFMInterface:
    """Interface to rtl_fm for FM radio tuning and audio output."""

    def __init__(self):
        """Initialize RTL-FM interface."""
        self.process: Optional[subprocess.Popen] = None
        self.current_frequency: float = 102.4  # Default to 102.4 MHz
        self.is_tuning = False
        self.on_frequency_changed: Optional[Callable] = None

    def tune(self, frequency_mhz: float) -> bool:
        """Tune to specified FM frequency.

        Args:
            frequency_mhz: Frequency in MHz (88.0-108.0)

        Returns:
            bool: True if tuning successful, False otherwise
        """
        if not (88.0 <= frequency_mhz <= 108.0):
            return False

        self.current_frequency = frequency_mhz
        if self.on_frequency_changed:
            self.on_frequency_changed(frequency_mhz)
        return True

    def start_playback(self) -> bool:
        """Start FM radio playback at current frequency.

        Returns:
            bool: True if playback started, False otherwise
        """
        # TODO: Implement rtl_fm subprocess management
        return True

    def stop_playback(self) -> bool:
        """Stop FM radio playback.

        Returns:
            bool: True if stopped successfully, False otherwise
        """
        if self.process:
            self.process.terminate()
            self.process = None
        return True

    def get_signal_strength(self) -> float:
        """Get current signal strength (0-100).

        Returns:
            float: Signal strength percentage
        """
        # TODO: Implement signal strength monitoring
        return 0.0
