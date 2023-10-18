//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import TVServices

class ContentProvider: TVTopShelfContentProvider {
    let api = ApiService()
    let factory = TopShelfContentFactory()

    override func loadTopShelfContent() async -> TVTopShelfContent? {
        do {
            let recentTalks = try await api.recentTalks().prefix(10)
            let sections = factory.makeTopShelfSections(recentTalks: Array(recentTalks))
            return TVTopShelfSectionedContent(sections: sections)
        } catch {
            return nil
        }
    }
}
