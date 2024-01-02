//
//  CCCTubeUIScreenshotTests.swift
//  CCCTubeUITests
//
//  Created by Mathijs Bernson on 30/12/2023.
//

import XCTest

final class CCCTubeUIScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testRecentTalks() {
        app.launch()
        XCTAssertTrue(app.otherElements["TalksGrid"].buttons.firstMatch.waitForExistence(timeout: 3.0))
        Thread.sleep(forTimeInterval: 2.0)
        takeScreenshot("RecentTalks")
    }

    func testConferences() {
        app.launch()
        app.tabBars.buttons["Conferences"].firstMatch.tap()
        XCTAssertTrue(app.otherElements["ConferencesGrid"].buttons.firstMatch.waitForExistence(timeout: 3.0))
        Thread.sleep(forTimeInterval: 2.0)
        takeScreenshot("Conferences")
    }

    func testVideo() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.launch()

        // "How do GPS/Galileo really work & how the galmon.eu monitors all navigation satellites"
        let talkID = "dc0fe8c9-443d-5873-91ee-cca74db67c80"
        DispatchQueue.main.async {
            XCUIDevice.shared.system.open(URL(string: "ccctube://talk/\(talkID)")!)
        }
        if springboard.buttons["Open"].waitForExistence(timeout: 5) {
            springboard.buttons["Open"].tap()
        }
        takeScreenshot("Video")
    }

    private func takeScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
