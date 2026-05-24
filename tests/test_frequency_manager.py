"""Tests for frequency manager."""

import pytest
from radio_logic.frequency_manager import FrequencyManager


class TestFrequencyManager:
    """Test FrequencyManager class."""

    def setup_method(self):
        """Setup test fixtures."""
        self.fm = FrequencyManager()

    def test_quantize_frequency(self):
        """Test frequency quantization to 100 kHz steps."""
        assert self.fm.quantize_frequency(102.45) == 102.5
        assert self.fm.quantize_frequency(102.44) == 102.4
        assert self.fm.quantize_frequency(88.05) == 88.1

    def test_is_valid_frequency(self):
        """Test frequency validation."""
        assert self.fm.is_valid_frequency(102.4)
        assert self.fm.is_valid_frequency(88.0)
        assert self.fm.is_valid_frequency(108.0)
        assert not self.fm.is_valid_frequency(50.0)
        assert not self.fm.is_valid_frequency(150.0)

    def test_get_display_string(self):
        """Test display string formatting."""
        self.fm.current_frequency = 102.4
        assert self.fm.get_display_string() == "102.4"
        assert self.fm.get_display_string(88.0) == "88.0"
        assert self.fm.get_display_string(108.0) == "108.0"

    def test_tune_to_frequency(self):
        """Test tuning to frequency."""
        assert self.fm.tune_to_frequency(102.4)
        assert self.fm.current_frequency == 102.4
        assert self.fm.tune_to_frequency(88.0)
        assert self.fm.current_frequency == 88.0
        assert not self.fm.tune_to_frequency(50.0)

    def test_get_frequency_offset(self):
        """Test frequency offset calculation."""
        self.fm.current_frequency = 100.0
        assert self.fm.get_frequency_offset(105.0) == 5.0
        assert self.fm.get_frequency_offset(95.0) == -5.0
        assert self.fm.get_frequency_offset(100.0) == 0.0
