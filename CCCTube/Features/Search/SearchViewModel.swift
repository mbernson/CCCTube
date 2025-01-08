//
//  SearchViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import CCCApi
import Combine
import Foundation

@Observable
class SearchViewModel {
    private let api: ApiService = .shared
    private var searchQuerySubject = PassthroughSubject<String, Never>()
    private var cancellable: AnyCancellable?

    var results: [Talk] = []
    var error: Error?

    init() {
        cancellable = searchQuerySubject
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink(receiveValue: { query in
                self.search(query: query)
            })
    }

    func updateSearchQuery(_ query: String) {
        searchQuerySubject.send(query)
    }

    func search(query: String) {
        Task {
            do {
                results = try await api.searchTalks(query: query)
            } catch is CancellationError {
            } catch {
                self.error = error
            }
        }
    }
}
