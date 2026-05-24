"""Frequency management with 100 kHz quantization."""

from typing import Optional


class FrequencyManager:
    """Manages frequency tuning with 100 kHz quantization."""

    # FM band constants
    FM_MIN_MHZ = 88.0
    FM_MAX_MHZ = 108.0
    FM_STEP_MHZ = 0.1  # 100 kHz steps

    def __init__(self):
        """Initialize frequency manager."""
        self.current_frequency = 102.4

    def quantize_frequency(self, frequency_mhz: float) -> float:
        """Quantize frequency to 100 kHz steps.

        Args:
            frequency_mhz: Frequency in MHz

        Returns:
            Quantized frequency in MHz
        """
        # Round to nearest 0.1 MHz (100 kHz)
        quantized = round(frequency_mhz / self.FM_STEP_MHZ) * self.FM_STEP_MHZ
        return max(self.FM_MIN_MHZ, min(self.FM_MAX_MHZ, quantized))

    def is_valid_frequency(self, frequency_mhz: float) -> bool:
        """Check if frequency is within valid FM range.

        Args:
            frequency_mhz: Frequency in MHz

        Returns:
            bool: True if valid, False otherwise
        """
        return self.FM_MIN_MHZ <= frequency_mhz <= self.FM_MAX_MHZ

    def get_display_string(self, frequency_mhz: Optional[float] = None) -> str:
        """Get formatted frequency display string.

        Args:
            frequency_mhz: Frequency to format (uses current if None)

        Returns:
            Formatted string (e.g., "102.4" MHz)
        """
        freq = frequency_mhz or self.current_frequency
        return f"{freq:.1f}"

    def tune_to_frequency(self, frequency_mhz: float) -> bool:
        """Tune to specified frequency.

        Args:
            frequency_mhz: Frequency in MHz

        Returns:
            bool: True if tuning successful, False otherwise
        """
        if not self.is_valid_frequency(frequency_mhz):
            return False
        self.current_frequency = self.quantize_frequency(frequency_mhz)
        return True

    def get_frequency_offset(self, target_mhz: float) -> float:
        """Get offset from current frequency to target.

        Args:
            target_mhz: Target frequency in MHz

        Returns:
            Offset in MHz (positive = target is higher)
        """
        return target_mhz - self.current_frequency
