//
//  URLParser.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation

struct URLParser {
    func parseURL(_ url: URL) -> URLRoute? {
        guard url.scheme == "ccctube" else { return nil }
        guard url.host == "talk" else { return nil }

        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count >= 1,
              let id = components.first
        else { return nil }

        if components.last == "play" {
            return .playTalk(id: id)
        } else {
            return .openTalk(id: id)
        }
    }
}
