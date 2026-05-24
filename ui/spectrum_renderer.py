"""Spectrum visualization renderer."""

from PyQt5.QtWidgets import QWidget
from PyQt5.QtGui import QPainter


class SpectrumRenderer(QWidget):
    """Renders FFT spectrum visualization."""

    def __init__(self):
        """Initialize spectrum renderer."""
        super().__init__()
        self.spectrum_data = []

    def update_spectrum(self, data: list) -> None:
        """Update spectrum data.

        Args:
            data: Spectrum magnitude data
        """
        self.spectrum_data = data
        self.update()

    def paintEvent(self, event):
        """Paint spectrum visualization.

        Args:
            event: Paint event
        """
        painter = QPainter(self)
        # TODO: Implement spectrum rendering
        painter.drawText(10, 50, "Spectrum Renderer")
