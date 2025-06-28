# macdefaultbrowsy/dialog_automation.py

"""Dialog automation helpers.

When macOS shows the *"Do you want to use <Browser> as your default browser?"*
confirmation window (handled by `CoreServicesUIAgent`) we want to click the
confirmation button automatically so the CLI stays non-interactive.

The code spawns a background thread that, for up to *10 s*, polls the window via
AppleScript every 0.5 s.  As soon as it finds a button whose title contains the
browser display-name **or** the word *"Use"* it clicks it and exits.
"""

from __future__ import annotations

import subprocess
import threading
import time
from loguru import logger

# ---------------------------------------------------------------------------
# Mapping internal names → names shown in the system dialog
# ---------------------------------------------------------------------------


def _dialog_browser_name(browser_name: str) -> str:
    """Return the capitalised name used by the system dialog."""
    mapping = {
        "chrome": "Chrome",
        "safari": "Safari",
        "firefox": "Firefox",
        "firefoxdeveloperedition": "Firefox",
        "edgemac": "Edge",
        "chromium": "Chromium",
    }
    return mapping.get(browser_name.lower(), browser_name.capitalize())


# ---------------------------------------------------------------------------
# AppleScript runner
# ---------------------------------------------------------------------------


def _run_osascript(script: str) -> str | None:
    """Run *osascript* synchronously and return trimmed stdout on success."""
    try:
        completed = subprocess.run(
            ["osascript", "-e", script], capture_output=True, text=True, check=True
        )
        return completed.stdout.strip()
    except subprocess.CalledProcessError as exc:  # pragma: no cover – OS only
        logger.debug("osascript failed: {}", exc)
        return None


# ---------------------------------------------------------------------------
# Monitoring logic
# ---------------------------------------------------------------------------


def _monitor_and_click(browser_name: str) -> None:  # runs in thread
    display_name = _dialog_browser_name(browser_name)

    for _ in range(20):  # 20 × 0.5 s  == 10 s total
        time.sleep(0.5)
        script = f'''
            tell application "System Events"
                if exists process "CoreServicesUIAgent" then
                    if exists window 1 of process "CoreServicesUIAgent" then
                        set btns to buttons of window 1 of process "CoreServicesUIAgent"
                        repeat with theBtn in btns
                            try
                                set btnTitle to name of theBtn as string
                                if (btnTitle contains "{display_name}") or ¬
                                   (btnTitle contains "Use") then
                                    click theBtn
                                    return "Clicked:" & btnTitle
                                end if
                            end try
                        end repeat
                        return "No-match"
                    end if
                end if
                return "No-window"
            end tell'''
        result = _run_osascript(script)
        if result and result.startswith("Clicked:"):
            logger.info(
                "Dialog confirmed with button: {}", result.replace("Clicked:", "")
            )
            return
    # If we get here – no click
    logger.warning("Failed to auto-confirm the default-browser dialog.")


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def start_dialog_confirmation(browser_name: str) -> threading.Thread:
    """Start background thread that auto-confirms the default-browser dialog.

    Returns the thread object so caller can wait for completion.
    """
    thread = threading.Thread(
        target=_monitor_and_click, args=(browser_name,), daemon=False
    )
    thread.start()
    return thread
