//
//  CCCTubeError.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation

struct CCCTubeError: Error {
    let message: String
}

extension CCCTubeError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
