"""Preset station management and persistence."""

import json
import os
from typing import List, Dict, Optional


class Preset:
    """A radio station preset."""

    def __init__(self, name: str, frequency_mhz: float, mode: str = "FM"):
        """Initialize preset.

        Args:
            name: Station name
            frequency_mhz: Frequency in MHz
            mode: Radio mode (FM or DAB)
        """
        self.name = name
        self.frequency_mhz = frequency_mhz
        self.mode = mode

    def to_dict(self) -> Dict:
        """Convert preset to dictionary.

        Returns:
            Dictionary representation
        """
        return {
            "name": self.name,
            "frequency_mhz": self.frequency_mhz,
            "mode": self.mode,
        }

    @staticmethod
    def from_dict(data: Dict) -> "Preset":
        """Create preset from dictionary.

        Args:
            data: Dictionary with preset data

        Returns:
            Preset instance
        """
        return Preset(
            name=data.get("name", "Unknown"),
            frequency_mhz=data.get("frequency_mhz", 102.4),
            mode=data.get("mode", "FM"),
        )


class PresetManager:
    """Manages saved radio station presets."""

    def __init__(self, presets_file: str = "config/presets.json"):
        """Initialize preset manager.

        Args:
            presets_file: Path to presets JSON file
        """
        self.presets_file = presets_file
        self.presets: List[Preset] = []
        self.load_presets()

    def add_preset(self, preset: Preset) -> bool:
        """Add a new preset.

        Args:
            preset: Preset to add

        Returns:
            bool: True if added successfully
        """
        self.presets.append(preset)
        self.save_presets()
        return True

    def remove_preset(self, index: int) -> bool:
        """Remove preset by index.

        Args:
            index: Index of preset to remove

        Returns:
            bool: True if removed successfully
        """
        if 0 <= index < len(self.presets):
            self.presets.pop(index)
            self.save_presets()
            return True
        return False

    def get_preset_at_index(self, index: int) -> Optional[Preset]:
        """Get preset by index.

        Args:
            index: Index of preset

        Returns:
            Preset or None if index out of range
        """
        if 0 <= index < len(self.presets):
            return self.presets[index]
        return None

    def get_all_presets(self) -> List[Preset]:
        """Get all presets.

        Returns:
            List of presets
        """
        return self.presets.copy()

    def find_preset_by_frequency(self, frequency_mhz: float) -> Optional[Preset]:
        """Find preset by frequency.

        Args:
            frequency_mhz: Frequency in MHz

        Returns:
            Preset or None if not found
        """
        for preset in self.presets:
            if abs(preset.frequency_mhz - frequency_mhz) < 0.01:  # Within 10 kHz
                return preset
        return None

    def save_presets(self) -> bool:
        """Save presets to file.

        Returns:
            bool: True if saved successfully
        """
        try:
            os.makedirs(os.path.dirname(self.presets_file), exist_ok=True)
            data = [p.to_dict() for p in self.presets]
            with open(self.presets_file, "w") as f:
                json.dump(data, f, indent=2)
            return True
        except Exception:
            return False

    def load_presets(self) -> bool:
        """Load presets from file.

        Returns:
            bool: True if loaded successfully
        """
        if not os.path.exists(self.presets_file):
            return False

        try:
            with open(self.presets_file, "r") as f:
                data = json.load(f)
            self.presets = [Preset.from_dict(p) for p in data]
            return True
        except Exception:
            return False
