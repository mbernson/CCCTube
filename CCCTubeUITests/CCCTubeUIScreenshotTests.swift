//
//  CCCTubeUIScreenshotTests.swift
//  CCCTubeUITests
//
//  Created by Mathijs Bernson on 30/12/2023.
//

import XCTest

final class CCCTubeUIScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    func testLaunch() throws {
        XCTAssertTrue(app.otherElements["TalksGrid"].buttons.firstMatch.waitForExistence(timeout: 3.0))
        takeScreenshot("Launch Screen")
    }

    func takeScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
