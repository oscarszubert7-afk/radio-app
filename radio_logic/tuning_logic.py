"""Tuning logic with snapping to presets and magnetic effects."""

from typing import Optional, List
from radio_logic.frequency_manager import FrequencyManager
from radio_logic.preset_manager import Preset


class TuningLogic:
    """Handles tuning with snapping to saved presets."""

    def __init__(
        self, freq_manager: FrequencyManager, snap_threshold_mhz: float = 0.3
    ):
        """Initialize tuning logic.

        Args:
            freq_manager: FrequencyManager instance
            snap_threshold_mhz: Frequency distance for snapping to presets (MHz)
        """
        self.freq_manager = freq_manager
        self.snap_threshold_mhz = snap_threshold_mhz

    def find_nearest_preset(
        self, frequency_mhz: float, presets: List[Preset]
    ) -> Optional[Preset]:
        """Find nearest preset to frequency.

        Args:
            frequency_mhz: Reference frequency
            presets: List of presets to search

        Returns:
            Nearest preset or None if none within threshold
        """
        nearest = None
        min_distance = self.snap_threshold_mhz

        for preset in presets:
            distance = abs(preset.frequency_mhz - frequency_mhz)
            if distance < min_distance:
                min_distance = distance
                nearest = preset

        return nearest

    def apply_magnetic_snap(
        self, frequency_mhz: float, presets: List[Preset]
    ) -> float:
        """Apply magnetic snapping to nearby presets.

        Args:
            frequency_mhz: Current frequency
            presets: List of available presets

        Returns:
            Tuned frequency (may be snapped to preset)
        """
        preset = self.find_nearest_preset(frequency_mhz, presets)
        if preset:
            return preset.frequency_mhz
        return self.freq_manager.quantize_frequency(frequency_mhz)

    def calculate_ruler_position(
        self, frequency_mhz: Optional[float] = None
    ) -> float:
        """Calculate position for ruler widget (0.0 to 1.0).

        Args:
            frequency_mhz: Frequency (uses current if None)

        Returns:
            Normalized position (0.0 = 88 MHz, 1.0 = 108 MHz)
        """
        freq = frequency_mhz or self.freq_manager.current_frequency
        min_freq = self.freq_manager.FM_MIN_MHZ
        max_freq = self.freq_manager.FM_MAX_MHZ
        return (freq - min_freq) / (max_freq - min_freq)

    def frequency_from_ruler_position(self, position: float) -> float:
        """Convert ruler position to frequency.

        Args:
            position: Normalized position (0.0 to 1.0)

        Returns:
            Frequency in MHz
        """
        min_freq = self.freq_manager.FM_MIN_MHZ
        max_freq = self.freq_manager.FM_MAX_MHZ
        freq = min_freq + position * (max_freq - min_freq)
        return self.freq_manager.quantize_frequency(freq)
