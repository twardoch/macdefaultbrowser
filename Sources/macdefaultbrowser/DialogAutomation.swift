// this_file: Sources/macdefaultbrowser/DialogAutomation.swift

import Foundation

/// Handles automatic confirmation of system dialogs when changing default browser
struct DialogAutomation {
    
    /// Map internal browser names to display names used in system dialogs
    private static func dialogBrowserName(for browserName: String) -> String {
        switch browserName.lowercased() {
        case "chrome":
            return "Chrome"
        case "safari":
            return "Safari"
        case "firefox", "firefoxdeveloperedition":
            return "Firefox"
        case "edgemac":
            return "Edge"
        case "chromium":
            return "Chromium"
        default:
            // For unknown browsers, try the name as-is and also capitalized
            return browserName
        }
    }
    
    /// Confirm the browser change dialog automatically
    /// - Parameters:
    ///   - browserName: Name of the browser being set as default
    ///   - timeout: Maximum time to wait for dialog (default: 2.0 seconds)
    /// - Returns: True if dialog was found and clicked, false otherwise
    @discardableResult
    static func confirmBrowserChangeDialog(for browserName: String, timeout: TimeInterval = 2.0) async -> Bool {
        let displayName = dialogBrowserName(for: browserName)
        let script = """
        tell application "System Events"
            set startTime to current date
            repeat while (current date) - startTime < \(timeout)
                try
                    if exists window 1 of process "CoreServicesUIAgent" then
                        set buttonList to buttons of window 1 of process "CoreServicesUIAgent"
                        repeat with currentButton in buttonList
                            set buttonTitle to name of currentButton as string
                            ignoring case
                                if buttonTitle contains "\(displayName)" then
                                    click currentButton
                                    return "success"
                                end if
                            end ignoring
                        end repeat
                    end if
                end try
                delay 0.1
            end repeat
            return "timeout"
        end tell
        """
        
        return await withCheckedContinuation { continuation in
            Task {
                let result = runAppleScript(script)
                continuation.resume(returning: result == "success")
            }
        }
    }
    
    /// Execute AppleScript and return result
    /// - Parameter script: AppleScript code to execute
    /// - Returns: Result string from the script, or nil if error
    private static func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        
        guard let scriptObject = NSAppleScript(source: script) else {
            return nil
        }
        
        let output = scriptObject.executeAndReturnError(&error)
        
        if error != nil {
            // Log error for debugging but don't expose to user
            return nil
        }
        
        return output.stringValue
    }
    
    /// Set default browser with automatic dialog confirmation
    /// - Parameter browserName: Name of the browser to set as default
    /// - Throws: BrowserError if setting fails
    static func setDefaultBrowserWithAutomation(_ browserName: String) async throws {
        // Start the dialog automation task that will wait for and click the dialog
        let automationTask = Task { () -> Bool in
            // Give the system a moment to show the dialog
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Try to click the dialog button
            let clicked = await confirmBrowserChangeDialog(for: browserName, timeout: 3.0)
            
            if !clicked {
                // Try again with more variations
                let variations = [
                    browserName,
                    dialogBrowserName(for: browserName),
                    browserName.capitalized,
                    "Use \"",  // Sometimes the button just says "Use "Browser Name""
                ]
                
                for variation in variations {
                    if await confirmBrowserChangeDialog(for: variation, timeout: 1.0) {
                        return true
                    }
                }
            }
            
            return clicked
        }
        
        // Set the default browser (this will trigger the dialog)
        do {
            try BrowserManager.setDefaultBrowser(browserName)
        } catch {
            // Cancel the automation task if setting failed
            automationTask.cancel()
            throw error
        }
        
        // Wait for automation to complete
        let dialogClicked = await automationTask.value
        
        // Give the system a moment to process the change
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Note: Even if dialog wasn't clicked, the browser change request was made
        // The user will need to manually confirm if automation failed
        if !dialogClicked {
            print("Note: Could not automatically confirm the dialog. Please click 'Use \"\(browserName)\"' in the system dialog.")
        }
    }
}