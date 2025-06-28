# tests/test_browser_manager.py

from unittest import mock
from macdefaultbrowsy.macdefaultbrowsy import browser_manager


@mock.patch(
    "macdefaultbrowsy.macdefaultbrowsy.launch_services.get_all_handlers_for_scheme"
)
def test_get_available_browsers(mock_get_all_handlers):
    mock_get_all_handlers.side_effect = [
        ["com.apple.Safari", "com.google.Chrome"],
        ["com.apple.Safari", "com.google.Chrome", "org.mozilla.firefox"],
    ]

    browsers = browser_manager.get_available_browsers()

    assert "safari" in browsers
    assert "chrome" in browsers
    assert "firefox" not in browsers  # It's not a handler for both http and https
    assert browsers["safari"] == "com.apple.Safari"


@mock.patch(
    "macdefaultbrowsy.macdefaultbrowsy.launch_services.get_current_handler_for_scheme"
)
def test_get_current_default_browser(mock_get_current_handler):
    mock_get_current_handler.return_value = "com.apple.Safari"

    browser = browser_manager.get_current_default_browser()

    assert browser == "safari"


@mock.patch("macdefaultbrowsy.macdefaultbrowsy.browser_manager.get_available_browsers")
@mock.patch(
    "macdefaultbrowsy.macdefaultbrowsy.launch_services.set_default_handler_for_scheme"
)
def test_set_default_browser(mock_set_handler, mock_get_browsers):
    mock_get_browsers.return_value = {"safari": "com.apple.Safari"}
    mock_set_handler.return_value = True  # Success

    success = browser_manager.set_default_browser("safari")

    assert success
    mock_set_handler.assert_any_call("com.apple.Safari", "http")
    mock_set_handler.assert_any_call("com.apple.Safari", "https")
