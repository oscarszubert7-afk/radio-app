"""Main application window."""

import sys
from PyQt5.QtWidgets import QMainWindow, QWidget, QVBoxLayout
from PyQt5.QtCore import Qt
from ui.ruler_widget import RulerWidget
from radio_logic.frequency_manager import FrequencyManager
from radio_logic.preset_manager import PresetManager


class RadioApp(QMainWindow):
    """Main radio application window."""

    def __init__(self):
        """Initialize main application window."""
        super().__init__()
        self.setWindowTitle("Radio App")
        self.setGeometry(100, 100, 800, 600)

        # Initialize managers
        self.freq_manager = FrequencyManager()
        self.preset_manager = PresetManager()

        # Create central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        # Create ruler widget
        self.ruler_widget = RulerWidget(self.freq_manager)
        layout.addWidget(self.ruler_widget)

        # Set stylesheet
        self.load_stylesheet()

    def load_stylesheet(self) -> None:
        """Load application stylesheet."""
        try:
            with open("ui/styles.qss", "r") as f:
                self.setStyleSheet(f.read())
        except FileNotFoundError:
            pass

    def keyPressEvent(self, event):
        """Handle keyboard events."""
        if event.key() == Qt.Key_Escape:
            self.close()
        else:
            super().keyPressEvent(event)


def main():
    """Run the application."""
    app = RadioApp()
    app.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
