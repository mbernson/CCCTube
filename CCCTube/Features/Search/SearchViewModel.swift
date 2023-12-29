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
