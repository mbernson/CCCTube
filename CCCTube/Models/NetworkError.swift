//
//  NetworkError.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation

struct NetworkError: LocalizedError {
  let errorDescription: String?
  let failureReason: String?

  init(errorDescription: String, error: Error) {
    self.errorDescription = errorDescription
    failureReason = error.localizedDescription
  }
}
