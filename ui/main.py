"""Main application window."""

import sys
from PyQt5.QtWidgets import QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton
from PyQt5.QtCore import Qt, pyqtSignal
from ui.ruler_widget import RulerWidget
from radio_logic.frequency_manager import FrequencyManager
from radio_logic.preset_manager import PresetManager


class RadioApp(QMainWindow):
    """Main radio application window."""

    # Signal for mode changes
    mode_changed = pyqtSignal(str)

    def __init__(self):
        """Initialize main application window."""
        super().__init__()
        self.setWindowTitle("Radio App")
        self.setGeometry(100, 100, 800, 600)

        # Initialize managers
        self.freq_manager = FrequencyManager()
        self.preset_manager = PresetManager()
        
        # Track current mode
        self.current_mode = "FM"

        # Create central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)

        # Create top bar with mode toggle
        top_bar = QHBoxLayout()
        top_bar.addStretch()  # Push toggle to the right

        # Create FM/DAB toggle button
        self.mode_toggle_btn = QPushButton("FM")
        self.mode_toggle_btn.setMaximumWidth(80)
        self.mode_toggle_btn.setObjectName("modeToggleButton")
        self.mode_toggle_btn.clicked.connect(self.toggle_mode)
        top_bar.addWidget(self.mode_toggle_btn)

        # Add top bar to main layout
        top_widget = QWidget()
        top_widget.setLayout(top_bar)
        top_widget.setMaximumHeight(50)
        main_layout.addWidget(top_widget)

        # Create ruler widget
        self.ruler_widget = RulerWidget(self.freq_manager)
        main_layout.addWidget(self.ruler_widget)

        # Set stylesheet
        self.load_stylesheet()

    def toggle_mode(self) -> None:
        """Toggle between FM and DAB modes."""
        if self.current_mode == "FM":
            self.current_mode = "DAB"
        else:
            self.current_mode = "FM"
        
        self.mode_toggle_btn.setText(self.current_mode)
        self.mode_changed.emit(self.current_mode)

    def get_current_mode(self) -> str:
        """Get the current radio mode.

        Returns:
            str: Current mode ("FM" or "DAB")
        """
        return self.current_mode

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
    from PyQt5.QtWidgets import QApplication
    app = QApplication(sys.argv)
    radio_app = RadioApp()
    radio_app.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
