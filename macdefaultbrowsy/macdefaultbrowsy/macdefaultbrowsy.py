# macdefaultbrowsy/macdefaultbrowsy.py

import time
from loguru import logger
from . import launch_services, dialog_automation


def _browser_name_from_bundle_id(bundle_id: str) -> str:
    """
    Extracts a user-friendly browser name from a bundle identifier.
    Example: com.google.Chrome -> chrome
    """
    return bundle_id.split(".")[-1].lower()


def _get_available_browsers() -> dict:
    """
    Returns dict of available browsers: {browser_name: bundle_id}.
    """
    http_handlers = launch_services.get_all_handlers_for_scheme("http") or []
    https_handlers = launch_services.get_all_handlers_for_scheme("https") or []

    all_handlers = set(http_handlers) & set(https_handlers)

    browsers = {}
    for handler in all_handlers:
        name = _browser_name_from_bundle_id(handler)
        browsers[name] = handler

    return browsers


def read_default_browser() -> str | None:
    """
    Returns the name of the current default browser.
    """
    handler = launch_services.get_current_handler_for_scheme("http")
    if handler:
        return _browser_name_from_bundle_id(handler)
    return None


def set_default_browser(browser_id: str) -> bool:
    """
    Sets the default browser with automatic dialog confirmation.
    """
    browsers = _get_available_browsers()
    if browser_id not in browsers:
        logger.error(f"Browser '{browser_id}' not found.")
        return False

    bundle_id = browsers[browser_id]

    # Start background confirmation BEFORE triggering the dialog
    dialog_thread = dialog_automation.start_dialog_confirmation(browser_id)

    # Small delay to ensure monitor is running
    time.sleep(0.1)

    http_ok = launch_services.set_default_handler_for_scheme(bundle_id, "http")
    https_ok = launch_services.set_default_handler_for_scheme(bundle_id, "https")

    if http_ok and https_ok:
        # Wait for dialog automation thread to complete
        dialog_thread.join(timeout=10.0)  # Max 10 seconds
        logger.info(f"Successfully set {browser_id} as default.")
        return True

    return False


def list_browsers():
    """
    Lists all available browsers, marking the default with a *.
    """
    available_browsers = _get_available_browsers()
    current_browser = read_default_browser()

    for name in sorted(available_browsers.keys()):
        if name == current_browser:
            logger.info(f"* {name}")
        else:
            logger.info(f"  {name}")
