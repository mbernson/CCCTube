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

    @State var error: NetworkError?
    @State var isErrorPresented = false

    @EnvironmentObject var api: ApiService

    var body: some View {
        NavigationView {
            ScrollView {
                TalksGrid(talks: talks)
            }
            #if !os(tvOS)
            .navigationTitle(query.localizedTitle)
            #endif
            .task {
                await refresh()
            }
            .alert(isPresented: $isErrorPresented, error: error) {
                Button("OK") {}
            }
        }
        .navigationViewStyle(.stack)
    }

    func refresh() async {
        do {
            switch query {
            case .recent:
                talks = try await api.recentTalks()
            case .popular:
                talks = try await api.popularTalks()
            }
        } catch {
            self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
            isErrorPresented = true
            debugPrint(error)
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(query: .popular, talks: [.example])
            .environmentObject(ApiService())
    }
}
