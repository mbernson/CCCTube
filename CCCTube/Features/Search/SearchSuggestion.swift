//
//  SearchSuggestion.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import Foundation

struct SearchSuggestion: Identifiable {
    let title: String
    var id: String { title }
}

extension SearchSuggestion {
    static let defaultSuggestions: [SearchSuggestion] = [
        "Freedom", "Linux", "ethics", "IoT",
        "security", "lightning talks", "climate", "cryptography",
    ].map(SearchSuggestion.init)
}
