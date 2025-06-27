// this_file: Sources/macdefaultbrowser/main.swift

import Foundation

/// Main entry point for macdefaultbrowser
@main
struct MacDefaultBrowser {
    static func main() async {
        let arguments = CommandLine.arguments
        
        // If no arguments, list browsers
        if arguments.count == 1 {
            listBrowsers()
        } else {
            // Set browser as default
            let browserName = arguments[1]
            await setDefaultBrowser(browserName)
        }
    }
    
    /// List all available browsers with current default marked
    static func listBrowsers() {
        let browsers = BrowserManager.listBrowsers()
        
        for browser in browsers {
            let mark = browser.isDefault ? "* " : "  "
            print("\(mark)\(browser.name)")
        }
    }
    
    /// Set a browser as the default with automatic dialog confirmation
    /// - Parameter browserName: Name of the browser to set as default
    static func setDefaultBrowser(_ browserName: String) async {
        do {
            try await DialogAutomation.setDefaultBrowserWithAutomation(browserName)
        } catch BrowserError.alreadyDefault(let name) {
            print("\(name) is already set as the default HTTP handler")
            exit(0)
        } catch BrowserError.browserNotFound(let name) {
            print("\(name) is not available as an HTTP handler")
            exit(1)
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }
}