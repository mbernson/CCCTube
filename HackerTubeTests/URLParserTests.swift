//
//  URLParserTests.swift
//  HackerTubeTests
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import XCTest

@testable import HackerTube

class URLParserTests: XCTestCase {
    let parser = URLParser()

    func testParseOpenURL() {
        let url = URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895")!
        XCTAssertEqual(parser.parseURL(url), .openTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    func testParsePlayURL() {
        let url = URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895/play")!
        XCTAssertEqual(parser.parseURL(url), .playTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    func testInvalidURLs() {
        XCTAssertNil(parser.parseURL(URL(string: "ccctube://")!))
        XCTAssertNil(parser.parseURL(URL(string: "https://google.com/")!))
        XCTAssertNil(parser.parseURL(URL(string: "ccctube://foo")!))
        XCTAssertNil(parser.parseURL(URL(string: "mailto:info@example.com")!))
    }
}
