# macdefaultbrowsy/launch_services.py

from LaunchServices import (
    LSCopyAllHandlersForURLScheme,
    LSCopyDefaultHandlerForURLScheme,
    LSSetDefaultHandlerForURLScheme,
)


def get_all_handlers_for_scheme(scheme: str):
    """
    Get all registered handlers for a given URL scheme.
    """
    return LSCopyAllHandlersForURLScheme(scheme)


def get_current_handler_for_scheme(scheme: str):
    """
    Get the current default handler for a given URL scheme.
    """
    return LSCopyDefaultHandlerForURLScheme(scheme)


def set_default_handler_for_scheme(bundle_id: str, scheme: str):
    """
    Set the default handler for a given URL scheme.
    """
    result = LSSetDefaultHandlerForURLScheme(scheme, bundle_id)
    # A non-zero result may be returned if a confirmation dialog is displayed,
    # so we treat -10810 (kLSUnknownErr) as success in that case.
    return result == 0 or result == -10810
