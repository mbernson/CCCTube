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
            async let recentTalks = api.recentTalks()
            async let popularTalks = api.popularTalks()
            let sections = factory.makeTopShelfSections(recentTalks: try await recentTalks, popularTalks: try await popularTalks)
            return TVTopShelfSectionedContent(sections: sections)
        } catch {
            return nil
        }
    }
}
