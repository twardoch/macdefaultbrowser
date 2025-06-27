// this_file: Tests/macdefaultbrowserTests/BrowserManagerTests.swift

import XCTest
@testable import macdefaultbrowser

final class BrowserManagerTests: XCTestCase {
    
    func testBrowserNameExtraction() {
        XCTAssertEqual(BrowserManager.browserName(from: "com.google.Chrome"), "chrome")
        XCTAssertEqual(BrowserManager.browserName(from: "com.apple.Safari"), "safari")
        XCTAssertEqual(BrowserManager.browserName(from: "org.mozilla.firefox"), "firefox")
        XCTAssertEqual(BrowserManager.browserName(from: "com.microsoft.Edge"), "edge")
        XCTAssertEqual(BrowserManager.browserName(from: "SingleComponent"), "singlecomponent")
    }
    
    func testGetAvailableBrowsers() {
        let browsers = BrowserManager.getAvailableBrowsers()
        
        // Should have at least Safari on any Mac
        XCTAssertTrue(browsers.count > 0)
        XCTAssertTrue(browsers.keys.contains("safari"))
    }
    
    func testGetCurrentDefaultBrowser() {
        let currentBrowser = BrowserManager.getCurrentDefaultBrowser()
        
        // Should have a default browser set
        XCTAssertNotNil(currentBrowser)
    }
    
    func testListBrowsers() {
        let browserList = BrowserManager.listBrowsers()
        
        // Should have at least one browser
        XCTAssertTrue(browserList.count > 0)
        
        // Should have exactly one default browser
        let defaultBrowsers = browserList.filter { $0.isDefault }
        XCTAssertEqual(defaultBrowsers.count, 1)
    }
}