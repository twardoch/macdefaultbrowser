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
            let arg = arguments[1]
            
            // Check for version flag
            if arg == "--version" || arg == "-v" {
                print("macdefaultbrowser \(Version.version)")
                exit(0)
            }
            
            // Check for help flag
            if arg == "--help" || arg == "-h" {
                printHelp()
                exit(0)
            }
            
            // Set browser as default
            await setDefaultBrowser(arg)
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
    
    /// Print help information
    static func printHelp() {
        print("""
        macdefaultbrowser \(Version.version)
        
        A command-line tool for managing the default web browser on macOS.
        
        Usage:
            macdefaultbrowser                List all available browsers
            macdefaultbrowser <browser>      Set <browser> as the default
            macdefaultbrowser --version      Show version information
            macdefaultbrowser --help         Show this help message
        
        Examples:
            macdefaultbrowser                # List browsers (default marked with *)
            macdefaultbrowser chrome         # Set Chrome as default browser
            macdefaultbrowser safari         # Set Safari as default browser
        
        Note: When changing the default browser, the system dialog will be
        automatically confirmed (requires accessibility permissions).
        """)
    }
}