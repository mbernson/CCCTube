//
//  SearchSuggestion.swift
//  HackerTube
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
        "Security", "Lightning talks", "Climate", "Cryptography", "Encryption",
        "Internet", "Software", "Hardware", "Cloud", "Networking",
        "Privacy", "Mental health", "Accessibility",
        "Artificial intelligence", "AI", "Machine learning", "Neural networks", "Language models",
        "Electronics", "Robotics", "Quantum computing", "Microcontroller",
        "Python", "Rust",
        "Science", "Chemistry", "Math", "Physics", "Biology", "Biohacking", "DNA", "Biometrics",
        "Information theory", "Communication", "GPS",
        "The ultimate talk", "Radio communications", "Badge",
        "Blockchain", "Cryptocurrency",
        "Digital forensics",
        "Drones", "Autonomous vehicles", "Smart cities",
        "Cybersecurity", "Digital rights", "Ethical hacking", "Data Science",
        "Internet governance", "Hacktivism",
        "Open source", "Free software",
        "Malware analysis", "Data protection", "Forensics", "Social engineering",
        "Network security",
        "Virtual reality (VR)", "Augmented reality (AR)", "Wearable tech",
        "Penetration testing", "Bug bounties", "Reverse engineering",
        "Dark web", "Anonymity",
        "4G", "5G", "Cellular",
    ].map(SearchSuggestion.init)
}
