// this_file: Sources/macdefaultbrowser/BrowserManager.swift

import Foundation

/// Manages browser detection and default browser settings
struct BrowserManager {
    
    /// Extract browser name from bundle identifier
    /// e.g., "com.google.Chrome" -> "chrome"
    /// - Parameter bundleID: Bundle identifier
    /// - Returns: Lowercase browser name
    static func browserName(from bundleID: String) -> String {
        let components = bundleID.split(separator: ".")
        return components.last?.lowercased() ?? bundleID.lowercased()
    }
    
    /// Get all available browsers that can handle HTTP/HTTPS
    /// - Returns: Dictionary mapping browser names to bundle identifiers
    static func getAvailableBrowsers() -> [String: String] {
        let handlers = LaunchServicesWrapper.getAllHandlers(for: "http")
        var browsers: [String: String] = [:]
        
        for handler in handlers {
            let name = browserName(from: handler)
            browsers[name] = handler
        }
        
        return browsers
    }
    
    /// Get the current default browser name
    /// - Returns: Name of the current default browser, or nil if none
    static func getCurrentDefaultBrowser() -> String? {
        guard let handler = LaunchServicesWrapper.getCurrentHandler(for: "http") else {
            return nil
        }
        return browserName(from: handler)
    }
    
    /// Set a browser as the default for both HTTP and HTTPS
    /// - Parameter browserName: Name of the browser to set as default
    /// - Throws: BrowserError if browser not found or setting fails
    static func setDefaultBrowser(_ browserName: String) throws {
        let browsers = getAvailableBrowsers()
        
        // Case-insensitive lookup
        let matchingBrowser = browsers.first { key, _ in
            key.caseInsensitiveCompare(browserName) == .orderedSame
        }
        
        guard let (_, bundleID) = matchingBrowser else {
            throw BrowserError.browserNotFound(browserName)
        }
        
        // Check if already default
        if let currentDefault = getCurrentDefaultBrowser(),
           currentDefault.caseInsensitiveCompare(browserName) == .orderedSame {
            throw BrowserError.alreadyDefault(browserName)
        }
        
        // Set for both HTTP and HTTPS
        let httpSuccess = LaunchServicesWrapper.setDefaultHandler(bundleID, for: "http")
        let httpsSuccess = LaunchServicesWrapper.setDefaultHandler(bundleID, for: "https")
        
        if !httpSuccess || !httpsSuccess {
            throw BrowserError.setDefaultFailed(browserName)
        }
    }
    
    /// List all available browsers with current default marked
    /// - Returns: Array of tuples (browserName, isDefault)
    static func listBrowsers() -> [(name: String, isDefault: Bool)] {
        let browsers = getAvailableBrowsers()
        let currentDefault = getCurrentDefaultBrowser()
        
        return browsers.keys.sorted().map { name in
            let isDefault = currentDefault?.caseInsensitiveCompare(name) == .orderedSame
            return (name: name, isDefault: isDefault)
        }
    }
}

/// Errors that can occur during browser management
enum BrowserError: LocalizedError {
    case browserNotFound(String)
    case alreadyDefault(String)
    case setDefaultFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .browserNotFound(let name):
            return "\(name) is not available as an HTTP handler"
        case .alreadyDefault(let name):
            return "\(name) is already set as the default HTTP handler"
        case .setDefaultFailed(let name):
            return "Failed to set \(name) as the default browser"
        }
    }
}