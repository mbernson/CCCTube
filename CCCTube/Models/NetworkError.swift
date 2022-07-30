//
//  NetworkError.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation

struct NetworkError: LocalizedError {
  let errorDescription: String?

  init(error: Error) {
    errorDescription = error.localizedDescription
  }
}
