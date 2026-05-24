"""Station scanning and discovery."""

import threading
from typing import Callable, Optional, List
from radio_logic.frequency_manager import FrequencyManager


class StationScanner:
    """Scans for active radio stations."""

    def __init__(self, freq_manager: FrequencyManager):
        """Initialize station scanner.

        Args:
            freq_manager: FrequencyManager instance
        """
        self.freq_manager = freq_manager
        self.is_scanning = False
        self.scan_thread: Optional[threading.Thread] = None
        self.on_station_found: Optional[Callable] = None
        self.on_scan_complete: Optional[Callable] = None

    def start_scan(self) -> None:
        """Start scanning for active stations."""
        if self.is_scanning:
            return
        self.is_scanning = True
        # TODO: Implement scanning logic

    def stop_scan(self) -> None:
        """Stop scanning."""
        self.is_scanning = False

    def get_scan_progress(self) -> float:
        """Get current scan progress (0.0 to 1.0).

        Returns:
            Progress as percentage (0.0 to 1.0)
        """
        # TODO: Implement progress tracking
        return 0.0
