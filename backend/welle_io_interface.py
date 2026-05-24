"""Welle.io backend interface for DAB/DAB+ radio reception."""

from typing import Optional, List, Dict, Callable


class WelleIOInterface:
    """Interface to welle.io for DAB+ radio reception."""

    def __init__(self):
        """Initialize welle.io interface."""
        self.is_scanning = False
        self.current_service: Optional[str] = None
        self.available_services: List[Dict] = []
        self.on_service_changed: Optional[Callable] = None

    def start_scan(self) -> bool:
        """Start DAB ensemble scan.

        Returns:
            bool: True if scan started, False otherwise
        """
        self.is_scanning = True
        # TODO: Implement welle.io integration
        return True

    def stop_scan(self) -> bool:
        """Stop DAB ensemble scan.

        Returns:
            bool: True if scan stopped, False otherwise
        """
        self.is_scanning = False
        return True

    def select_service(self, service_name: str) -> bool:
        """Select a DAB service by name.

        Args:
            service_name: Name of the service to select

        Returns:
            bool: True if service selected, False otherwise
        """
        self.current_service = service_name
        if self.on_service_changed:
            self.on_service_changed(service_name)
        return True

    def get_available_services(self) -> List[Dict]:
        """Get list of available DAB services.

        Returns:
            List of service dictionaries with name, frequency, etc.
        """
        return self.available_services
