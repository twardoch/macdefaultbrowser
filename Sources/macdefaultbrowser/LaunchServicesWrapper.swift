// this_file: Sources/macdefaultbrowser/LaunchServicesWrapper.swift

import Foundation
import ApplicationServices

/// Swift wrapper for Launch Services API functionality
enum LaunchServicesWrapper {
    
    /// Get all registered handlers for a given URL scheme
    /// - Parameter scheme: The URL scheme (e.g., "http", "https")
    /// - Returns: Array of bundle identifiers that can handle the scheme
    static func getAllHandlers(for scheme: String) -> [String] {
        guard let handlers = LSCopyAllHandlersForURLScheme(scheme as CFString)?.takeRetainedValue() as? [String] else {
            return []
        }
        return handlers
    }
    
    /// Get the current default handler for a given URL scheme
    /// - Parameter scheme: The URL scheme (e.g., "http", "https")
    /// - Returns: Bundle identifier of the current default handler, or nil if none
    static func getCurrentHandler(for scheme: String) -> String? {
        guard let handler = LSCopyDefaultHandlerForURLScheme(scheme as CFString)?.takeRetainedValue() as String? else {
            return nil
        }
        return handler
    }
    
    /// Set the default handler for a given URL scheme
    /// - Parameters:
    ///   - bundleID: Bundle identifier of the application to set as default
    ///   - scheme: The URL scheme (e.g., "http", "https")
    /// - Returns: Success status
    @discardableResult
    static func setDefaultHandler(_ bundleID: String, for scheme: String) -> Bool {
        let result = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleID as CFString)
        // Note: LSSetDefaultHandlerForURLScheme returns noErr (0) on success
        // It may return an error even when it succeeds in showing the dialog
        // Common error codes:
        // -10814: kLSApplicationNotFoundErr
        // -10810: kLSUnknownErr
        return result == 0 || result == -10810 // Accept -10810 as it often means dialog was shown
    }
}