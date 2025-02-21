//
//  HackerTubeError.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation

struct HackerTubeError: Error {
    let message: String
}

extension HackerTubeError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
