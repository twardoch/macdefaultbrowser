// this_file: Sources/macdefaultbrowser/DialogAutomation.swift

import Foundation

/// Handles automatic confirmation of system dialogs when changing default browser
/// Uses subprocess approach to run osascript for better compatibility
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
            return browserName
        }
    }
    
    /// Execute osascript as a subprocess
    private static func runOsascript(_ script: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error running osascript: \(error)")
            return nil
        }
    }
    
    /// Monitor and click the dialog using subprocess
    private static func monitorAndClickDialog(browserName: String) {
        let displayName = dialogBrowserName(for: browserName)
        
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<20 { // Check for 10 seconds
                Thread.sleep(forTimeInterval: 0.5)
                
                let script = """
                tell application "System Events"
                    if exists process "CoreServicesUIAgent" then
                        if exists window 1 of process "CoreServicesUIAgent" then
                            set buttonList to buttons of window 1 of process "CoreServicesUIAgent"
                            repeat with currentButton in buttonList
                                try
                                    set buttonTitle to name of currentButton as string
                                    if buttonTitle contains "\(displayName)" or buttonTitle contains "Use" then
                                        click currentButton
                                        return "Clicked: " & buttonTitle
                                    end if
                                end try
                            end repeat
                            return "No matching button found"
                        else
                            return "No window"
                        end if
                    else
                        return "No process"
                    end if
                end tell
                """
                
                if let result = runOsascript(script) {
                    if result.contains("Clicked:") {
                        // Extract browser name from result like "Clicked: Use "Edge""
                        if let browserStart = result.range(of: "\""),
                           let browserEnd = result.range(of: "\"", options: .backwards),
                           browserStart.lowerBound < browserEnd.lowerBound {
                            let browser = String(result[browserStart.upperBound..<browserEnd.lowerBound])
                            print("As the default browser, the system will now use \(browser)")
                        } else {
                            print("As the default browser, the system will now use \(displayName)")
                        }
                        break
                    }
                }
            }
        }
    }
    
    /// Set default browser with automatic dialog confirmation
    static func setDefaultBrowserWithAutomation(_ browserName: String) async throws {
        // Start monitoring in background
        monitorAndClickDialog(browserName: browserName)
        
        // Small delay to ensure monitor is running
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Trigger the dialog
        try BrowserManager.setDefaultBrowser(browserName)
        
        // Wait for the change to complete
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }
}