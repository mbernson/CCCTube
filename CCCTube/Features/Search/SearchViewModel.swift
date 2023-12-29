//
//  SearchViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import CCCApi
import Combine
import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    private let api = ApiService()

    @Published var query: String = ""
    @Published var results: [Talk] = []

    @Published var error: Error?

    private var cancellable: AnyCancellable?

    init() {
        cancellable = $query
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink(receiveValue: { query in
                self.search()
            })
    }

    func search() {
        Task {
            do {
                results = try await api.searchTalks(query: query)
            } catch {
                self.error = error
            }
        }
    }
}
