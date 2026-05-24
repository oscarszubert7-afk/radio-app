"""Signal strength monitoring and visualization support."""

import threading
from typing import Callable, Optional


class SignalStrengthMonitor:
    """Monitors and reports signal strength from SDR backend."""

    def __init__(self, update_interval: float = 0.1):
        """Initialize signal strength monitor.

        Args:
            update_interval: Time between updates in seconds
        """
        self.update_interval = update_interval
        self.is_monitoring = False
        self.on_signal_update: Optional[Callable] = None
        self.monitor_thread: Optional[threading.Thread] = None

    def start_monitoring(self) -> None:
        """Start monitoring signal strength."""
        self.is_monitoring = True
        # TODO: Implement monitoring loop

    def stop_monitoring(self) -> None:
        """Stop monitoring signal strength."""
        self.is_monitoring = False

    def get_signal_strength(self) -> float:
        """Get current signal strength (0-100).

        Returns:
            float: Signal strength as percentage
        """
        # TODO: Implement signal strength calculation
        return 0.0
