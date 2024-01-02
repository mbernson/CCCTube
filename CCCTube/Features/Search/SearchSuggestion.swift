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
        "Freedom", "Linux", "Ethics", "Internet of Things",
        "Security", "Lightning talks", "Climate", "Cryptography",
        "Internet", "Software", "Hardware", "Cloud", "Networking",
        "Privacy", "Mental health", "Accessibility",
        "AI", "Machine learning", "Neural networks", "Language models",
        "Electronics", "Robotics", "Quantum computing", "Microcontroller",
        "Python", "Rust",
        "Science", "Chemistry", "Math", "Physics", "Biology", "DNA",
        "Information theory", "Communication", "GPS",
        "The ultimate talk", "Radio communications", "Badge",
    ].map(SearchSuggestion.init)
}
