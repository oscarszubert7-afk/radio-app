"""Preset station display widget."""

from PyQt5.QtWidgets import QWidget, QHBoxLayout, QPushButton
from radio_logic.preset_manager import PresetManager, Preset


class PresetDisplay(QWidget):
    """Display and manage preset stations."""

    def __init__(self, preset_manager: PresetManager):
        """Initialize preset display.

        Args:
            preset_manager: PresetManager instance
        """
        super().__init__()
        self.preset_manager = preset_manager
        self.layout = QHBoxLayout(self)
        self.update_preset_buttons()

    def update_preset_buttons(self) -> None:
        """Update preset buttons from manager."""
        # Clear existing buttons
        while self.layout.count():
            self.layout.takeAt(0).widget().deleteLater()

        # Add preset buttons
        for preset in self.preset_manager.get_all_presets():
            btn = QPushButton(preset.name)
            btn.clicked.connect(lambda checked, p=preset: self.on_preset_clicked(p))
            self.layout.addWidget(btn)

    def on_preset_clicked(self, preset: Preset) -> None:
        """Handle preset button click.

        Args:
            preset: Clicked preset
        """
        # TODO: Emit signal to tune to preset
        pass
