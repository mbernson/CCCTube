//
//  SearchContext.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import Combine
import Foundation

final class SearchContext: ObservableObject {
    private var searchQuerySubject = PassthroughSubject<String, Never>()
    var searchQueryPublisher: AnyPublisher<String, Never> {
        searchQuerySubject
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func send(query: String) {
        searchQuerySubject.send(query)
    }
}
