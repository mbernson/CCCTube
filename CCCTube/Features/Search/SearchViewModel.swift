//
//  SearchViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import Foundation
import CCCApi
import Combine

@MainActor class SearchViewModel: ObservableObject {
  let api = ApiService()

  @Published var query: String = ""
  @Published var results: [Talk] = []

  @Published var error: NetworkError? = nil
  @Published var isErrorPresented = false

  private var cancellable: AnyCancellable?

  init() {
    cancellable = $query
      .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
      .sink(receiveValue: { query in
        self.fetchResults(query: query)
      })
  }

  private func fetchResults(query: String) {
    Task {
      do {
        results = try await api.searchTalks(query: query)
      } catch {
        self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
        isErrorPresented = true
        debugPrint(error)
      }
    }
  }
}
