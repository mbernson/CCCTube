//
//  BrowseView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

enum EventsQuery {
    case recent
    case popular

    var localizedTitle: String {
        switch self {
        case .recent:
            return String(localized: "Recent")
        case .popular:
            return String(localized: "Popular")
        }
    }
}

struct BrowseView: View {
    let query: EventsQuery
    @State var talks: [Talk] = []
    @State var error: Error?
    @State var api: ApiService = .shared

    var body: some View {
        NavigationStack {
            ScrollView {
                TalksGrid(talks: talks)
            }
            #if !os(tvOS)
            .navigationTitle(query.localizedTitle)
            #endif
            .task {
                await refresh()
            }
            .refreshable {
                await refresh()
            }
            .alert("Failed to load data from the media.ccc.de API", error: $error)
        }
    }

    func refresh() async {
        do {
            switch query {
            case .recent:
                talks = try await api.recentTalks()
            case .popular:
                talks = try await api.popularTalks(in: .currentYear)
            }
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(query: .popular, talks: [.example])
    }
}
