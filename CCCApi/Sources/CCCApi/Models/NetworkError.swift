//
//  NetworkError.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation

public struct NetworkError: LocalizedError {
    public let errorDescription: String?
    public let failureReason: String?

    public init(errorDescription: String, error: Error) {
        self.errorDescription = errorDescription
        failureReason = error.localizedDescription
    }
}
